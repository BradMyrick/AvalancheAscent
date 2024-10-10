// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./card.sol";

contract Game is Ownable, ReentrancyGuard {
    Card public immutable cardContract;

    enum GameState { SETUP, PLAY, END }

    struct Player {
        address playerAddress;
        uint256 position;
        bool isActive;
        uint256[] cardIds;
        uint256 energy;
    }

    struct GameInfo {
        GameState state;
        Player[] players;
        uint256 currentPlayerIndex;
        uint256 mountainTop;
        uint256 turnNumber;
        uint256 lastActionTimestamp;
    }

    GameInfo[] public games;
    uint256 public constant MAX_PLAYERS = 4;
    uint256 public constant TURN_TIMEOUT = 5 minutes;
    uint256 public constant INITIAL_ENERGY = 3;
    uint256 public constant MAX_ENERGY = 10;

    event GameCreated(uint256 indexed gameIndex);
    event PlayerMoved(uint256 indexed gameIndex, address indexed playerAddress, uint256 newPosition);
    event CardPlayed(uint256 indexed gameIndex, address indexed playerAddress, uint256 cardId);
    event GameEnded(uint256 indexed gameIndex, address indexed winner);
    event PlayerSkipped(uint256 indexed gameIndex, address indexed playerAddress);

    constructor(address _cardContractAddress) {
        cardContract = Card(_cardContractAddress);
    }

    function createGame(address[] memory _players, uint256 _mountainTop) external {
        require(_players.length >= 2 && _players.length <= MAX_PLAYERS, "Invalid number of players");
        require(_mountainTop > 0, "Invalid mountain top");

        Player[] memory players = new Player[](_players.length);
        for (uint256 i = 0; i < _players.length; i++) {
            players[i] = Player({
                playerAddress: _players[i],
                position: 0,
                isActive: true,
                cardIds: new uint256[](0),
                energy: INITIAL_ENERGY
            });
        }

        games.push(GameInfo({
            state: GameState.SETUP,
            players: players,
            currentPlayerIndex: 0,
            mountainTop: _mountainTop,
            turnNumber: 0,
            lastActionTimestamp: block.timestamp
        }));

        emit GameCreated(games.length - 1);
    }

    function startGame(uint256 _gameIndex) external {
        GameInfo storage game = games[_gameIndex];
        require(game.state == GameState.SETUP, "Game is not in setup state");
        require(msg.sender == game.players[0].playerAddress, "Only the first player can start the game");

        game.state = GameState.PLAY;
        game.lastActionTimestamp = block.timestamp;
    }

    function playCard(uint256 _gameIndex, uint256 _cardId) external nonReentrant {
        GameInfo storage game = games[_gameIndex];
        require(game.state == GameState.PLAY, "Game is not in play state");
        Player storage currentPlayer = game.players[game.currentPlayerIndex];
        require(currentPlayer.playerAddress == msg.sender, "It's not your turn");
        require(currentPlayer.isActive, "You are not active in this game");

        // Check if the player has the card
        bool hasCard = false;
        for (uint256 i = 0; i < currentPlayer.cardIds.length; i++) {
            if (currentPlayer.cardIds[i] == _cardId) {
                hasCard = true;
                break;
            }
        }
        require(hasCard, "You don't have this card");

        // Get card info and check energy cost
        (,,,, uint256 colorlessCost, uint256 colorCost,,,,) = cardContract.CardByID(_cardId);
        uint256 totalCost = colorlessCost + colorCost;
        require(currentPlayer.energy >= totalCost, "Not enough energy to play this card");

        // Deduct energy and apply card effects
        currentPlayer.energy -= totalCost;
        // TODO: Implement card effects based on card type

        emit CardPlayed(_gameIndex, msg.sender, _cardId);
        _endTurn(_gameIndex);
    }

    function makeMove(uint256 _gameIndex) external nonReentrant {
        GameInfo storage game = games[_gameIndex];
        require(game.state == GameState.PLAY, "Game is not in play state");
        Player storage currentPlayer = game.players[game.currentPlayerIndex];
        require(currentPlayer.playerAddress == msg.sender, "It's not your turn");
        require(currentPlayer.isActive, "You are not active in this game");

        // Move the player
        currentPlayer.position += 1;

        emit PlayerMoved(_gameIndex, msg.sender, currentPlayer.position);

        // Check if the player has reached the mountain top
        if (currentPlayer.position >= game.mountainTop) {
            game.state = GameState.END;
            emit GameEnded(_gameIndex, msg.sender);
        } else {
            _endTurn(_gameIndex);
        }
    }

    function skipTurn(uint256 _gameIndex) external {
        GameInfo storage game = games[_gameIndex];
        require(game.state == GameState.PLAY, "Game is not in play state");
        Player storage currentPlayer = game.players[game.currentPlayerIndex];
        require(currentPlayer.playerAddress == msg.sender, "It's not your turn");

        emit PlayerSkipped(_gameIndex, msg.sender);
        _endTurn(_gameIndex);
    }

    function _endTurn(uint256 _gameIndex) private {
        GameInfo storage game = games[_gameIndex];
        game.turnNumber++;
        game.currentPlayerIndex = (game.currentPlayerIndex + 1) % game.players.length;
        game.lastActionTimestamp = block.timestamp;

        // Replenish energy for the next player
        Player storage nextPlayer = game.players[game.currentPlayerIndex];
        nextPlayer.energy = nextPlayer.energy + 1 > MAX_ENERGY ? MAX_ENERGY : nextPlayer.energy + 1;
    }

    function getPlayerCards(uint256 _gameIndex, address _playerAddress) external view returns (uint256[] memory) {
        GameInfo storage game = games[_gameIndex];
        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.players[i].playerAddress == _playerAddress) {
                return game.players[i].cardIds;
            }
        }
        revert("Player not found");
    }

    function getGameState(uint256 _gameIndex) external view returns (GameInfo memory) {
        return games[_gameIndex];
    }

    function forceEndGame(uint256 _gameIndex) external onlyOwner {
        GameInfo storage game = games[_gameIndex];
        require(game.state != GameState.END, "Game has already ended");
        game.state = GameState.END;
        emit GameEnded(_gameIndex, address(0));
    }
}
