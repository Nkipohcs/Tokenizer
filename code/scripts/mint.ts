import { ethers } from "hardhat";

async function main() {
  const tokenAddr = process.env.TOKEN_ADDRESS!;
  const to = process.env.MINT_TO!;
  const amount = BigInt(process.env.MINT_AMOUNT!); // in wei (18 decimals)
  const token = await ethers.getContractAt("FT42Token", tokenAddr);
  const tx = await token.mint(to, amount);
  await tx.wait();
  console.log(`Minted ${ethers.formatEther(amount)} tokens to ${to}`);
}

main().catch((e)=>{ console.error(e); process.exit(1); });
