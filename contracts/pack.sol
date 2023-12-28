// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./card.sol";

contract PackContract {
    // Constants
    uint256 public constant CARDS_IN_PACK = 10;
    uint256 public constant CARDS_IN_DECK = 60;

    uint256 public PACK_PRICE = 0.25 ether;
    uint256 public DECK_PRICE = 1 ether;

    // 1 colorless card per pack
    enum PackType {
        RED,
        GREEN,
        BLUE,
        BLACK,
        WHITE,
    }

    // with one or two colorless cards per deck
    enum DeckType {
        REDGREEN,
        BLUEWHITE,
        BLACKBLUE,
        GreenBlack,
        WhiteRed
    }

    // map deck types to color types
    mapping(DeckType => uint256[]) public deckTypeToColorType;

    constant deckTypeToColorType[DeckType.REDGREEN] = [PackType.RED, PackType.GREEN];
    constant deckTypeToColorType[DeckType.BLUEWHITE] = [PackType.BLUE, PackType.WHITE];
    constant deckTypeToColorType[DeckType.BLACKBLUE] = [PackType.BLACK, PackType.BLUE];
    constant deckTypeToColorType[DeckType.GreenBlack] = [PackType.GREEN, PackType.BLACK];
    constant deckTypeToColorType[DeckType.WhiteRed] = [PackType.WHITE, PackType.RED];

    // Card contract
    Card public cardContract;

    // Pack Master
    address public packMaster;

    // only packMaster modifier
    modifier onlyPackMaster() {
        require(
            msg.sender == packMaster,
            "Only the Pack Master can call this function"
        );
        _;
    }

    constructor(address _cardContract) {
        packMaster = msg.sender;
        cardContract = Card(_cardContract);
    }

    function buyBoosterPack(PackType packType) public payable {
        require(msg.value == PACK_PRICE, "Incorrect payment amount");
        // get random card ids the pack type
        uint256[] memory cardIds = cardContract.getIdsByColor(packType);
        // mint pack
        cardContract.packMint(msg.sender, cardIds, "");
    }

    function buyPreBuiltDeck(DeckType deckType) public payable {
        require(msg.value == DECK_PRICE, "Incorrect payment amount");
        // get color types to build deck from
        uint256[] memory colorTypes = deckTypeToColorType[deckType];
        // get random card ids for each color type
        uint256[] memory color1CardIds = cardContract.getIdsByColor(colorTypes[0]);
        uint256[] memory color2CardIds = cardContract.getIdsByColor(colorTypes[1]);
        // get random card ids for each color type
        uint256[] memory cardIds = new uint256[](CARDS_IN_DECK);
        for (uint256 i = 0; i < CARDS_IN_DECK; i++) {
            if (i < CARDS_IN_DECK / 2) {
                cardIds[i] = _getRandomCardId(color1CardIds);
            } else {
                cardIds[i] = _getRandomCardId(color2CardIds);
            }
        }
        // mint deck
        cardContract.deckMint(msg.sender, cardIds, "");
    }

    function _getRandomCardId(uint256[] memory cardIds) private view returns (uint256) {
        // [WIP] - add better randomness
        uint256 rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        // resolve rand to a number between 0 and cardIds.length
        return cardIds[rand % cardIds.length];
    }

    function withdraw() public onlyPackMaster {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setPackPrice(uint256 _packPrice) public onlyPackMaster {
        PACK_PRICE = _packPrice;
    }

    function setDeckPrice(uint256 _deckPrice) public onlyPackMaster {
        DECK_PRICE = _deckPrice;
    }

    function setPackMaster(address _packMaster) public onlyPackMaster {
        packMaster = _packMaster;
    }

    function setCardContract(address _cardContract) public onlyPackMaster {
        cardContract = Card(_cardContract);
    }

    function getPackPrice() public view returns (uint256) {
        return PACK_PRICE;
    }

    function getDeckPrice() public view returns (uint256) {
        return DECK_PRICE;
    }


}
