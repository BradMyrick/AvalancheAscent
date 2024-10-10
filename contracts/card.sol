// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Card is ERC1155, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant GUIDE_MASTER_ROLE = keccak256("GUIDE_MASTER_ROLE");
    bytes32 public constant PACK_MASTER_ROLE = keccak256("PACK_MASTER_ROLE");

    enum CardType { GUIDE, CLIMBER, GEAR, ACTION, PLAN, TOOL, CAMP, EMERGENCY, RESCUE }
    enum Color { RED, GREEN, BLUE, BLACK, WHITE, COLORLESS }

    struct CardInfo {
        uint256 id;
        string name;
        CardType cardType;
        Color color;
        uint256 attributes; // Packed attributes: colorlessCost (8 bits) | colorCost (8 bits) | power (8 bits) | toughness (8 bits) | speed (8 bits) | agility (8 bits)
    }

    mapping(Color => mapping(CardType => uint256)) public cardTypeQtyByColor;
    mapping(uint256 => CardInfo) public cardById;
    mapping(uint256 => uint256) public maxSupplyByCard;
    mapping(uint256 => uint256) public currentSupplyByCard;

    Counters.Counter private _cardIdCounter;

    event CardTypeQtyByColorUpdated(Color indexed _color, CardType indexed _cardType, uint256 _qty);
    event CardCreated(uint256 indexed id, Color indexed color, CardType indexed cardType, string name);

    constructor() ERC1155("https://kodr.pro/aa/item/{id}.json") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GUIDE_MASTER_ROLE, msg.sender);
        _setupRole(PACK_MASTER_ROLE, msg.sender);
        _initializeCardTypeQty();
    }

    function _initializeCardTypeQty() private {
        // Initialize cardTypeQtyByColor here (omitted for brevity)
    }

    function setMaxCardSupply(uint256 _id, uint256 _maxSupply) external onlyRole(GUIDE_MASTER_ROLE) {
        maxSupplyByCard[_id] = _maxSupply;
    }

    function createCard(
        string memory _name,
        CardType _cardType,
        Color _color,
        uint8 _colorlessCost,
        uint8 _colorCost,
        uint8 _power,
        uint8 _toughness,
        uint8 _speed,
        uint8 _agility
    ) external onlyRole(GUIDE_MASTER_ROLE) {
        require(cardTypeQtyByColor[_color][_cardType] > 0, "No more cards of this type can be created");

        uint256 newId = _cardIdCounter.current();
        _cardIdCounter.increment();

        uint256 attributes = uint256(_colorlessCost) |
                             (uint256(_colorCost) << 8) |
                             (uint256(_power) << 16) |
                             (uint256(_toughness) << 24) |
                             (uint256(_speed) << 32) |
                             (uint256(_agility) << 40);

        cardById[newId] = CardInfo({
            id: newId,
            name: _name,
            cardType: _cardType,
            color: _color,
            attributes: attributes
        });

        cardTypeQtyByColor[_color][_cardType]--;
        emit CardCreated(newId, _color, _cardType, _name);
    }

    function mint(address _to, uint256 _id, uint256 _quantity, bytes memory _data) public onlyRole(GUIDE_MASTER_ROLE) {
        _mintWithSupplyCheck(_to, _id, _quantity, _data);
    }

    function packMint(address _to, uint256 _id, uint256 _quantity, bytes memory _data) external onlyRole(PACK_MASTER_ROLE) {
        _mintWithSupplyCheck(_to, _id, _quantity, _data);
    }

    function deckMint(address _to, uint256[] memory _ids, bytes memory _data) external onlyRole(PACK_MASTER_ROLE) {
        uint256[] memory _quantities = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            require(currentSupplyByCard[_ids[i]] < maxSupplyByCard[_ids[i]], "Max supply reached");
            currentSupplyByCard[_ids[i]]++;
            _quantities[i] = 1;
        }
        _mintBatch(_to, _ids, _quantities, _data);
    }

    function _mintWithSupplyCheck(address _to, uint256 _id, uint256 _quantity, bytes memory _data) private {
        require(currentSupplyByCard[_id] + _quantity <= maxSupplyByCard[_id], "Max supply reached");
        currentSupplyByCard[_id] += _quantity;
        _mint(_to, _id, _quantity, _data);
    }

    function updateCardTypeQtyByColor(Color _color, CardType _cardType, uint256 _qty) external onlyRole(GUIDE_MASTER_ROLE) {
        cardTypeQtyByColor[_color][_cardType] = _qty;
        emit CardTypeQtyByColorUpdated(_color, _cardType, _qty);
    }

    function getIdsByColorAndCardType(Color _color, CardType _cardType) external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](cardTypeQtyByColor[_color][_cardType]);
        uint256 index = 0;
        for (uint256 i = 0; i < _cardIdCounter.current(); i++) {
            if (cardById[i].color == _color && cardById[i].cardType == _cardType) {
                ids[index] = cardById[i].id;
                index++;
            }
        }
        return ids;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
