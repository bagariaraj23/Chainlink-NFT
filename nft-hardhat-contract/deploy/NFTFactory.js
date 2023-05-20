const { network, ethers } = require("hardhat");
const { verify } = require("../utils/verify");
const fs = require("fs");

async function main() {
  const mockUsdAddress = fs
    .readFileSync("deployedAddress.txt")
    .toString()
    .split("\n")[0]
    .split("=")[1];
//   console.log(mockUsdAddress);

  const mockV3AggregatorAddress = fs
    .readFileSync("deployedAddress.txt")
    .toString()
    .split("\n")[1]
    .split("=")[1];
//   console.log(mockV3AggregatorAddress);
  // get Signers
  const signers = await ethers.getSigners();

  console.log("Deploying contracts with the account:", signers[0].address);

  const nftFactory = await ethers.getContractFactory("NftFactory");

  console.log("Deploying NFTFactory...");
  const nftFactoryInstance = await nftFactory.deploy(mockUsdAddress, mockV3AggregatorAddress);
  await nftFactoryInstance.deployed();

  console.log("NFTFactory deployed to:", nftFactoryInstance.address);
    fs.appendFileSync(
    "deployedAddress.txt",
    `NFTFactoryAddress=${nftFactoryInstance.address}\n`
    );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
