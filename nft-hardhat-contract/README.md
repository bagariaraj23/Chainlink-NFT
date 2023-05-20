# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

## How to Deploy Scripts

**First** run

```
npx hardhat node --network hardhat
```

**Second** run

```
npx hardhat run deploy/Mocks/MockUsd.js --network localhost
```

**Then** run

```
npx hardhat run deploy/Mocks/MockV3Aggregator.js --network localhost
```

**Lastly** 
```
npx hardhat run deploy/NFTfactory.js --network localhost
```

All the deploy scripts will work and the addresses will be stored in ```./deployedAddress.txt```