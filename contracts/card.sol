// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// everyone starts with a Guide in play but don't start moving until they have a Climber

contract CardContract is ERC1155 {
    enum CardType {
        GUIDE, // Guide, if it dies you halt progress; itoa
        CLIMBER, // attack the guide
        GEAR, // Enchantments
        ACTION, // Instants
        PLAN, // Can increase ascention rate
        TOOL, // Artifacts
        CAMP, // tap to pay cast cost
        EMERGENCY, // Interrupts that halt progress
        RESCUE // Counter Emergency or provide guide protection
    }

    // color pie
    enum Color {
        RED, // iota
        GREEN,
        BLUE,
        BLACK,
        WHITE,
        COLORLESS
    }

    // Guide Master
    address public guideMaster;
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

    // mappings
    mapping(Color => mapping(CardType => uint256)) public CardTypeQtyByColor;

    mapping(uint256 => Card) public CardByID;

    mapping(uint256 => uint256) public MaxSupplyByCard;

    mapping(uint256 => uint256) public CurrentSupplyByCard;

    // only guideMaster modifier
    modifier onlyGuideMaster() {
        require(
            msg.sender == guideMaster,
            "Only the Guide Master can call this function"
        );
        _;
    }

    // structs
    struct Card {
        uint256 id;
        string name;
        CardType cardType;
        Color color;
        uint256 colorlessCost;
        uint256 colorCost;
        uint256 power; // attack
        uint256 toughness; // defense
        uint256 speed; // movement rate
        uint256 agility; // dodge, obstacle avoidance
    }

    constructor() ERC1155("https://kodr.pro/aa/item/") {
        guideMaster = msg.sender;

        // set the setlists for each color [wip]
        // these are different types of cards that can be minted
        // not total qty of cards that can be minted
        CardTypeQtyByColor[Color.RED][CardType.GUIDE] = 5;
        CardTypeQtyByColor[Color.RED][CardType.CLIMBER] = 50;
        CardTypeQtyByColor[Color.RED][CardType.GEAR] = 30;
        CardTypeQtyByColor[Color.RED][CardType.ACTION] = 30;
        CardTypeQtyByColor[Color.RED][CardType.PLAN] = 20;
        CardTypeQtyByColor[Color.RED][CardType.TOOL] = 25;
        CardTypeQtyByColor[Color.RED][CardType.CAMP] = 4;
        CardTypeQtyByColor[Color.RED][CardType.EMERGENCY] = 15;
        CardTypeQtyByColor[Color.RED][CardType.RESCUE] = 10;

        CardTypeQtyByColor[Color.GREEN][CardType.GUIDE] = 5;
        CardTypeQtyByColor[Color.GREEN][CardType.CLIMBER] = 50;
        CardTypeQtyByColor[Color.GREEN][CardType.GEAR] = 30;
        CardTypeQtyByColor[Color.GREEN][CardType.ACTION] = 30;
        CardTypeQtyByColor[Color.GREEN][CardType.PLAN] = 25;
        CardTypeQtyByColor[Color.GREEN][CardType.TOOL] = 20;
        CardTypeQtyByColor[Color.GREEN][CardType.CAMP] = 4;
        CardTypeQtyByColor[Color.GREEN][CardType.EMERGENCY] = 10;
        CardTypeQtyByColor[Color.GREEN][CardType.RESCUE] = 15;

        CardTypeQtyByColor[Color.BLUE][CardType.GUIDE] = 5;
        CardTypeQtyByColor[Color.BLUE][CardType.CLIMBER] = 40;
        CardTypeQtyByColor[Color.BLUE][CardType.GEAR] = 30;
        CardTypeQtyByColor[Color.BLUE][CardType.ACTION] = 40;
        CardTypeQtyByColor[Color.BLUE][CardType.PLAN] = 30;
        CardTypeQtyByColor[Color.BLUE][CardType.TOOL] = 20;
        CardTypeQtyByColor[Color.BLUE][CardType.CAMP] = 4;
        CardTypeQtyByColor[Color.BLUE][CardType.EMERGENCY] = 10;
        CardTypeQtyByColor[Color.BLUE][CardType.RESCUE] = 10;

        CardTypeQtyByColor[Color.BLACK][CardType.GUIDE] = 5;
        CardTypeQtyByColor[Color.BLACK][CardType.CLIMBER] = 45;
        CardTypeQtyByColor[Color.BLACK][CardType.GEAR] = 30;
        CardTypeQtyByColor[Color.BLACK][CardType.ACTION] = 35;
        CardTypeQtyByColor[Color.BLACK][CardType.PLAN] = 25;
        CardTypeQtyByColor[Color.BLACK][CardType.TOOL] = 20;
        CardTypeQtyByColor[Color.BLACK][CardType.CAMP] = 4;
        CardTypeQtyByColor[Color.BLACK][CardType.EMERGENCY] = 15;
        CardTypeQtyByColor[Color.BLACK][CardType.RESCUE] = 10;

        CardTypeQtyByColor[Color.WHITE][CardType.GUIDE] = 5;
        CardTypeQtyByColor[Color.WHITE][CardType.CLIMBER] = 50;
        CardTypeQtyByColor[Color.WHITE][CardType.GEAR] = 30;
        CardTypeQtyByColor[Color.WHITE][CardType.ACTION] = 30;
        CardTypeQtyByColor[Color.WHITE][CardType.PLAN] = 25;
        CardTypeQtyByColor[Color.WHITE][CardType.TOOL] = 20;
        CardTypeQtyByColor[Color.WHITE][CardType.CAMP] = 4;
        CardTypeQtyByColor[Color.WHITE][CardType.EMERGENCY] = 10;
        CardTypeQtyByColor[Color.WHITE][CardType.RESCUE] = 15;

        CardTypeQtyByColor[Color.COLORLESS][CardType.GEAR] = 40;
        CardTypeQtyByColor[Color.COLORLESS][CardType.ACTION] = 30;
        CardTypeQtyByColor[Color.COLORLESS][CardType.PLAN] = 20;
        CardTypeQtyByColor[Color.COLORLESS][CardType.TOOL] = 10;
    }

    function setMaxCardSupply(
        uint256 _id,
        uint256 _maxSupply
    ) external onlyGuideMaster {
        MaxSupplyByCard[_id] = _maxSupply;
    }

    uint256 private redIndex = 0;
    uint256 private greenIndex = 0;
    uint256 private blueIndex = 0;
    uint256 private blackIndex = 0;
    uint256 private whiteIndex = 0;
    uint256 private colorlessIndex = 0;

    function createCard(
        string memory _name,
        CardType _cardType,
        Color _color,
        uint256 _colorlessCost,
        uint256 _colorCost,
        uint256 _power,
        uint256 _toughness,
        uint256 _speed,
        uint256 _agility
    ) external onlyGuideMaster {
        require(
            CardTypeQtyByColor[_color][_cardType] > 0,
            "No more cards of this type can be created"
        );

        uint256 newId = uint256(_color) +
            uint256(_cardType) +
            CardTypeQtyByColor[_color][_cardType];


        Card memory newCard = Card({
            id: newId,
            name: _name,
            cardType: _cardType,
            color: _color,
            colorlessCost: _colorlessCost,
            colorCost: _colorCost,
            power: _power,
            toughness: _toughness,
            speed: _speed,
            agility: _agility
            });

        CardTypeQtyByColor[_color][_cardType] -= 1;
        CardByID[newId] = newCard;
    }

    // mint
    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public onlyGuideMaster {
        require(
            CurrentSupplyByCard[_id] + _quantity <= MaxSupplyByCard[_id],
            "Max supply reached"
        );
        CurrentSupplyByCard[_id] += _quantity;
        _mint(_to, _id, _quantity, _data);
    }

    // pack mint
    function packMint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) external onlyPackMaster {
        require(
            CurrentSupplyByCard[_id] + _quantity <= MaxSupplyByCard[_id],
            "Max supply reached"
        );
        CurrentSupplyByCard[_id] += _quantity;
        _mint(_to, _id, _quantity, _data);
    }

    // deck mint
    function deckMint(
        address _to,
        uint256[] memory _ids,
        bytes memory _data
    ) external onlyPackMaster {
        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                CurrentSupplyByCard[_ids[i]] + 1 <= MaxSupplyByCard[_ids[i]],
                "Max supply reached"
            );
            CurrentSupplyByCard[_ids[i]] += 1;
        }
        uint256[] memory _quantity = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            _quantity[i] = 1;
        }
        // if I have to make a set of the id's then I'll have to calculate the quantity
        _mintBatch(_to, _ids, _quantity, _data);
    }

    // uri override
    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_id), ".json"));
    }

    function updateCardTypeQtyByColor(
        Color _color,
        CardType _cardType,
        uint256 _qty
    ) external onlyGuideMaster {
        CardTypeQtyByColor[_color][_cardType] = _qty;
        emit CardTypeQtyByColorUpdated(_color, _cardType, _qty);
    }

    function getIdsByColorAndCardType(
        Color _color,
        CardType _cardType
    ) external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](
            CardTypeQtyByColor[_color][_cardType]
        );
        uint256 index = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            if (CardByID[i].color == _color && CardByID[i].cardType == _cardType) {
                ids[index] = CardByID[i].id;
                index++;
            }
        }
        return ids;
    }

    function setPackMaster(address _packMaster) external onlyGuideMaster {
        packMaster = _packMaster;
    }

    // events
    event CardTypeQtyByColorUpdated(
        Color _color,
        CardType _cardType,
        uint256 _qty
    );

    event CardCreated(
        Color color,
        CardType cardType,
        uint256 cardIndex,
        string name
    );
}
