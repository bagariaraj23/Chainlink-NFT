const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  const MockUSD = await ethers.getContractFactory("MockUsd");

  console.log("deploying MockUsd...");
  const mockUsd = await MockUSD.deploy();
  await mockUsd.deployed();

  console.log("MockUsd deployed to:", mockUsd.address);
  fs.writeFileSync(
    "deployedAddress.txt",
    `mockUsdAddress=${mockUsd.address}\n`
  );

  //owner
  const owner = await mockUsd.owner();
  console.log("Owner:", owner);

  //signers
  const signers = await ethers.getSigners();
  console.log("Signers:", signers);

  //balance
  const balance = await signers[0].getBalance();
  console.log("Balance:", balance.toString());

  //balance
  const balance1 = await signers[1].getBalance();
  console.log("Balance:", balance1.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
