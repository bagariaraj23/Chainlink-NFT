require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-truffle5");
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100000,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-goerli.alchemyapi.io/v2/" + process.env.ALCHEMY_KEY,
        // url: "https://eth-mainnet.alchemyapi.io/v2/"  + process.env.ALCHEMY_KEY,
      },
    },
    local: {
      allowUnlimitedContractSize: true,
      blockGasLimit: 87500000000,
      url: "http://127.0.0.1:8545/",
      accounts: [process.env.PKEY],
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + process.env.ALCHEMY_KEY,
      gas: 10000000,
      accounts: [process.env.PKEY],
    },
    main: {
      url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY,
      gas: 10000000,
      accounts: [process.env.PKEY],
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/"+ process.env.ALCHEMY_KEY,
      gas: 10000000,
      accounts: [process.env.PKEY],
    },
  },
  etherscan: {
    apiKey: {
      //ethereum
      goerli: process.env.ETHERSCAN_API_KEY,
      //polygon
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
  },
  mocha: {
    timeout: 100000000,
  },
};
