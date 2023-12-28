import hre from "hardhat";

async function main() {
  const CardContract =  await hre.viem.deployContract("CardContract");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  