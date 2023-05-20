// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721, Ownable, ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;

    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    mapping(uint256 => uint256) private tokenExpiration;

    Counters.Counter private _tokenIdCounter;

    uint256 public totalSupply = 0;
    uint256 public supplyLimit = 0;
    bool isTransferable = false;
    bool isExpireable = false;

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

    modifier notExpired(uint256 tokenId) {
        if (isExpireable) {
            require(
                tokenExpiration[tokenId] > block.timestamp,
                "NFT has expired"
            );
        }
        _;
    }

    function safeMint(
        address to,
        uint256 expiration,
        string memory tokenUri
    ) public onlyOwner {
        require(supplyLimit > totalSupply, "All Sold"); // when token count reach the max supply
        require(balanceOf(to) == 0, "already have token"); // think when one user can mint only one token

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        totalSupply += 1;

        tokenExpiration[tokenId] = expiration;

        _safeMint(to, tokenId);

        // Update your URI!!!
        _setTokenURI(tokenId, tokenUri);
    }

    // function setTokenURI(tokenId, tokenUri) external onlyOwner{

    // _setTokenURI(tokenId, tokenUri);

    // }

    function remainigNftsToBeSold() external view returns (uint256) {
        return supplyLimit - totalSupply;
    }

    function burn(uint256 tokenId) public override notExpired(tokenId) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller is not the owner nor approved"
        );
        _burn(tokenId);
        delete tokenExpiration[tokenId];
    }

    function hasExpired(uint256 tokenId) external view returns (bool) {
        if (isExpireable) {
            return tokenExpiration[tokenId] <= block.timestamp;
        }
        return false;
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (!isTransferable) {
            if (from == address(0)) {
                emit Attest(to, firstTokenId);
            } else if (to == address(0)) {
                emit Revoke(to, firstTokenId);
            }
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
