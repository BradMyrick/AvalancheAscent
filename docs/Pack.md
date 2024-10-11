# Pack Contract

The `PackContract` manages the creation and sale of card packs and pre-built decks for the Avalanche Ascent game. It interacts with the `Card` contract to mint cards and distribute them to players.

## Constants

- `CARDS_IN_PACK`: 10 (Number of cards in a booster pack)
- `CARDS_IN_DECK`: 60 (Number of cards in a pre-built deck)
- `PACK_PRICE`: 0.25 ether (Initial price for a booster pack)
- `DECK_PRICE`: 1 ether (Initial price for a pre-built deck)

## Enums

### PackType

Represents the different types of booster packs:

- `RED`
- `GREEN`
- `BLUE`
- `BLACK`
- `WHITE`

### DeckType

Represents the different types of pre-built decks:

- `REDGREEN`
- `BLUEWHITE`
- `BLACKBLUE`
- `GreenBlack`
- `WhiteRed`

## State Variables

- `cardContract`: Instance of the `Card` contract
- `packMaster`: Address of the Pack Master who has special permissions
- `deckTypeToColorType`: Mapping of `DeckType` to an array of `PackType` (colors)

## Modifiers

- `onlyPackMaster`: Restricts function access to the Pack Master

## Constructor

```solidity
constructor(address _cardContract)
```

Initializes the contract with the address of the `Card` contract and sets the `packMaster` to the contract deployer.

## Functions

### buyBoosterPack

```solidity
function buyBoosterPack(PackType packType) public payable
```

Allows a user to purchase a booster pack of the specified type. Requires the correct payment amount.

### buyPreBuiltDeck

```solidity
function buyPreBuiltDeck(DeckType deckType) public payable
```

Allows a user to purchase a pre-built deck of the specified type. Requires the correct payment amount.

### _getRandomCardId

```solidity
function _getRandomCardId(uint256[] memory cardIds) private view returns (uint256)
```

Internal function to select a random card ID from the provided array. Uses a basic randomness mechanism (TODO: improve randomness).

### withdraw

```solidity
function withdraw() public onlyPackMaster
```

Allows the Pack Master to withdraw the contract's balance.

### setPackPrice

```solidity
function setPackPrice(uint256 _packPrice) public onlyPackMaster
```

Allows the Pack Master to set a new price for booster packs.

### setDeckPrice

```solidity
function setDeckPrice(uint256 _deckPrice) public onlyPackMaster
```

Allows the Pack Master to set a new price for pre-built decks.

### setPackMaster

```solidity
function setPackMaster(address _packMaster) public onlyPackMaster
```

Allows the current Pack Master to transfer their role to a new address.

### setCardContract

```solidity
function setCardContract(address _cardContract) public onlyPackMaster
```

Allows the Pack Master to update the address of the `Card` contract.

### getPackPrice

```solidity
function getPackPrice() public view returns (uint256)
```

Returns the current price of a booster pack.

### getDeckPrice

```solidity
function getDeckPrice() public view returns (uint256)
```

Returns the current price of a pre-built deck.

## TODO

1. **Improve Randomness**: 
   - Replace the current randomness generation in `_getRandomCardId` with a more secure method, such as Chainlink VRF.
   - Ensure fair and unpredictable card distribution in packs and decks.

2. **Pack Contents Balancing**:
   - Implement logic to ensure a balanced distribution of card types and rarities within packs and decks.
   - Consider adding different pack types with varying probabilities for rare cards.

3. **Dynamic Pricing**:
   - Implement a dynamic pricing mechanism based on supply and demand.
   - Consider integrating with an oracle for price feeds.

4. **Event Logging**:
   - Add events for important actions like pack purchases, deck purchases, and price changes.
   - This will facilitate off-chain tracking and provide a better user experience.

5. **Access Control**:
   - Consider using OpenZeppelin's `AccessControl` for more granular permission management.
   - Implement roles for different administrative functions.

6. **Pack Opening Mechanism**:
   - Implement a separate function for "opening" packs to reveal cards.
   - This could add an element of excitement and allow for future animations or reveals in the frontend.

7. **Inventory Management**:
   - Implement a system to track available packs and decks.
   - Add functionality to create new pack types or deck types dynamically.

8. **Integration with Marketplace**:
   - Consider how this contract will interact with a future marketplace for trading cards.
   - Implement functions to support secondary market dynamics.

9. **Gas Optimization**:
   - Review and optimize functions for gas efficiency, especially in loops and array operations.

10. **Security Audit**:
    - Conduct a thorough security audit of the contract, paying special attention to randomness generation and fund handling.
