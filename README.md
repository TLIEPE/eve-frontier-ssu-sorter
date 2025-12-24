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
- In EVE Frontier, you collect many different resources
- SSUs are like storage boxes, but they don't sort automatically
- You have to manually move everything around

### The Solution: Automatic Resource Sorting! ⚡

1. **Input-SSU** (accepts everything): Your collection station for all resources
2. **Carbon-SSU** (Carbonaceous Ore only): Special storage for coal

**When you put Carbon in the Input-SSU:**
- ✅ Automatic Detection: "That's Carbon!"
- ✅ Proximity Check: Are the SSUs "close" enough?
- ✅ Space Check: Does the Carbon-SSU have enough space?
- ✅ Automatic Transfer: Carbon moves to the Carbon-SSU!

**Example Scenario:**
```
Input-SSU: [Iron, Carbon, Copper, Carbon, Gold]
           ↓ (Carbon is automatically detected)
Carbon-SSU: [Carbon, Carbon]
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
# Should show something like "sui 1.27.0"
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
- `0x0` = **No partner** (special CLI trick!)

**Find the Object ID:**
```
Created Objects:
  ┌──
  │ ObjectID: 0xdef789...ghi012
  │ ...
  └──
```

> 📝 **Note:** `0xdef789...ghi012` = Your Carbon-SSU ID

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
    0xdef789...ghi012 \
  --gas-budget 10000000
```

**Parameters:**
- `1` = SSU Type (1 = Input-SSU)
- Same Location Hash (must match for "proximity")
- `0xdef789...ghi012` = **Partner ID** (your Carbon-SSU!)

**Find the Object ID:**
```
Created Objects:
  ┌──
  │ ObjectID: 0xjkl345...mno678
  │ ...
  └──
```

> 📝 **Note:** `0xjkl345...mno678` = Your Input-SSU ID

### Step 3: Deposit Carbon

Now the exciting part: Put Carbon in the Input-SSU!

```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function deposit_item \
  --args \
    0xjkl345...mno678 \
    0xdef789...ghi012 \
    42 \
    500 \
  --gas-budget 10000000
```

**Parameters:**
- `0xjkl345...mno678` = Input-SSU ID
- `0xdef789...ghi012` = Carbon-SSU ID
- `42` = Item Type ID for Carbonaceous Ore
- `500` = Quantity

### Step 4: Check Status

Check both SSUs:

**Input-SSU:**
```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function get_info \
  --args 0xjkl345...mno678
```

**Carbon-SSU:**
```bash
sui client call \
  --package 0xabc123...def456 \
  --module ssu_sorter \
  --function get_info \
  --args 0xdef789...ghi012
```

---

## 🎉 Expected Results

### Before Deposit:
- **Input-SSU:** `used_capacity: 0`
- **Carbon-SSU:** `used_capacity: 0`

### After Deposit:
- **Input-SSU:** `used_capacity: 0` ✅ (Carbon was transferred!)
- **Carbon-SSU:** `used_capacity: 500` ✅ (Carbon arrived!)

### Check Events:

```bash
sui client query-events --event ssu_sorter::ssu_sorter::CarbonTransferred
```

You'll see an event like:
```
{
  "from_ssu_id": "0xjkl345...mno678",
  "to_ssu_id": "0xdef789...ghi012",
  "quantity": 500,
  "timestamp_ms": 1234567890
}
```

> 🎊 **Congratulations!** You just performed your first automatic On-Chain transfer!

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
