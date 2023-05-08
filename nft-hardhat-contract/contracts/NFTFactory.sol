// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFT.sol";

//create NFTFactory which creates another NFT contract
contract NFTFactory {
    address[] public deployedNFTs;

    function createNFT(string memory name, string memory symbol) public {
        address newNFT = address(new NFT(name, symbol, msg.sender));
        deployedNFTs.push(newNFT);
    }

    function getDeployedNFTs() public view returns (address[] memory) {
        return deployedNFTs;
    }
}
