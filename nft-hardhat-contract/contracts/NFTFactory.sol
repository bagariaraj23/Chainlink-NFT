// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "./NFT.sol";
import "./library/PriceConverter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract NftFactory  {
    
    
    IERC20 immutable USDC;
    AggregatorV3Interface immutable priceFeed;


    // right now we are supposing provider can only create NFt once, because if he create seconnd time the fist one address will replace
    mapping(address=>NFT) private ProviderToNft;
    mapping(address=>address) private NftToProvider;
    mapping(address=>uint) private NftToPrice;


    constructor(IERC20 _usdc, AggregatorV3Interface _priceFeed){
 
        USDC = IERC20(_usdc);
        priceFeed = _priceFeed;

    }


    // fixed amount in usd

    function createNFT(string memory name, string memory symbol,uint256 _supplyLimit,uint256 priceOfNft) public returns(address){

        NFT nft =  new NFT(name,symbol,_supplyLimit);

            ProviderToNft[msg.sender] = nft;
            NftToProvider[address(nft)] = msg.sender; 
            NftToPrice[address(nft)] = priceOfNft;
           return  address(nft);
    }



    function getNft(address _provider) internal returns(NFT){

        return  ProviderToNft[_provider];

    }



    function getNftAddress(address _provider) external view returns(address){
        return  address(ProviderToNft[_provider]);
    }


    function buyNftWithNative(address to, address _nft) external payable {

        
        uint priceInUsd = PriceConverter.getConversionRate(msg.value, priceFeed);
        require(priceInUsd >= NftToPrice[_nft] && priceInUsd > 0 ,"amount not correct"); // found vulnerability if we not put amount > 0

        uint revenue = msg.value * 10 / 100;

        
        (bool sent,bytes memory data) = to.call{value:msg.value - revenue}("");
        require(sent,"Tx Failed");
        

        NFT nft = ProviderToNft[NftToProvider[_nft]];
        nft.safeMint(to);


    }

    function buyNftWithUsd(address to,address _nft,uint256 amount) external {
        // right now I am sending whole amount of purchase to user

        require(amount >= NftToPrice[_nft] && amount > 0 ,"amount not correct" ); // found vulnerability if we not put amount > 0
        
        uint revenue = amount * 10 / 100;
        
        require(USDC.transferFrom(msg.sender,address(this), revenue), "tx failed");

        require(USDC.transferFrom(msg.sender,NftToProvider[_nft], amount - revenue), "tx failed");
        
        NFT nft = ProviderToNft[NftToProvider[_nft]];
        nft.safeMint(to);


    }


}


