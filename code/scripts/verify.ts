import { run } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const tokenAddress = process.env.TOKEN_ADDRESS;
  const msigAddress  = process.env.MULTISIG_ADDRESS;
  const deployerAddress = process.env.DEPLOYER_ADDRESS;

  if (!tokenAddress) {
    throw new Error("TOKEN_ADDRESS must be set in your .env file");
  }
  if (!deployerAddress) {
      throw new Error("DEPLOYER_ADDRESS must be set in your .env file");
  }

  // --- Verify Token ---
  const decimals = 18n;
  const initialSupply = 1_000_000n * 10n ** decimals;
  const cap = 10_000_000n * 10n ** decimals;

  console.log("Verifying FT42Token...");
  try {
    await run("verify:verify", {
      address: tokenAddress,
      constructorArguments: [
        deployerAddress,
        initialSupply,
        cap
      ],
    });
    console.log("FT42Token verified successfully.");
  } catch (error: any) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("Token is already verified.");
    } else {
      console.error("Token verification failed:", error);
    }
  }

  // --- Verify Multisig ---
  if (msigAddress) {
    const owner1 = process.env.OWNER1;
    const owner2 = process.env.OWNER2;
    const owner3 = process.env.OWNER3;

    if (!owner1 || !owner2 || !owner3) {
        throw new Error("For multisig verification, OWNER1, OWNER2, and OWNER3 must be set in your .env file");
    }
    
    console.log("\nVerifying SimpleMultiSig...");
    try {
        await run("verify:verify", {
            address: msigAddress,
            constructorArguments: [[owner1, owner2, owner3]],
        });
        console.log("SimpleMultiSig verified successfully.");
    } catch (error: any) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Multisig is already verified.");
        } else {
            console.error("Multisig verification failed:", error);
        }
    }
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
