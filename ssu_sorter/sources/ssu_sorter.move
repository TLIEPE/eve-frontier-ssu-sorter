/// Module: ssu_sorter
///
/// EVE Frontier SSU Sorter - On-chain mod for automatic resource routing between Smart Storage Units.
/// This module provides functionality to create SSUs (StorageUnits) and automatically transfer
/// Carbonaceous Ore from input SSUs to nearby carbon storage SSUs when space is available.
module ssu_sorter::ssu_sorter;

use sui::event;

// ===== CONSTANTS =====

/// Item type ID for Carbonaceous Ore
const CARBONACEOUS_ORE_TYPE_ID: u64 = 42;

/// Number of bytes to check for "nearby" proximity (first 16 bytes of location_hash must match)
const NEARBY_PREFIX_LENGTH: u64 = 16;

/// SSU Type IDs
const SSU_TYPE_INPUT: u64 = 1;
const SSU_TYPE_CARBON: u64 = 2;

// ===== ERROR CODES =====

/// Location hash must be exactly 32 bytes
const E_INVALID_LOCATION_HASH_LENGTH: u64 = 1;

/// Insufficient capacity in target SSU
const E_INSUFFICIENT_CAPACITY: u64 = 2;

/// Invalid SSU type
const E_INVALID_SSU_TYPE: u64 = 4;

// ===== STRUCTS =====

/// Represents a simple item stored in an SSU
public struct SimpleItem has store, drop, copy {
    /// The type ID of the item (e.g., 42 = Carbonaceous Ore)
    item_type_id: u64,
    /// Quantity of this item
    quantity: u64,
}

/// Smart Storage Unit - the core storage entity
public struct StorageUnit has key, store {
    /// Unique object ID
    id: UID,
    /// Owner address
    owner: address,
    /// Type of SSU: 1 = Input-SSU, 2 = Carbon-SSU
    type_id: u64,
    /// 32-byte hash representing location (for proximity simulation)
    location_hash: vector<u8>,
    /// Maximum storage capacity
    max_capacity: u64,
    /// Currently used capacity
    used_capacity: u64,
    /// Items stored in this SSU
    items: vector<SimpleItem>,
    /// Partner SSU ID for automatic routing (address @0x0 means none, mainly for input SSUs)
    partner_carbon_ssu: address,
}

// ===== EVENTS =====

/// Event emitted when carbon is automatically transferred between SSUs
public struct CarbonTransferred has copy, drop {
    /// Source SSU ID
    from_ssu_id: ID,
    /// Target SSU ID
    to_ssu_id: ID,
    /// Amount of carbon transferred
    quantity: u64,
    /// Timestamp of transfer
    timestamp_ms: u64,
}

// ===== PUBLIC FUNCTIONS =====

/// Create a new Smart Storage Unit
/// For input SSUs (type_id = 1), you can optionally specify a partner carbon SSU for automatic routing
/// Use 0x0 for no partner in CLI
public fun create_ssu(
    type_id: u64,
    location_hash: vector<u8>,
    max_capacity: u64,
    partner_ssu_id: address,
    ctx: &mut TxContext,
) {
    // Validate inputs
    assert!(vector::length(&location_hash) == 32, E_INVALID_LOCATION_HASH_LENGTH);
    assert!(type_id == SSU_TYPE_INPUT || type_id == SSU_TYPE_CARBON, E_INVALID_SSU_TYPE);

    let ssu = StorageUnit {
        id: object::new(ctx),
        owner: tx_context::sender(ctx),
        type_id,
        location_hash,
        max_capacity,
        used_capacity: 0,
        items: vector::empty(),
        partner_carbon_ssu: partner_ssu_id,
    };

    transfer::share_object(ssu);
}

/// Deposit an item into a StorageUnit and optionally transfer to partner SSU
/// For input SSUs with a partner carbon SSU, automatically transfers carbon if nearby and space available
public fun deposit_item(
    input_ssu: &mut StorageUnit,
    carbon_ssu: &mut StorageUnit,
    item_type_id: u64,
    quantity: u64,
    ctx: &mut TxContext,
) {
    // Check capacity of input SSU
    let new_used_capacity = input_ssu.used_capacity + quantity;
    assert!(new_used_capacity <= input_ssu.max_capacity, E_INSUFFICIENT_CAPACITY);

    // Add item to input storage
    let item = SimpleItem { item_type_id, quantity };
    vector::push_back(&mut input_ssu.items, item);
    input_ssu.used_capacity = new_used_capacity;

    // Attempt automatic carbon transfer if this is an input SSU
    if (input_ssu.type_id == SSU_TYPE_INPUT) {
        auto_transfer_carbon(input_ssu, carbon_ssu, ctx);
    };
}

