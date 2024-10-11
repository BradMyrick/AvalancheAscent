# Game Contract

The `Game` contract manages the game state, player actions, and win conditions for the Avalanche Ascent game. It interacts with the `Card` contract to handle player cards and game mechanics.

## State Variables

- `cardContract`: Instance of the `Card` contract.

## Enums

### GameState

Represents the different states of a game:

- `SETUP`: The game is being set up.
- `PLAY`: The game is in progress.
- `END`: The game has ended.

## Structs

### Player

Represents a player in the game:

- `playerAddress`: The address of the player.
- `position`: The current position of the player.
- `isActive`: Indicates whether the player is active in the game.
- `cardIds`: An array to store the player's card IDs.

### GameInfo

Represents the information about a game:

- `state`: The current state of the game.
- `players`: An array of `Player` structs representing the players in the game.
- `currentPlayerIndex`: The index of the current player.
- `mountainTop`: The position a player must reach to win the game.

## Events

- `GameCreated`: Emitted when a new game is created, includes the game index.
- `PlayerMoved`: Emitted when a player moves, includes the player's address and new position.
- `GameEnded`: Emitted when the game ends, includes the winner's address.

## Constructor

```solidity
constructor(address _cardContractAddress)
```

The constructor function initializes the `Game` contract by setting the `cardContract` instance using the provided `_cardContractAddress`.

## Functions

### createGame

```solidity
function createGame(address[] memory _players, uint256 _mountainTop) public
```

Creates a new game with the specified `_players` addresses and `_mountainTop` position. It initializes the game state, player positions, and emits the `GameCreated` event.

### playCard

```solidity
function playCard(uint256 _gameIndex, uint256 _cardId) public
```

Allows a player to play a card in the specified game. The logic for playing a card is not yet implemented (TODO).

### makeMove

```solidity
function makeMove(uint256 _gameIndex) public
```

Allows the current player to make a move in the specified game. The function checks if the game is in the `PLAY` state, if it's the player's turn, and if the player is active. The logic for making a move is not yet fully implemented (TODO).

If the player reaches the `mountainTop` position, the game ends and the `GameEnded` event is emitted. Otherwise, the turn is passed to the next player.

### getPlayerCards

```solidity
function getPlayerCards(uint256 _gameIndex, address _playerAddress) public view returns (uint256[] memory)
```

Retrieves the card IDs of a specific player in the specified game. It searches for the player in the game's `players` array and returns their `cardIds`. If the player is not found, it reverts with an error message.

Note: The `getPlayerCards` function uses a `playerGameIndex` mapping that is not defined in the provided code snippet. It seems to be missing or defined elsewhere.

## TODO

- Implement the logic for playing a card in the `playCard` function.
- Complete the logic for making a move in the `makeMove` function, including drawing a card, playing a card, and updating the game state accordingly.
- Define and implement the `playerGameIndex` mapping used in the `getPlayerCards` function.
