// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./NFT.sol";
import "./library/PriceConverter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract NftFactory is Ownable {
    // IERC20 immutable USDC;
    AggregatorV3Interface immutable priceFeed;

    //The structure to store info about a listed token
    struct ListedToken {
        uint256 tokenId;
        address payable companyProvider;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    //the event emitted when a token is successfully listed
    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    mapping(address nft => mapping(uint256 => ListedToken))
        private nftToTokenIdToListedTokenInfo;
    // right now we are supposing provider can only create NFt once, because if he create seconnd time the fist one address will replace
    
    mapping(address => NFT) private ProviderToNft;
    mapping(address => address) private NftToProvider;
    mapping(address => uint) private NftToPrice;
    mapping(address => bool) private ProviderToIsWhitelist;
    mapping(address => uint256) private nftToExpiration;

    modifier isWhiteListed() {
        require(ProviderToIsWhitelist[msg.sender], "not in White list");
        _;
    }

    // constructor(IERC20 _usdc, AggregatorV3Interface _priceFeed){
    constructor(AggregatorV3Interface _priceFeed) {
        // USDC = IERC20(_usdc);
        priceFeed = _priceFeed;
    }

    // fixed amount in usd

    function createNFT(
        string memory name,
        string memory symbol,
        uint256 _supplyLimit,
        uint256 priceOfNft,
        bool _isTransferable,
        bool _isExpireable,
        uint256 expiration
    ) public returns (address) {
        NFT nft = new NFT(
            name,
            symbol,
            _supplyLimit,
            _isTransferable,
            _isExpireable
        );

        ProviderToNft[msg.sender] = nft;
        NftToProvider[address(nft)] = msg.sender;
        NftToPrice[address(nft)] = priceOfNft;

        nftToExpiration[address(nft)] = expiration; // if not expire put 0

        return address(nft);
    }

    function getNft(address _provider) internal view returns (NFT) {
        return ProviderToNft[_provider];
    }

    function buyNftWithNative(
        address to,
        address _nft,
        string memory tokenUri
    ) external payable {
        uint revenue = (msg.value * 10) / 100;

        (bool sent /* bytes memory data */, ) = NftToProvider[_nft].call{
            value: msg.value - revenue
        }("");
        require(sent, "Tx Failed");

        NFT nft = ProviderToNft[NftToProvider[_nft]];
        nft.safeMint(to, block.timestamp + nftToExpiration[_nft], tokenUri);
    }

    // function buyNftWithUsd(address to,address _nft,uint256 amount) external {
    //     // right now I am sending whole amount of purchase to user

    //     require(amount >= NftToPrice[_nft] && amount > 0 ,"amount not correct" ); // found vulnerability if we not put amount > 0

    //     uint revenue = amount * 10 / 100;

    //     require(USDC.transferFrom(msg.sender,address(this), revenue), "tx failed");

    //     require(USDC.transferFrom(msg.sender,NftToProvider[_nft], amount - revenue), "tx failed");

    //     NFT nft = ProviderToNft[NftToProvider[_nft]];
    //     nft.safeMint(to,nftToExpiration[_nft]);

    // }

    function WhiteListProvider(address _provider) external onlyOwner {
        ProviderToIsWhitelist[_provider] = true;
    }

    function excecuteSale(
        address _nft,
        address to,
        uint256 tokenId
    ) external payable {
        uint priceInUsd = PriceConverter.getConversionRate(
            msg.value,
            priceFeed
        );
        ListedToken memory tokenInfo = nftToTokenIdToListedTokenInfo[_nft][
            tokenId
        ];
        require(tokenInfo.currentlyListed, "token not listed");
        require(priceInUsd >= tokenInfo.price, "low price");

        uint256 revenue = (msg.value * 10) / 100;
        (bool sentToSeller, /*bytes memory data*/) = tokenInfo.seller.call{
            value: msg.value - revenue
        }("");
        (bool sentToProvider, /*bytes memory _data*/) = tokenInfo
            .companyProvider
            .call{value: revenue / 2}("");

        require(sentToProvider && sentToSeller, "Tx Failed");

        nftToTokenIdToListedTokenInfo[_nft][tokenId].seller = payable(to);
        nftToTokenIdToListedTokenInfo[_nft][tokenId].price = priceInUsd;

        nftToTokenIdToListedTokenInfo[_nft][tokenId].currentlyListed = false;
        ProviderToNft[NftToProvider[_nft]].transferFrom(
            msg.sender,
            to,
            tokenId
        );
    }

    // user apna Nft list krne jaa rha he
    function SaleNft(
        address _nft,
        address seller,
        uint256 tokenId,
        uint256 _price,
        bool reSale
    ) external {
        require(
            ProviderToNft[NftToProvider[_nft]].ownerOf(tokenId) == seller,
            "you are not an owner"
        );
        // uint priceInUsd = PriceConverter.getConversionRate(_price, priceFeed);
        nftToTokenIdToListedTokenInfo[_nft][tokenId] = ListedToken(
            tokenId,
            payable(NftToProvider[_nft]),
            payable(seller),
            _price,
            reSale
        );
        ProviderToNft[NftToProvider[_nft]].approve(address(this), tokenId);
    }

    function getMatictoUSD() public payable returns (uint256) {
        uint priceInUsd = PriceConverter.getConversionRate(
            msg.value,
            priceFeed
        );
        return priceInUsd;
    }

    // function useNft(){

    //     send token URI
    //     from token URI we get json
    //     we change things in json -> parameter
    //     we pin the new json on pinata
    //     we send back the URI to Smart contract
    //     set the token URI with Token Identifier

    // }

    function getNftAddress(address _provider) external view returns (address) {
        return address(ProviderToNft[_provider]);
    }
}

// MockV3Aggregator  => 0xd9145CCE52D386f254917e481eB44e9943F39138
// MockUSD => 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
