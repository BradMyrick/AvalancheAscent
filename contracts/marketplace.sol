// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./card.sol";
import "./pack.sol";

contract Marketplace is ERC1155Holder, ReentrancyGuard, Ownable {
    Card public cardContract;
    PackContract public packContract;

    struct Listing {
        address seller;
        uint256[] cardIds;
        uint256[] quantities;
        uint256 price;
        bool isActive;
        uint256 expirationTime;
    }

    struct Trade {
        address initiator;
        address counterparty;
        uint256[] offeredCardIds;
        uint256[] offeredQuantities;
        uint256[] requestedCardIds;
        uint256[] requestedQuantities;
        bool isActive;
        bool isAccepted;
        uint256 expirationTime;
    }

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Trade) public trades;
    uint256 public nextListingId;
    uint256 public nextTradeId;

    uint256 public constant TRADE_EXPIRATION_TIME = 7 days;
    uint256 public constant LISTING_EXPIRATION_TIME = 30 days;
    uint256 public listingFeePercentage = 250; // 2.5% fee (in basis points)
    uint256 public tradeFeePercentage = 100; // 1% fee (in basis points)
    address public feeCollector;
    address public arbiter;

    event ListingCreated(uint256 indexed listingId, address indexed seller, uint256[] cardIds, uint256[] quantities, uint256 price);
    event ListingCancelled(uint256 indexed listingId);
    event ListingPurchased(uint256 indexed listingId, address indexed buyer);
    event TradeOffered(uint256 indexed tradeId, address indexed initiator, address indexed counterparty);
    event TradeAccepted(uint256 indexed tradeId);
    event TradeCancelled(uint256 indexed tradeId);
    event PackPurchased(address indexed buyer, PackContract.PackType packType);
    event DeckPurchased(address indexed buyer, PackContract.DeckType deckType);
    event DisputeRaised(uint256 indexed tradeId, address indexed disputeInitiator);
    event DisputeResolved(uint256 indexed tradeId, bool tradeExecuted);

    constructor(address _cardContract, address _packContract) {
        cardContract = Card(_cardContract);
        packContract = PackContract(_packContract);
        feeCollector = msg.sender;
        arbiter = msg.sender;
    }

    function createListing(uint256[] memory _cardIds, uint256[] memory _quantities, uint256 _price) external nonReentrant {
        require(_cardIds.length == _quantities.length, "Mismatched arrays");
        require(_cardIds.length > 0, "Empty listing");

        for (uint256 i = 0; i < _cardIds.length; i++) {
            require(cardContract.balanceOf(msg.sender, _cardIds[i]) >= _quantities[i], "Insufficient balance");
            cardContract.safeTransferFrom(msg.sender, address(this), _cardIds[i], _quantities[i], "");
        }

        listings[nextListingId] = Listing({
            seller: msg.sender,
            cardIds: _cardIds,
            quantities: _quantities,
            price: _price,
            isActive: true,
            expirationTime: block.timestamp + LISTING_EXPIRATION_TIME
        });

        emit ListingCreated(nextListingId, msg.sender, _cardIds, _quantities, _price);
        nextListingId++;
    }

    function cancelListing(uint256 _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing not active");
        require(listing.seller == msg.sender, "Not the seller");

        for (uint256 i = 0; i < listing.cardIds.length; i++) {
            cardContract.safeTransferFrom(address(this), msg.sender, listing.cardIds[i], listing.quantities[i], "");
        }

        listing.isActive = false;
        emit ListingCancelled(_listingId);
    }

    function purchaseListing(uint256 _listingId) external payable nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing not active");
        require(block.timestamp < listing.expirationTime, "Listing expired");
        require(msg.value == listing.price, "Incorrect payment");

        uint256 fee = (listing.price * listingFeePercentage) / 10000;
        uint256 sellerAmount = listing.price - fee;

        for (uint256 i = 0; i < listing.cardIds.length; i++) {
            cardContract.safeTransferFrom(address(this), msg.sender, listing.cardIds[i], listing.quantities[i], "");
        }

        payable(listing.seller).transfer(sellerAmount);
        payable(feeCollector).transfer(fee);
        listing.isActive = false;
        emit ListingPurchased(_listingId, msg.sender);
    }

    function offerTrade(
        address _counterparty,
        uint256[] memory _offeredCardIds,
        uint256[] memory _offeredQuantities,
        uint256[] memory _requestedCardIds,
        uint256[] memory _requestedQuantities
    ) external nonReentrant {
        require(_offeredCardIds.length == _offeredQuantities.length, "Mismatched offered arrays");
        require(_requestedCardIds.length == _requestedQuantities.length, "Mismatched requested arrays");
        require(_offeredCardIds.length > 0 || _requestedCardIds.length > 0, "Empty trade");

        for (uint256 i = 0; i < _offeredCardIds.length; i++) {
            require(cardContract.balanceOf(msg.sender, _offeredCardIds[i]) >= _offeredQuantities[i], "Insufficient balance");
            cardContract.safeTransferFrom(msg.sender, address(this), _offeredCardIds[i], _offeredQuantities[i], "");
        }

        trades[nextTradeId] = Trade({
            initiator: msg.sender,
            counterparty: _counterparty,
            offeredCardIds: _offeredCardIds,
            offeredQuantities: _offeredQuantities,
            requestedCardIds: _requestedCardIds,
            requestedQuantities: _requestedQuantities,
            isActive: true,
            isAccepted: false,
            expirationTime: block.timestamp + TRADE_EXPIRATION_TIME
        });

        emit TradeOffered(nextTradeId, msg.sender, _counterparty);
        nextTradeId++;
    }

    function acceptTrade(uint256 _tradeId) external nonReentrant {
        Trade storage trade = trades[_tradeId];
        require(trade.isActive, "Trade not active");
        require(block.timestamp < trade.expirationTime, "Trade expired");
        require(trade.counterparty == msg.sender, "Not the counterparty");
        require(!trade.isAccepted, "Trade already accepted");

        for (uint256 i = 0; i < trade.requestedCardIds.length; i++) {
            require(cardContract.balanceOf(msg.sender, trade.requestedCardIds[i]) >= trade.requestedQuantities[i], "Insufficient balance");
            cardContract.safeTransferFrom(msg.sender, address(this), trade.requestedCardIds[i], trade.requestedQuantities[i], "");
        }

        for (uint256 i = 0; i < trade.offeredCardIds.length; i++) {
            cardContract.safeTransferFrom(address(this), msg.sender, trade.offeredCardIds[i], trade.offeredQuantities[i], "");
        }

        for (uint256 i = 0; i < trade.requestedCardIds.length; i++) {
            cardContract.safeTransferFrom(address(this), trade.initiator, trade.requestedCardIds[i], trade.requestedQuantities[i], "");
        }

        uint256 fee = calculateTradeFee(trade);
        if (fee > 0) {
            require(msg.value >= fee, "Insufficient fee");
            payable(feeCollector).transfer(fee);
        }

        trade.isAccepted = true;
        trade.isActive = false;
        emit TradeAccepted(_tradeId);
    }

    function cancelTrade(uint256 _tradeId) external nonReentrant {
        Trade storage trade = trades[_tradeId];
        require(trade.isActive, "Trade not active");
        require(trade.initiator == msg.sender, "Not the initiator");

        for (uint256 i = 0; i < trade.offeredCardIds.length; i++) {
            cardContract.safeTransferFrom(address(this), msg.sender, trade.offeredCardIds[i], trade.offeredQuantities[i], "");
        }

        trade.isActive = false;
        emit TradeCancelled(_tradeId);
    }

    function raiseTradingDispute(uint256 _tradeId) external {
        Trade storage trade = trades[_tradeId];
        require(trade.isActive, "Trade not active");
        require(msg.sender == trade.initiator || msg.sender == trade.counterparty, "Not involved in trade");
        
        emit DisputeRaised(_tradeId, msg.sender);
    }

    function resolveDispute(uint256 _tradeId, bool _executeTransaction) external {
        require(msg.sender == arbiter, "Only arbiter can resolve disputes");
        Trade storage trade = trades[_tradeId];
        require(trade.isActive, "Trade not active");

        if (_executeTransaction) {
            // Execute the trade
            for (uint256 i = 0; i < trade.offeredCardIds.length; i++) {
                cardContract.safeTransferFrom(address(this), trade.counterparty, trade.offeredCardIds[i], trade.offeredQuantities[i], "");
            }
            for (uint256 i = 0; i < trade.requestedCardIds.length; i++) {
                cardContract.safeTransferFrom(address(this), trade.initiator, trade.requestedCardIds[i], trade.requestedQuantities[i], "");
            }
        } else {
            // Return cards to original owners
            for (uint256 i = 0; i < trade.offeredCardIds.length; i++) {
                cardContract.safeTransferFrom(address(this), trade.initiator, trade.offeredCardIds[i], trade.offeredQuantities[i], "");
            }
        }

        trade.isActive = false;
        emit DisputeResolved(_tradeId, _executeTransaction);
    }

    function batchCreateListings(uint256[][] memory _cardIds, uint256[][] memory _quantities, uint256[] memory _prices) external nonReentrant {
        require(_cardIds.length == _quantities.length && _cardIds.length == _prices.length, "Mismatched arrays");
        for (uint256 i = 0; i < _cardIds.length; i++) {
            createListing(_cardIds[i], _quantities[i], _prices[i]);
        }
    }

    function batchPurchaseListings(uint256[] memory _listingIds) external payable nonReentrant {
        uint256 totalCost = 0;
        for (uint256 i = 0; i < _listingIds.length; i++) {
            Listing storage listing = listings[_listingIds[i]];
            require(listing.isActive, "Listing not active");
            require(block.timestamp < listing.expirationTime, "Listing expired");
            totalCost += listing.price;
        }
        require(msg.value >= totalCost, "Insufficient payment");

        for (uint256 i = 0; i < _listingIds.length; i++) {
            purchaseListing(_listingIds[i]);
        }

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    function calculateTradeFee(Trade storage _trade) internal view returns (uint256) {
        uint256 totalValue = 0;
        for (uint256 i = 0; i < _trade.offeredCardIds.length; i++) {
            totalValue += cardContract.getCardValue(_trade.offeredCardIds[i]) * _trade.offeredQuantities[i];
        }
        for (uint256 i = 0; i < _trade.requestedCardIds.length; i++) {
            totalValue += cardContract.getCardValue(_trade.requestedCardIds[i]) * _trade.requestedQuantities[i];
        }
        return (totalValue * tradeFeePercentage) / 10000;
    }

    function setListingFeePercentage(uint256 _newFeePercentage) external onlyOwner {
        require(_newFeePercentage <= 1000, "Fee too high"); // Max 10%
        listingFeePercentage = _newFeePercentage;
    }

    function setTradeFeePercentage(uint256 _newFeePercentage) external onlyOwner {
        require(_newFeePercentage <= 500, "Fee too high"); // Max 5%
        tradeFeePercentage = _newFeePercentage;
    }

    function setFeeCollector(address _newFeeCollector) external onlyOwner {
        feeCollector = _newFeeCollector;
    }

    function setArbiter(address _newArbiter) external onlyOwner {
        arbiter = _newArbiter;
    }

    function buyPack(PackContract.PackType _packType) external payable nonReentrant {
        require(msg.value == packContract.PACK_PRICE(), "Incorrect payment");
        packContract.buyBoosterPack{value: msg.value}(_packType);
        emit PackPurchased(msg.sender, _packType);
    }

    function buyDeck(PackContract.DeckType _deckType) external payable nonReentrant {
        require(msg.value == packContract.DECK_PRICE(), "Incorrect payment");
        packContract.buyPreBuiltDeck{value: msg.value}(_deckType);
        emit DeckPurchased(msg.sender, _deckType);
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}