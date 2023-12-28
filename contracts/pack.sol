// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./card.sol";

contract Packs {
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
        for (uint256 i = 0; i < CARDS_IN_PACK; i++) {
            uint256[] memory cardIds = cardContract.getIdsByColor(packType);
            uint256 randomCardId = _getRandomCardId(cardIds);
            cardContract.packMint(msg.sender, randomCardId, 1, "");
        }
    }

    function buyPreBuiltDeck(DeckType deckType) public payable {

        for (uint256 i = 0; i < CARDS_IN_DECK; i++) {
            uint256 randomCardId = _getRandomCardId(deckType);
            cardContract.packMint(msg.sender, randomCardId, 1, "");
        }
    }

    function _getRandomCardId(uint256[] memory cardIds) private view returns (uint256) {
        // [WIP] - add better randomness
        return cardIds[0];

    }

    function _getRandomCardId(uint256[] memory cardIds) private view returns (uint256) {
        // [WIP] - add better randomness
        return cardIds[0];

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
