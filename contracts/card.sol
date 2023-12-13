// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// everyone starts with a Guide in play but don't start moving until they have a Climber

contract Card is ERC1155 {

    enum CardType {
                    GUIDE,  // Guide, if it dies you halt progress
                    CLIMBER, // attack the guide
                    GEAR, // Enchantments
                    ACTION, // Instants
                    PLAN, // Can increase ascention rate
                    TOOL, // Artifacts
                    REST_STOP, // tap to pay cast cost
                    EMERGENCY, // Interrupts that halt progress
                    RESCUE // Counter Emergency or provide guide protection
                    } 

    // color pie
    enum Color {
                    RED, 
                    GREEN,
                    BLUE,
                    BLACK, 
                    WHITE,
                    COLORLESS 
                }

    // SetList
    struct SetList {
        Guide[] guide;
        Climber[] climber;
        Gear[] gear;
        Action[] action;
        Plan[] plan;
        Tool[] tool;
        Emergency[] emergency;
        Rescue[] rescue;        
    }

    // Guide Master
    address public guideMaster;

    // only guideMaster modifier
    modifier onlyGuideMaster() {
        require(msg.sender == guideMaster, "Only the Guide Master can call this function");
        _;
    }

    mapping(Color => mapping (CardType => SetList)) public ColorSet;
    constructor() ERC1155("https://kodr.pro/aa/item/") {
        guideMaster = msg.sender;

            // set the setlists for each color [wip]
        ColorSet[Color.RED][CardType.GUIDE] = SetList(Guide[](5));
        ColorSet[Color.RED][CardType.CLIMBER] = SetList(Climber[](45));
        ColorSet[Color.RED][CardType.GEAR] = SetList(Gear[](30));
        ColorSet[Color.RED][CardType.ACTION] = SetList(Action[](35));
        ColorSet[Color.RED][CardType.PLAN] = SetList(Plan[](25));
        ColorSet[Color.RED][CardType.TOOL] = SetList(Tool[](20));
        ColorSet[Color.RED][CardType.EMERGENCY] = SetList(Emergency[](15));
        ColorSet[Color.RED][CardType.RESCUE] = SetList(Rescue[](10));

        ColorSet[Color.GREEN][CardType.GUIDE] = SetList(Guide[](5));
        ColorSet[Color.GREEN][CardType.CLIMBER] = SetList(Climber[](50));
        ColorSet[Color.GREEN][CardType.GEAR] = SetList(Gear[](30));
        ColorSet[Color.GREEN][CardType.ACTION] = SetList(Action[](30));
        ColorSet[Color.GREEN][CardType.PLAN] = SetList(Plan[](25));
        ColorSet[Color.GREEN][CardType.TOOL] = SetList(Tool[](20));
        ColorSet[Color.GREEN][CardType.EMERGENCY] = SetList(Emergency[](10));
        ColorSet[Color.GREEN][CardType.RESCUE] = SetList(Rescue[](15));

        ColorSet[Color.BLUE][CardType.GUIDE] = SetList(Guide[](5));
        ColorSet[Color.BLUE][CardType.CLIMBER] = SetList(Climber[](40));
        ColorSet[Color.BLUE][CardType.GEAR] = SetList(Gear[](30));
        ColorSet[Color.BLUE][CardType.ACTION] = SetList(Action[](40));
        ColorSet[Color.BLUE][CardType.PLAN] = SetList(Plan[](30));
        ColorSet[Color.BLUE][CardType.TOOL] = SetList(Tool[](20));
        ColorSet[Color.BLUE][CardType.EMERGENCY] = SetList(Emergency[](10));
        ColorSet[Color.BLUE][CardType.RESCUE] = SetList(Rescue[](10));

        ColorSet[Color.BLACK][CardType.GUIDE] = SetList(Guide[](5));
        ColorSet[Color.BLACK][CardType.CLIMBER] = SetList(Climber[](45));
        ColorSet[Color.BLACK][CardType.GEAR] = SetList(Gear[](30));
        ColorSet[Color.BLACK][CardType.ACTION] = SetList(Action[](35));
        ColorSet[Color.BLACK][CardType.PLAN] = SetList(Plan[](25));
        ColorSet[Color.BLACK][CardType.TOOL] = SetList(Tool[](20));
        ColorSet[Color.BLACK][CardType.EMERGENCY] = SetList(Emergency[](15));
        ColorSet[Color.BLACK][CardType.RESCUE] = SetList(Rescue[](10));

        ColorSet[Color.WHITE][CardType.GUIDE] = SetList(Guide[](5));
        ColorSet[Color.WHITE][CardType.CLIMBER] = SetList(Climber[](50));
        ColorSet[Color.WHITE][CardType.GEAR] = SetList(Gear[](30));
        ColorSet[Color.WHITE][CardType.ACTION] = SetList(Action[](30));
        ColorSet[Color.WHITE][CardType.PLAN] = SetList(Plan[](25));
        ColorSet[Color.WHITE][CardType.TOOL] = SetList(Tool[](20));
        ColorSet[Color.WHITE][CardType.EMERGENCY] = SetList(Emergency[](10));
        ColorSet[Color.WHITE][CardType.RESCUE] = SetList(Rescue[](15));

        ColorSet[Color.COLORLESS][CardType.GEAR] = SetList(Gear[](40));
        ColorSet[Color.COLORLESS][CardType.ACTION] = SetList(Action[](30));
        ColorSet[Color.COLORLESS][CardType.PLAN] = SetList(Plan[](20));
        ColorSet[Color.COLORLESS][CardType.TOOL] = SetList(Tool[](10));

    }

    // only guidemaster mint to send all cards to the marketplace
    function mintColorSet(Color _color, CardType _cardType) public onlyGuideMaster {
        //WIP
        
    }

    // create a blank deck with 65 cards, 60 playable and 5 in reserve
    function _createBlankDeck() public {
        createCard(GUIDE, 1); 
        createCard(CLIMBER, 15);             
        createCard(CAMP, 20); 
        createCard(GEAR, 8); 
        createCard(ACTION, 5);
        createCard(PLAN, 7); 
        createCard(TOOL, 5); 
        createCard(EMERGENCY, 2);
        createCard(RESCUE, 1);
    }

    // uri override
    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_id), ".json"));
    }

}
