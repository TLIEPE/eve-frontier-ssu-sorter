# EVE Frontier SSU Sorter

**On-chain mod for EVE Frontier Smart Storage Units**  
Automatic sorting and overflow routing of resources between SSUs (currently focused on Carbonaceous Ore).

### Status: Early Development / WIP

This is a **player-made prototype** for on-chain modding in EVE Frontier using Sui Move.  
It is built as preparation for the upcoming Sui migration and full programmable Smart Assemblies.

Current features (localnet only):
- Create multiple SSUs with different roles (input / storage)
- Automatic detection of specific items (e.g. Carbonaceous Ore)
- Overflow routing to nearby SSU if space available
- Simple location simulation (hash-based proximity check)

The code is intentionally simplified for learning and testing purposes.

### Why this project?

While the community currently builds great off-chain tools (killboards, maps, BOM calculators), this project explores **true on-chain modding** – the future of player-driven gameplay in EVE Frontier.

### Tech Stack

- Sui Move
- Localnet testing (sui-test-validator)
- TypeScript for interaction scripts

### Prerequisites

- Sui CLI must be installed
- You'll likely need a Sui wallet configured

### How to run (localnet)

1. Start localnet:
   ```bash
   sui start --with-faucet --force-regenesis
   ```

2. In new terminal:
   ```bash
   sui client switch --env localnet
   sui client faucet
   sui client gas
   ```

3. Build & deploy:
   ```bash
   sui move build
   sui client publish --gas-budget 1000000000
   ```

4. Run test script (see scripts/spawn_and_sort.ts)

### License & Usage

**MIT License** – feel free to fork, learn, and build upon it.

**Important**: This is my personal exploration of the future modding system.  
If you use parts of this code in your own projects, please give credit (link to this repo).  
Commercial use is allowed under MIT, but I'd appreciate a shoutout or coffee donation if it helps you :)

Bitcoin donations welcome: `bc1q...` (coming soon)  
Or just star the repo – that already helps a lot!

### Future plans

- Real location proximity using LocationProof
- Support for multiple resource types
- Registry integration when available
- Auto-routing network between multiple SSUs

### Disclaimer

This is **not affiliated** with CCP Games.  
All mechanics are based on public repo analysis (evefrontier/world-contracts) and whitepaper.  
Everything is subject to change when Sui migration goes live.

Built by TLIEPE – December 2025

⭐ Star if you like the idea of on-chain resource automation!
