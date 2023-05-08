//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// use openzeppelin ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    // Constructor
    constructor(string memory name, string memory symbol, address creator) {}

    // State variables
    uint256 public totalNFTs;
    mapping(address => uint256) public addressToNFTCount;

    // Events
    event NFTMinted(address indexed _from, uint256 indexed _tokenId);

    // Modifiers
    modifier maxSupplyCheck() {
        // ...
        _;
    }

    // Main Functions
    function mint(address receiver, string memory tokenURI) public returns (uint256) {
        // ...
    }

    function transfer(address from, address to, uint256 tokenId) public {
        // ...
    }

    function maxSupply() public view returns (uint256) {
        // ...
    }

    // View/Pure functions
    function balanceOf(address owner) public view returns (uint256) {
        // ...
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        // ...
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        // ...
    }

    function totalSupply() public view returns (uint256) {
        // ...
    }
}
