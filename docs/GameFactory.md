# GameFactory Contract

The `GameFactory` contract is responsible for creating and managing game instances in the Avalanche Ascent game. It acts as a factory for creating new `Game` contracts and keeps track of all created games.

## State Variables

- `games`: An array of `Game` contract instances, storing all created games.

## Events

### GameCreated

```solidity
event GameCreated(address gameAddress, uint256 gameIndex)
```

Emitted when a new game is created. It includes:
- `gameAddress`: The address of the newly created `Game` contract.
- `gameIndex`: The index of the new game in the `games` array.

## Functions

### createGame

```solidity
function createGame(address[] memory _players) public
```

Creates a new `Game` instance and adds it to the `games` array.

Parameters:
- `_players`: An array of player addresses to be included in the new game.

Functionality:
1. Creates a new `Game` contract instance, passing the `_players` array to its constructor.
2. Adds the new `Game` instance to the `games` array.
3. Emits a `GameCreated` event with the address of the new game contract and its index in the `games` array.

## Usage

The `GameFactory` contract serves as the entry point for creating new games in Avalanche Ascent. When players want to start a new game, they interact with this contract to create a game instance. The factory keeps track of all created games, allowing for easy management and retrieval of game information.

## TODO

1. **Access Control**: Currently, anyone can create a game. Implement access control mechanisms if I want to restrict game creation to certain addresses or roles.

2. **Game Parameters**: The current implementation only takes player addresses as input. Add more parameters (e.g., game settings, mountain top position) to allow for more customizable game creation.

3. **Game Tracking**: While the contract stores all created games, it doesn't provide functions to query or manage these games. Add functions to:
   - Get the total number of games
   - Retrieve game addresses by index
   - Check if a game exists

4. **Gas Optimization**: Creating new contract instances can be gas-intensive. For a high-volume application, Implement a game pool or use upgradeable proxy patterns to reduce gas costs.

5. **Event Indexing**: The `GameCreated` event could benefit from indexing the `gameAddress` for more efficient off-chain filtering and querying.

6. **Error Handling**: Add require statements to handle potential errors, such as an empty `_players` array or exceeding a maximum number of players.
