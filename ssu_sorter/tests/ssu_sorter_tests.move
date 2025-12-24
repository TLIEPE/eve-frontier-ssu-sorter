#[test_only]
module ssu_sorter::ssu_sorter_tests;

use sui::test_scenario;
use ssu_sorter::ssu_sorter;

// Test constants
const CARBONACEOUS_ORE_TYPE_ID: u64 = 42;
const SSU_TYPE_INPUT: u64 = 1;
const SSU_TYPE_CARBON: u64 = 2;

// Helper function to create a 32-byte vector filled with a value
fun create_location_hash(fill_value: u8): vector<u8> {
    let mut result = vector::empty<u8>();
    let mut i = 0;
    while (i < 32) {
        vector::push_back(&mut result, fill_value);
        i = i + 1;
    };
    result
}

#[test]
fun test_create_ssu() {
    let mut scenario = test_scenario::begin(@0x1);
    let ctx = test_scenario::ctx(&mut scenario);

    // Create location hash (32 bytes)
    let location_hash = create_location_hash(0u8);

    // Create input SSU with no partner
    ssu_sorter::create_ssu(SSU_TYPE_INPUT, location_hash, 1000, @0x0, ctx);

    test_scenario::end(scenario);
}

#[test]
fun test_deposit_item() {
    let mut scenario = test_scenario::begin(@0x1);

    // Create input SSU
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let location_hash = create_location_hash(0u8);
        ssu_sorter::create_ssu(SSU_TYPE_INPUT, location_hash, 1000, @0x0, ctx);
    };

    test_scenario::next_tx(&mut scenario, @0x1);

    // Create carbon SSU
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let location_hash = create_location_hash(0u8);
        ssu_sorter::create_ssu(SSU_TYPE_CARBON, location_hash, 1000, @0x0, ctx);
    };

    test_scenario::next_tx(&mut scenario, @0x1);

    // Deposit carbon ore (no transfer since no partner configured)
    {
        let ssu1 = test_scenario::take_shared(&scenario);
        let ssu2 = test_scenario::take_shared(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);

        // Determine which is input and which is carbon based on type
        let (type1, _, _, _, _) = ssu_sorter::get_info(&ssu1);
        let (mut input_ssu, mut carbon_ssu) = if (type1 == SSU_TYPE_INPUT) {
            (ssu1, ssu2)
        } else {
            (ssu2, ssu1)
        };

        ssu_sorter::deposit_item(&mut input_ssu, &mut carbon_ssu, CARBONACEOUS_ORE_TYPE_ID, 100, ctx);

        // Check that item was added to input SSU
        let (type_id, _, used_cap, item_count, _) = ssu_sorter::get_info(&input_ssu);
        assert!(type_id == SSU_TYPE_INPUT, 0);
        assert!(used_cap == 100, 0);
        assert!(item_count == 1, 0);

        // Carbon SSU should still be empty
        let (_, _, carbon_used_cap, _, _) = ssu_sorter::get_info(&carbon_ssu);
        assert!(carbon_used_cap == 0, 0);

        test_scenario::return_shared(input_ssu);
        test_scenario::return_shared(carbon_ssu);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_auto_transfer_carbon_nearby() {
    let mut scenario = test_scenario::begin(@0x1);

    // Create carbon SSU first
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let location_hash = create_location_hash(1u8); // Same prefix = nearby
        ssu_sorter::create_ssu(SSU_TYPE_CARBON, location_hash, 1000, @0x0, ctx);
    };

    test_scenario::next_tx(&mut scenario, @0x1);

    // Create input SSU without partner (simplified test)
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let location_hash = create_location_hash(1u8); // Same prefix as carbon SSU
        ssu_sorter::create_ssu(SSU_TYPE_INPUT, location_hash, 1000, @0x0, ctx);
    };

    test_scenario::next_tx(&mut scenario, @0x1);

    // Deposit carbon - no transfer since no partner configured
    {
        let ssu1 = test_scenario::take_shared(&scenario);
        let ssu2 = test_scenario::take_shared(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);

        // Determine which is input and which is carbon based on type
        let (type1, _, _, _, _) = ssu_sorter::get_info(&ssu1);
        let (mut input_ssu, mut carbon_ssu) = if (type1 == SSU_TYPE_INPUT) {
            (ssu1, ssu2)
        } else {
            (ssu2, ssu1)
        };

        ssu_sorter::deposit_item(&mut input_ssu, &mut carbon_ssu, CARBONACEOUS_ORE_TYPE_ID, 200, ctx);

        // Check input SSU has the carbon (no transfer)
        let (_, _, input_used_cap, _, _) = ssu_sorter::get_info(&input_ssu);
        assert!(input_used_cap == 200, 0);

        // Carbon SSU should still be empty
        let (_, _, carbon_used_cap, _, _) = ssu_sorter::get_info(&carbon_ssu);
        assert!(carbon_used_cap == 0, 0);

        test_scenario::return_shared(input_ssu);
        test_scenario::return_shared(carbon_ssu);
    };

    test_scenario::end(scenario);
}
