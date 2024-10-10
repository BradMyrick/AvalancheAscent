// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./card.sol";

contract PackContract is Ownable, ReentrancyGuard, VRFConsumerBase {
    // Constants
    uint256 public constant CARDS_IN_PACK = 10;
    uint256 public constant CARDS_IN_DECK = 60;

    uint256 public packPrice = 0.25 ether;
    uint256 public deckPrice = 1 ether;

    bytes32 internal keyHash;
    uint256 internal fee;

    // 1 colorless card per pack
    enum PackType {
        RED,
        GREEN,
        BLUE,
        BLACK,
        WHITE
    }

    // with one or two colorless cards per deck
    enum DeckType {
        REDGREEN,
        BLUEWHITE,
        BLACKBLUE,
        GREENBLACK,
        WHITERED
    }

    // map deck types to color types
    mapping(DeckType => PackType[2]) public deckTypeToColorType;

    // Card contract
    Card public cardContract;

    event BoosterPackBought(address indexed buyer, PackType packType);
    event PreBuiltDeckBought(address indexed buyer, DeckType deckType);

    constructor(address _cardContract, address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        cardContract = Card(_cardContract);
        keyHash = _keyHash;
        fee = _fee;

        deckTypeToColorType[DeckType.REDGREEN] = [PackType.RED, PackType.GREEN];
        deckTypeToColorType[DeckType.BLUEWHITE] = [PackType.BLUE, PackType.WHITE];
        deckTypeToColorType[DeckType.BLACKBLUE] = [PackType.BLACK, PackType.BLUE];
        deckTypeToColorType[DeckType.GREENBLACK] = [PackType.GREEN, PackType.BLACK];
        deckTypeToColorType[DeckType.WHITERED] = [PackType.WHITE, PackType.RED];
    }

    function buyBoosterPack(PackType packType) external payable nonReentrant {
        require(msg.value == packPrice, "Incorrect payment amount");

        requestRandomness(keyHash, fee);
        // The VRF will call fulfillRandomness which will handle minting the pack
        // We pass the pack type as the requestId to use it later
        emit BoosterPackBought(msg.sender, packType);
    }

    function buyPreBuiltDeck(DeckType deckType) external payable nonReentrant {
        require(msg.value == deckPrice, "Incorrect payment amount");

        requestRandomness(keyHash, fee);
        // The VRF will call fulfillRandomness which will handle minting the deck
        // We pass the deck type as the requestId to use it later
        emit PreBuiltDeckBought(msg.sender, deckType);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // If the first bit is 0, it's a booster pack. Otherwise, it's a pre-built deck.
        if (uint256(requestId) & (1 << 255) == 0) {
            PackType packType = PackType(uint256(requestId));
            _mintBoosterPack(msg.sender, packType, randomness);
        } else {
            DeckType deckType = DeckType(uint256(requestId) & ~(1 << 255));
            _mintPreBuiltDeck(msg.sender, deckType, randomness);
        }
    }

    function _mintBoosterPack(address to, PackType packType, uint256 randomness) private {
        uint256[] memory cardIds = new uint256[](CARDS_IN_PACK);
        for (uint256 i = 0; i < CARDS_IN_PACK; i++) {
            cardIds[i] = _getRandomCardId(packType, randomness, i);
        }
        cardContract.packMint(to, cardIds, "");
    }

    function _mintPreBuiltDeck(address to, DeckType deckType, uint256 randomness) private {
        PackType[2] memory colorTypes = deckTypeToColorType[deckType];
        uint256[] memory cardIds = new uint256[](CARDS_IN_DECK);
        for (uint256 i = 0; i < CARDS_IN_DECK; i++) {
            PackType colorType = i < CARDS_IN_DECK / 2 ? colorTypes[0] : colorTypes[1];
            cardIds[i] = _getRandomCardId(colorType, randomness, i);
        }
        cardContract.deckMint(to, cardIds, "");
    }

    function _getRandomCardId(PackType packType, uint256 randomness, uint256 index) private view returns (uint256) {
        uint256[] memory cardIds = cardContract.getIdsByColorAndCardType(uint256(packType), uint256(Card.CardType.CLIMBER));
        uint256 rand = uint256(keccak256(abi.encode(randomness, index)));
        return cardIds[rand % cardIds.length];
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setPackPrice(uint256 _packPrice) external onlyOwner {
        packPrice = _packPrice;
    }

    function setDeckPrice(uint256 _deckPrice) external onlyOwner {
        deckPrice = _deckPrice;
    }

    function setCardContract(address _cardContract) external onlyOwner {
        cardContract = Card(_cardContract);
    }
}