/// Check if SSUs are partners (helper function)
fun is_partner(partner_addr: address, target_ssu: &StorageUnit): bool {
    partner_addr == object::id_to_address(&object::uid_to_inner(&target_ssu.id))
}

/// Automatically transfer carbon from input SSU to carbon SSU if nearby and has space
fun auto_transfer_carbon(
    from_ssu: &mut StorageUnit,
    to_ssu: &mut StorageUnit,
    ctx: &TxContext,
) {
    // Check if target SSU is actually the partner
    if (from_ssu.partner_carbon_ssu == @0x0 || !is_partner(from_ssu.partner_carbon_ssu, to_ssu)) {
        return // No partner configured or wrong SSU
    };

    // Check proximity - first NEARBY_PREFIX_LENGTH bytes of location_hash must match
    let mut nearby = true;
    let mut i = 0;
    while (i < NEARBY_PREFIX_LENGTH) {
        if (*vector::borrow(&from_ssu.location_hash, i) != *vector::borrow(&to_ssu.location_hash, i)) {
            nearby = false;
            break
        };
        i = i + 1;
    };

    if (!nearby) return; // Not nearby

    // Find carbon items in the input SSU
    let mut i = 0;
    let mut total_carbon_to_transfer = 0u64;

    while (i < vector::length(&from_ssu.items)) {
        let item = vector::borrow(&from_ssu.items, i);
        if (item.item_type_id == CARBONACEOUS_ORE_TYPE_ID) {
            // Check if target SSU has enough capacity
            let available_capacity = to_ssu.max_capacity - to_ssu.used_capacity;
            if (available_capacity >= item.quantity) {
                // Transfer entire quantity
                total_carbon_to_transfer = total_carbon_to_transfer + item.quantity;
            } else if (available_capacity > 0) {
                // Transfer partial quantity
                total_carbon_to_transfer = total_carbon_to_transfer + available_capacity;
            }
        };
        i = i + 1;
    };

    // If we can transfer something, do it
    if (total_carbon_to_transfer > 0) {
        // Remove carbon from source SSU
        remove_carbon_from_ssu(from_ssu, total_carbon_to_transfer);

        // Add carbon to target SSU
        add_carbon_to_ssu(to_ssu, total_carbon_to_transfer);

        // Emit transfer event
        event::emit(CarbonTransferred {
            from_ssu_id: object::uid_to_inner(&from_ssu.id),
            to_ssu_id: object::uid_to_inner(&to_ssu.id),
            quantity: total_carbon_to_transfer,
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });
    }
}

// ===== HELPER FUNCTIONS =====

/// Remove carbon from an SSU (used during transfer)
fun remove_carbon_from_ssu(ssu: &mut StorageUnit, quantity_to_remove: u64) {
    let mut remaining_to_remove = quantity_to_remove;
    let mut i = 0;

    while (i < vector::length(&ssu.items) && remaining_to_remove > 0) {
        let item = vector::borrow_mut(&mut ssu.items, i);
        if (item.item_type_id == CARBONACEOUS_ORE_TYPE_ID) {
            if (item.quantity <= remaining_to_remove) {
                // Remove entire item
                remaining_to_remove = remaining_to_remove - item.quantity;
                ssu.used_capacity = ssu.used_capacity - item.quantity;
                vector::remove(&mut ssu.items, i);
                // Don't increment i since we removed an element
                continue
            } else {
                // Reduce quantity
                item.quantity = item.quantity - remaining_to_remove;
                ssu.used_capacity = ssu.used_capacity - remaining_to_remove;
                remaining_to_remove = 0;
            }
        };
        i = i + 1;
    };
}

/// Add carbon to an SSU (used during transfer)
fun add_carbon_to_ssu(ssu: &mut StorageUnit, quantity: u64) {
    // Check if we already have carbon items
    let mut i = 0;
    let mut found = false;

    while (i < vector::length(&ssu.items)) {
        let item = vector::borrow_mut(&mut ssu.items, i);
        if (item.item_type_id == CARBONACEOUS_ORE_TYPE_ID) {
            item.quantity = item.quantity + quantity;
            found = true;
            break
        };
        i = i + 1;
    };

    // If no carbon item exists, create one
    if (!found) {
        let carbon_item = SimpleItem {
            item_type_id: CARBONACEOUS_ORE_TYPE_ID,
            quantity,
        };
        vector::push_back(&mut ssu.items, carbon_item);
    };

    ssu.used_capacity = ssu.used_capacity + quantity;
}

// ===== VIEW FUNCTIONS =====

/// Get information about a StorageUnit
public fun get_info(ssu: &StorageUnit): (u64, u64, u64, u64, vector<SimpleItem>) {
    (
        ssu.type_id,
        ssu.max_capacity,
        ssu.used_capacity,
        vector::length(&ssu.items),
        ssu.items
    )
}
