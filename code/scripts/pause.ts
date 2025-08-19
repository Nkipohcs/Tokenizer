import { ethers } from "hardhat";

async function main() {
  const tokenAddr = process.env.TOKEN_ADDRESS!;
  const token = await ethers.getContractAt("FT42Token", tokenAddr);
  const tx = await token.pause();
  await tx.wait();
  console.log("Token transfers paused");
}

main().catch((e)=>{ console.error(e); process.exit(1); });
