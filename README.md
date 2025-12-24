# 🚀 EVE Frontier SSU Sorter

**Your First On-Chain Mod for EVE Frontier!** ✨

Automatic sorting of resources between Smart Storage Units (SSUs) using Sui Move. Focused on Carbonaceous Ore, but extensible to all resource types.

**Keywords:** EVE Frontier, Sui Move, SSU, On-Chain Mod, Resource Sorting

---

## 📊 Status: Early Prototype / Work in Progress

This is a **Community Prototype** for On-Chain Modding in EVE Frontier using Sui Move.
Created as preparation for the upcoming Sui migration and fully programmable Smart Assemblies.

> **⚠️ Important:** This is still in early development. Works only on Localnet (local test network), not on the real EVE Frontier network.

---

## 🤔 What Does This Mod Do?

Imagine: You're mining resources and your SSUs sort everything automatically! 🎯

### The Problem:
- In EVE Frontier, you collect many different resources (Common Ore, Carbonaceous Ore, Metal-rich Ore, etc.)
- SSUs are like storage boxes, but they don't sort automatically
- You have to manually move everything around

### The Solution: Automatic Resource Sorting! ⚡

1. **Input-SSU** (accepts everything): Your collection station for all resources
2. **Carbon-SSU** (Carbonaceous Ore only): Special storage for Carbonaceous Ore

**When you put Carbonaceous Ore in the Input-SSU:**
- ✅ Automatic Detection: "That's Carbonaceous Ore!"
- ✅ Proximity Check: Are the SSUs "close" enough? (same location hash)
- ✅ Space Check: Does the Carbon-SSU have enough space?
- ✅ Automatic Transfer: Carbonaceous Ore moves to the Carbon-SSU!

**Example Scenario:**
```
Input-SSU: [Common Ore, Carbonaceous Ore, Metal-rich Ore, Carbonaceous Ore]
           ↓ (Carbonaceous Ore is automatically detected)
Carbon-SSU: [Carbonaceous Ore, Carbonaceous Ore]
```

This is **real On-Chain Automation** – programmed in Sui Move! 🤖

---

## 🛠️ Prerequisites

You only need the **Sui CLI** (Command Line Interface):

### Installation:

**macOS:**
```bash
brew install sui
```

**Windows/Linux:**
```bash
# Follow the official guide:
# https://docs.sui.io/guides/developer/getting-started/sui-install
```

**Verify:**
```bash
sui --version
# Should show something like "sui 1.62.0" or higher (as of December 2025)
```

> 💡 **Tip:** Sui CLI is like a toolbox for blockchain development. You can deploy and test smart contracts with it.

---

## 🌐 Localnet Setup

**Localnet = Your Personal Playground!** 🎮

Here you learn blockchain development without spending real money.

### Step 1: Start Localnet

```bash
sui start --with-faucet --force-regenesis
```

**What's happening here?**
- `sui start` = Starts your local blockchain server
- `--with-faucet` = Gives you free "Test-SUI" (play money)
- `--force-regenesis` = Fresh start (deletes old data)

> ⏱️ **Wait time:** This can take 30-60 seconds. You'll see "Sui Node started successfully!" when it's done.

### Step 2: Open New Terminal Session

Open a **new terminal window** and connect to your localnet:

```bash
sui client switch --env localnet
```

### Step 3: Get Test Money (Faucet)

```bash
sui client faucet
```

**What's this?** The "Faucet" is like an ATM for test networks. Gives you free SUI for testing.

### Step 4: Check Balance

```bash
sui client gas
```

**Example output:**
```
Object ID: 0x...
Owner: ...
Balance: 10000000000 MIST
```

> 💡 **Gas = Transaction Fees!** In the real blockchain, transactions cost gas (like gasoline for a car). On Localnet, gas is **free** – perfect for learning!

### Step 5: Wallet Info

Your wallet was created automatically! 🎉

```bash
sui client addresses
# Shows your wallet address
```

> 🔑 **Important:** This is a test wallet. In the real blockchain, you'd need a secure wallet.

---

## 🚀 Build & Deploy

Now let's deploy your smart contract to the localnet!

### Step 1: Navigate to Package Directory

```bash
cd ssu_sorter
```

### Step 2: Compile Code

```bash
sui move build
```

**Success?** You see "BUILDING ssu_sorter" and then nothing more = All good!

### Step 3: Deploy Smart Contract

```bash
sui client publish --gas-budget 1000000000
```

**What's happening:**
- `--gas-budget 1000000000` = Budget for transaction costs (1 billion MIST = very generous)

**Find the Package ID in the output:**

```
Transaction Digest: ...
Published Objects:
  ┌──
  │ ObjectID: 0xabc123...def456
  │ Sender: 0x...
  │ Owner: ...
  │ ObjectType: 0x2::package::Package
  │ Version: 1
  │ Digest: ...
  └──
```

> 📋 **Copy Package ID!** That's `0xabc123...def456` – your smart contract address. Save it for later!

---

## 🧪 How to Test

**Let's get to the real testing!** 🎯

Each SSU gets an **Object ID** (like a unique address).

### Step 1: Create Carbon-SSU

Create a special SSU just for Carbon:

```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    2 \
    "[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    0x0 \
  --gas-budget 10000000
```

**Parameters explained:**
- `2` = SSU Type (2 = Carbon-SSU)
- `[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]` = Location Hash (32 bytes, simulates position)
- `1000` = Maximum capacity
- `0x0` = **No partner SSU** (special address meaning "none" - required for CLI compatibility)

**How to find your SSU's Object ID:**

After running the command, look for this section in the output:

