# SSU Sorter CLI Usage Guide

This guide shows how to create and test 2 Smart Storage Units (SSUs) with automatic carbon ore routing using the Sui CLI.

## Prerequisites

- Sui CLI installed and configured
- Localnet running
- Account with test SUI tokens

## Setup Localnet

```bash
# Start localnet
sui start --with-faucet --force-regenesis

# In new terminal, switch to localnet and get test tokens
sui client switch --env localnet
sui client faucet
sui client gas
```

## Deploy the Contract

```bash
# Navigate to the package directory
cd ssu_sorter

# Build and publish
sui move build
sui client publish --gas-budget 1000000000
```

Note the published package ID from the output, e.g.:
```
PackageID: 0xabc123...
```

## Create SSUs

### 1. Create Carbon Storage SSU

```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    2 \
    "[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    "null" \
  --gas-budget 10000000
```

This creates:
- SSU Type: 2 (Carbon Storage)
- Location Hash: 32 bytes starting with 16 ones (for proximity testing)
- Max Capacity: 1000
- Partner SSU: 0x0 (none)

Note the created object ID, e.g.:
```
ObjectID: 0xdef456...
```

### 2. Create Input SSU (linked to Carbon SSU)

```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    1 \
    "[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    "0xdef456..." \
  --gas-budget 10000000
```

This creates:
- SSU Type: 1 (Input SSU)
- Same location hash (nearby to carbon SSU)
- Max Capacity: 1000
- Partner SSU: The carbon SSU address from step 1

## Test Automatic Carbon Transfer

### Deposit Carbon Ore into Input SSU

Note: The deposit_item function requires both the input SSU and the carbon SSU as parameters for automatic transfer.

```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function deposit_item \
  --args \
    "0xghi789..." \
    "0xdef456..." \
    42 \
    500 \
  --gas-budget 10000000
```

Where:
- `0xghi789...` = Input SSU object ID
- `0xdef456...` = Carbon SSU object ID (partner)
- `42` = Carbonaceous Ore type ID
- `500` = Quantity to deposit

This should:
1. Add 500 carbon ore to the input SSU
2. Automatically transfer it to the carbon SSU (since they're nearby and there's space)
3. Emit a `CarbonTransferred` event

### Check SSU Status

Get info about the input SSU:
```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function get_info \
  --args "0xghi789..."
```

Get info about the carbon SSU:
```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function get_info \
  --args "0xdef456..."
```

Expected result:
- Input SSU: used_capacity = 0 (carbon was transferred)
- Carbon SSU: used_capacity = 500 (received the carbon)

## Test Proximity Logic

### Create SSUs in Different Locations

Create another carbon SSU with different location:
```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    2 \
    "[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    "null" \
  --gas-budget 10000000
```

Create input SSU linked to this distant carbon SSU:
```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    1 \
    "[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    "0xjkl012..." \
  --gas-budget 10000000
```

### Deposit Carbon - No Transfer Should Occur

For distant SSUs, create another input SSU that references the distant carbon SSU, then deposit:

```bash
sui client call \
  --package 0xabc123... \
  --module ssu_sorter \
  --function deposit_item \
  --args \
    "0xmno345..." \
    "0xjkl012..." \
    42 \
    300 \
  --gas-budget 10000000
```

Check status - the carbon should remain in the input SSU since the SSUs are not nearby.

## Events

Monitor for `CarbonTransferred` events:
```bash
sui client query-events --event ssu_sorter::ssu_sorter::CarbonTransferred
```

## Run Tests

```bash
sui move test
```

This runs the automated tests that verify:
- SSU creation
- Item deposits
- Automatic transfers when nearby
- No transfers when not nearby</contents>
</xai:function_call name="todo_write">
<parameter name="merge">true
