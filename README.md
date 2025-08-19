# FT42 — Tokenizer (BEP-20)

**Name**: FortyTwo Token  
**Ticker**: FT42  
**Network**: BNB Smart Chain **Testnet** (Chapel, chainId 97)  
**Standard**: BEP-20 (ERC-20 compatible)

## Goals & Choices
- Strict compliance with the BEP-20 standard.
- Security as a priority: `Ownable`, `ERC20Pausable`, `ERC20Capped`, `ERC20Burnable`, safe ERC20 rescue.
- Clear documentation (how-to, security) + deployment/verification scripts.
- Bonus: Simple 2-of-3 Multisig as the token owner.

## Directory Structure


.
├── code/ # smart contracts, scripts, tests, Hardhat config
├── deployment/ # network info, deployed addresses
└── documentation/ # WHITEPAPER, HOWTO, SECURITY


## Dependencies & Versions
- Node.js LTS (≥ 18)
- Hardhat ^2.22, ethers ^6
- OpenZeppelin **4.9.x** (stable API for ERC20Capped/Pausable)
- Solidity **^0.8.20**

## Installation
```bash
cd code
cp .env.example .env
# edit .env (testnet PRIVATE_KEY, BSCSCAN_API_KEY)
npm i
npm run build
npm test
```

## Deployment (Testnet)
```bash
npm run deploy:testnet
```

Output: FT42Token and SimpleMultiSig addresses, ownership transfer completed.

## Verification (BscScan Testnet)
```bash
# export addresses and owners to the env then
npm run verify:testnet
```

## Publication

Fill in the contract address and network in `deployment/addresses.json`.

Verify the code on testnet.bscscan.com (via script).

Add the ticker (FT42) in the explorer's metadata tab if necessary.

## Minimal Actions Demo

- **Transfer**: `transfer(to, amount)`
- **Pause/Unpause**: via `pause.ts` / `unpause.ts` scripts
- **Mint (owner/multisig)**: `mint.ts`
- **Burn**: `burn(amount)`
- **Rescue**: `rescueERC20(token,to,amount)` (cannot rescue FT42)

## Security

See `documentation/SECURITY.md`. Principles:

- Supply cap (anti-inflation).
- Pausable transfers (incident response).
- Owner ≠ EOA: multisig recommended (included).
- No payable functions, no external calls on transfers.
- Protected rescue function.

## Multisig Bonus

`SimpleMultiSig.sol` (2-of-3). The token is `Ownable`; we migrate ownership to the multisig to require 2 confirmations for admin operations.

Alternative: Gnosis Safe (testnet) as owner (out of scope for this repo, but recommended in production).

## Address & Network (to be completed after deployment)

- **Network**: BSC Testnet (Chapel)
- **FT42 Token**: `0x…`
- **Multisig**: `0x…`
