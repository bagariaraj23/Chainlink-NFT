// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFT is ERC721, Ownable,ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;

    event Attest(address indexed to, uint256 indexed tokenId );
    event Revoke(address indexed to, uint256 indexed tokenId );




    Counters.Counter private _tokenIdCounter;

    uint256 public totalSupply = 0;
    uint256 public supplyLimit = 0;

    constructor(string memory name,string memory symbol,uint256 _supplyLimit) ERC721(name, symbol) {
        supplyLimit = _supplyLimit;
       
    }

    
    function safeMint(address to) public onlyOwner {
        require(supplyLimit > totalSupply,"All Sold"); // when token count reach the max supply
        require(balanceOf(to) == 0,"already have token"); // think when one user can mint only one token

        uint256 tokenId = _tokenIdCounter.current();
        
        _tokenIdCounter.increment();
        totalSupply += 1;
        _safeMint(to, tokenId);
    }






    function remainigNftsToBeSold() external view returns(uint256) {
        return supplyLimit - totalSupply;
    }


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function revoke(uint256 tokenId) external onlyOwner{
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
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override virtual {
        require(from == address(0) || to == address(0),"token cannot transfer");
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
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override virtual {

        if(from == address(0)){
           emit Attest(to, firstTokenId);
        }
        else if(to == address(0)){
           emit Revoke(to, firstTokenId);
        }

    }





    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }



    
}