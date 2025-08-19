import { ethers } from "hardhat";

async function main() {
  const tokenAddr = process.env.TOKEN_ADDRESS!;
  const multisigAddr = process.env.MULTISIG_ADDRESS!;
  const token = await ethers.getContractAt("FT42Token", tokenAddr);
  const tx = await token.transferOwnership(multisigAddr);
  await tx.wait();
  console.log(`Token ownership transferred to ${multisigAddr}`);
}

main().catch((e)=>{ console.error(e); process.exit(1); });
