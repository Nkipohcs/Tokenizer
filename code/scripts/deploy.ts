import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);

  // Parameters (18 decimals)
  const decimals = 18n;
  const initialSupply = 1_000_000n * 10n ** decimals; // 1,000,000 FT42
  const cap          = 10_000_000n * 10n ** decimals; // 10,000,000 FT42 max

  // Deploy token
  const FT42 = await ethers.getContractFactory("FT42Token");
  const token = await FT42.deploy(deployer.address, initialSupply, cap);
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();
  console.log("FT42Token deployed at:", tokenAddr);

  // (Optional) Deploy multisig 2-of-3
  // Replace with your 3 owners (test addresses)
  const owners: [string, string, string] = [
    deployer.address,
    "0x0000000000000000000000000000000000000001",
    "0x0000000000000000000000000000000000000002"
  ];

  const MultiSig = await ethers.getContractFactory("SimpleMultiSig");
  const msig = await MultiSig.deploy(owners);
  await msig.waitForDeployment();
  const msigAddr = await msig.getAddress();
  console.log("SimpleMultiSig deployed at:", msigAddr);

  // Transfer token ownership to multisig
  const tx = await token.transferOwnership(msigAddr);
  await tx.wait();
  console.log("Ownership transferred to multisig:", msigAddr);

  // Output addresses (you can write this to deployment/addresses.json)
  console.log(JSON.stringify({
    network: "bsc_testnet",
    token: tokenAddr,
    multisig: msigAddr
  }, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