```
Transaction Digest: ...
...
Created Objects:
  ┌──
  │ ObjectID: 0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2
  │ Owner: Shared( 6 )
  │ ObjectType: 0xf346...::ssu_sorter::StorageUnit
  │ Version: 6
  │ Digest: FVuzVsCRM9fh5q3f3zeio1KwayycS1hV7vgrT8N5VYvX
  └──
```

**→ Copy the ObjectID** (the long 0x... string starting with "0x") – this is your Carbon-SSU's unique address!

> 📝 **Important:** Save this ID! You'll need it in the next steps.
> 📝 **Note:** `0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2` = Your Carbon-SSU ID

### Step 2: Create Input-SSU (with Partner!)

Create the collection SSU that automatically forwards to the Carbon-SSU:

```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function create_ssu \
  --args \
    1 \
    "[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" \
    1000 \
    0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2 \
  --gas-budget 10000000
```

**Parameters:**
- `1` = SSU Type (1 = Input-SSU)
- Same Location Hash (must match for "proximity")
- `0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2` = **Partner ID** (your Carbon-SSU!)

**How to find your SSU's Object ID:**

After running the command, look for this section in the output:

```
Transaction Digest: ...
...
Created Objects:
  ┌──
  │ ObjectID: 0x8f7c2b91e4a60327d5f19c8b2a1e45f6a9b3c8d7e1f2a4b5c6d7e8f9a0b1c2
  │ Owner: Shared( 7 )
  │ ObjectType: 0xf346...::ssu_sorter::StorageUnit
  │ Version: 7
  │ Digest: A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A7B8
  └──
```

**→ Copy the ObjectID** (the long 0x... string starting with "0x") – this is your Input-SSU's unique address!

> 📝 **Important:** Save this ID too! You'll need both IDs for the final test.
> 📝 **Note:** `0x8f7c2b91e4a60327d5f19c8b2a1e45f6a9b3c8d7e1f2a4b5c6d7e8f9a0b1c2` = Your Input-SSU ID

### Step 3: Deposit Carbon

Now the exciting part: Put Carbon in the Input-SSU!

```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function deposit_item \
  --args \
    0x8f7c2b91e4a60327d5f19c8b2a1e45f6a9b3c8d7e1f2a4b5c6d7e8f9a0b1c2 \
    0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2 \
    42 \
    500 \
  --gas-budget 10000000
```

**Parameters:**
- `0x8f7c2b91e4a60327d5f19c8b2a1e45f6a9b3c8d7e1f2a4b5c6d7e8f9a0b1c2` = **Input-SSU ID** (from Step 2)
- `0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2` = **Carbon-SSU ID** (from Step 1)
- `42` = Item Type ID for Carbonaceous Ore
- `500` = Quantity

**Replace the IDs above with your actual SSU IDs from the previous steps!** 🔄

### Step 4: Check Status

Check both SSUs:

**Input-SSU:**
```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function get_info \
  --args 0x8f7c2b91e4a60327d5f19c8b2a1e45f6a9b3c8d7e1f2a4b5c6d7e8f9a0b1c2
```

**Carbon-SSU:**
```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function get_info \
  --args 0x5c3aba17f1e95110a5cf09c015e185e5f50431fa81a562327e07c79f15482ba2
```

---

## 🎉 Expected Results

### Before Deposit:
- **Input-SSU:** `used_capacity: 0` (empty)
- **Carbon-SSU:** `used_capacity: 0` (empty)

### After Deposit:
- **Input-SSU:** `used_capacity: 0` ✅ **(Carbonaceous Ore was automatically transferred away!)**
- **Carbon-SSU:** `used_capacity: 500` ✅ **(Carbonaceous Ore arrived automatically!)**

**🎯 The Proof:** The automatic transfer worked because the Carbonaceous Ore moved from Input-SSU to Carbon-SSU automatically! This is proven by the change in `used_capacity` values.

**Note:** The `get_info` function shows the most important info (`used_capacity`). The items list might not be displayed in detail, but the capacity change proves the transfer worked!

> 🎊 **Congratulations!** You just performed your first automatic On-Chain transfer!
>
> **The automatic transfer is proven by the change in used_capacity – no separate event query needed on localnet.**

---

## 🔮 Future Plans

This is just the beginning! 🚀

- **More Resources:** Not just Carbon, but all ore types
- **Real Proximity:** LocationProof for real positions (not just hashes)
- **SSU Network:** Multiple SSUs that forward to each other
- **Registry Integration:** When the official registry arrives
- **UI Tools:** Web interface for easy management

---

## 📄 License & Usage

**MIT License** – Free to fork, learn, and build upon!

**Important:** This is my personal exploration of the future modding system.
If you use parts of this code, please give credit (link to this repo).

> 💝 **Donations welcome:** Bitcoin `bc1q...` (coming soon)
> Or just ⭐ star the repo – that already helps!

---

## ⚠️ Disclaimer

This is **NOT affiliated** with CCP Games.
All mechanics are based on public analysis (evefrontier/world-contracts) and the whitepaper.
Everything may change when the Sui migration goes live.

---

## 🏆 What You Learned

You just:
- ✅ Installed and used Sui CLI
- ✅ Started a local blockchain server
- ✅ Deployed a smart contract
- ✅ Created and configured SSUs
- ✅ Tested automatic resource transfer
- ✅ Observed On-Chain events

**Congratulations on your first On-Chain Mod for EVE Frontier!** 🎉

> 🌟 **Next Step:** Extend the mod with more resource types or build your own On-Chain feature!

Built with ❤️ by TLIEPE – December 2025
