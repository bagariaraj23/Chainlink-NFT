const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  const deployer = await ethers.getSigner();
  console.log(deployer);
  console.log("Deploying contracts with the account:", deployer.address);

  const value = ethers.utils.parseEther("1000000000");
  const MockV3Aggregator = await ethers.getContractFactory("MockV3Aggregator");
  const mockV3Aggregator = await MockV3Aggregator.deploy(8, value);

  console.log("MockV3Aggregator deployed to:", mockV3Aggregator.address);
  fs.appendFileSync(
    "deployedAddress.txt",
    `mockV3AggregatorAddress=${mockV3Aggregator.address}\n`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
