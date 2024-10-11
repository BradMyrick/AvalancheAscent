# Card Contract

The `Card` contract is an ERC1155 token contract that represents the cards in the Avalanche Ascent game. It manages the creation, minting, and attributes of all game cards.

## Enums

### CardType

Represents the different types of cards in the game:

- `GUIDE`: Guide card, if it dies, the player's progress is halted.
- `CLIMBER`: Climber card, used to attack the guide.
- `GEAR`: Gear card, represents enchantments.
- `ACTION`: Action card, represents instants.
- `PLAN`: Plan card, can increase ascension rate.
- `TOOL`: Tool card, represents artifacts.
- `CAMP`: Camp card, can be tapped to pay cast cost.
- `EMERGENCY`: Emergency card, interrupts that halt progress.
- `RESCUE`: Rescue card, counters emergency or provides guide protection.

### Color

Represents the color pie of the game:

- `RED`: Red color.
- `GREEN`: Green color.
- `BLUE`: Blue color.
- `BLACK`: Black color.
- `WHITE`: White color.
- `COLORLESS`: Colorless.

## State Variables

- `guideMaster`: Address of the Guide Master, who has special permissions.
- `packMaster`: Address of the Pack Master, who has special permissions for pack-related functions.
- `CardTypeQtyByColor`: Mapping that stores the quantity of each card type for each color.
- `CardByID`: Mapping that stores the card information for each card ID.
- `MaxSupplyByCard`: Mapping that stores the maximum supply for each card ID.
- `CurrentSupplyByCard`: Mapping that stores the current supply for each card ID.

## Modifiers

- `onlyGuideMaster`: Modifier that restricts access to functions only to the Guide Master.
- `onlyPackMaster`: Modifier that restricts access to functions only to the Pack Master.

## Structs

### CardInfo

Represents the information for a card:

- `id`: The unique ID of the card.
- `name`: The name of the card.
- `cardType`: The type of the card.
- `color`: The color of the card.
- `colorlessCost`: The colorless cost of the card.
- `colorCost`: The color cost of the card.
- `power`: The attack power of the card.
- `toughness`: The defense toughness of the card.
- `speed`: The movement rate of the card.
- `agility`: The dodge and obstacle avoidance of the card.

## Functions

### constructor

The constructor function initializes the `Card` contract and sets the initial quantities for each card type and color.

### setMaxCardSupply

Allows the Guide Master to set the maximum supply for a specific card ID.

```solidity
function setMaxCardSupply(uint256 _id, uint256 _maxSupply) external onlyGuideMaster
```

### createCard

Allows the Guide Master to create a new card with the specified attributes.

```solidity
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
) external onlyGuideMaster
```

### mint

Allows the Guide Master to mint a specific quantity of a card to an address.

```solidity
function mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
) public onlyGuideMaster
```

### packMint

Allows the Pack Master to mint a specific quantity of a card to an address.

```solidity
function packMint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
) external onlyPackMaster
```

### deckMint

Allows the Pack Master to mint a deck of cards to an address.

```solidity
function deckMint(
    address _to,
    uint256[] memory _ids,
    bytes memory _data
) external onlyPackMaster
```

### uri

Overrides the base URI for token metadata.

```solidity
function uri(uint256 _id) public view override returns (string memory)
```

### updateCardTypeQtyByColor

Allows the Guide Master to update the quantity of a specific card type and color.

```solidity
function updateCardTypeQtyByColor(
    Color _color,
    CardType _cardType,
    uint256 _qty
) external onlyGuideMaster
```

### getIdsByColorAndCardType

Returns an array of card IDs for a specific color and card type.

```solidity
function getIdsByColorAndCardType(
    Color _color,
    CardType _cardType
) external view returns (uint256[] memory)
```

### setPackMaster

Allows the Guide Master to set the Pack Master address.

```solidity
function setPackMaster(address _packMaster) external onlyGuideMaster
```

## Events

- `CardTypeQtyByColorUpdated`: Emitted when the quantity of a card type and color is updated.
- `CardCreated`: Emitted when a new card is created.
