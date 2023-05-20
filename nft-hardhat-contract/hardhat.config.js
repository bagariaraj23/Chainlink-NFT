require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("dotenv").config();

/*** 
 * @type import('hardhat/config').HardhatUserConfig 
 * */

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
      },
      {
        version: "0.6.7",
      },
      {
        version: "0.8.7",
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      // blockConfirmations: 1,
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      gas: 1000000000,
      accounts: [process.env.PRIVATE_KEY],
      blockConfirmations: 6,
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 100,
    enabled: false,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    buyer:{
      default: 1,
    }
  },
  mocha: {
    timeout: 2000000,
  },
};
