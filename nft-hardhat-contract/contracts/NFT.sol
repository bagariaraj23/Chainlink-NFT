// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";                                // used for counting the tokenIDs
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";                           // used for creating the NFT(Standard ERC721)
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";        // used for burning the NFT (using the _burn function)
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";      // used for overriding the tokenURI function

contract NFT is ERC721, Ownable, ERC721URIStorage, ERC721Burnable {
    // Counters constructor from library: Counters and using it as Counters here
    using Counters for Counters.Counter;

    // Defining 2 events:
    // 1. When a token is attested "to" a user(address) with the "tokenId" of token transferred/attested
    // 2. When a token is revoked "from" a user(address) with the "tokenId" of token transferred/revoked
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    // mapping of tokenID and their expiration timestamp
    mapping(uint256 => uint256) private tokenExpiration;

    // declaring a variable of type Counters.Counter to keep track of tokenIDs
    Counters.Counter private _tokenIdCounter;

    // initial supply of tokens is 0, supply limit is also set to 0, initially it is not transferable and not expireable
    uint256 public totalSupply = 0;
    uint256 public supplyLimit = 0;
    bool isTransferable = false;
    bool isExpireable = false;

    // constructor to initialise the contract with the 
    // NFT Name, symbol, supplyLimit, isTransferable and isExpireable
    // Using ERC721 from openzeppelin to create the NFT taking name and symbol as parameters
    constructor(
        string memory name,
        string memory symbol,
        uint256 _supplyLimit,
        bool _isTransferable,
        bool _isExpireable
    ) ERC721(name, symbol) {
        supplyLimit = _supplyLimit;
        isTransferable = _isTransferable;
        isExpireable = _isExpireable;
    }

    // modifier to check if the token is expired or not
    // We are passing the tokenID of the token to check if it is expired or not
    // if it is expirable then check whether it has expired or not by checking the timestamp, 
    modifier notExpired(uint256 tokenId) {
        if (isExpireable) {
            require(
                tokenExpiration[tokenId] > block.timestamp,
                "NFT has expired"
            );
        }
        _;
    }

    // function to attest/mint a token to a user taking the4 "to" address, setting an expiration time and the tokenURI as parameters
    //  to address is the address of the user to whom the token is to be minted
    //  expiration is the timestamp till when the token is valid
    //  tokenURI is the URI(uniform resource identifier) of the token which stores the metadata of the token
    //  only the owner of the contract can mint the token
    function safeMint(
        address to,
        uint256 expiration,
        string memory tokenUri
    ) public onlyOwner {

        // supply limit is the maximum number of tokens that can be minted and it should be greater than the total supply which is the number of tokens minted till now
        require(supplyLimit > totalSupply, "All Sold"); // when token count reach the max supply
        require(balanceOf(to) == 0, "already have token"); // think when one user can mint only one token

        // getting the current tokenID in tokenID variable and incrementing the tokenIDCounter
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        totalSupply += 1;

        // setting the expiration time of the token
        tokenExpiration[tokenId] = expiration;

        // minting the token with tokenID = tokenId to the user having address "to"
        _safeMint(to, tokenId);

        // Update your URI!!!
        _setTokenURI(tokenId, tokenUri);   
    }

    function burn(uint256 tokenId) public override notExpired(tokenId) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller is not the owner nor approved"
        );
        _burn(tokenId);
        delete tokenExpiration[tokenId];
    }

    // function to burn the NFT with the given tokenID
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // function to revoke a token from a user taking the "tokenId" of the token to be revoked as parameter
    function revoke(uint256 tokenId) external onlyOwner notExpired(tokenId) {
        _burn(tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    // function to check if the token is transferable or not before transfering the token by checking whther the from and to addresses are zero or not(zero address is the address of the deployer of the contract)
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 /* batchSize */
    ) internal virtual override notExpired(firstTokenId) {
        if (!isTransferable) {
            require(
                from == address(0) || to == address(0),
                "token cannot transfer"
            );
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    // function to emit the Attest event when a token is minted and the Revoke event when a token is burned
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 /* batchSize */
    ) internal virtual override {
        if (!isTransferable) {
            if (from == address(0)) {
                emit Attest(to, firstTokenId);
            } else if (to == address(0)) {
                emit Revoke(to, firstTokenId);
            }
        }
    }

    // inherited from ERC721URIStorage
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function remainigNftsToBeSold() external view returns (uint256) {
        return supplyLimit - totalSupply;
    }

    function hasExpired(uint256 tokenId) external view returns (bool) {
        if (isExpireable) {
            return tokenExpiration[tokenId] <= block.timestamp;
        }
        return false;
    }
}
