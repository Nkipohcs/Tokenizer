- **Configure MetaMask** for BSC Testnet (ChainId 97).
- **Get tBNB** from the official faucet.
- **Install**: `npm i`, then `npm test` to validate locally.
- **Deploy**: `npm run deploy:testnet`.
- **Verify** on BscScan testnet: `npm run verify:testnet`.
- **Add the token** to MetaMask: `FT42` address, `decimals=18`, symbol `FT42`.
- **Using the multisig**:
  1. Build the admin `data` (e.g., ABI-encoded `token.pause()` -> via Hardhat/ethers).
  2. Owner A calls `submit(target=FT42, value=0, data)` -> get `txId`.
  3. Owner B calls `confirm(txId)`.
  4. Owner A/B calls `execute(txId)` -> the admin transaction is executed.
