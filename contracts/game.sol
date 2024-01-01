// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./card.sol";

contract Game {
    Card public cardContract;

    enum GameState {
        SETUP,
        PLAY,
        END
    }

    struct Player {
        address playerAddress;
        uint256 position;
        bool isActive;
        uint256[] cardIds; // Array to store player's card IDs
    }

    struct GameInfo {
        GameState state;
        Player[] players;
        uint256 currentPlayerIndex;
        uint256 mountainTop; // The position a player must reach to win
    }

    GameInfo[] public games;

    event GameCreated(uint256 indexed gameIndex);
    event PlayerMoved(address indexed playerAddress, uint256 newPosition);
    event GameEnded(address indexed winner);

    constructor(address _cardContractAddress) {
        cardContract = Card(_cardContractAddress);
    }

    function createGame(address[] memory _players, uint256 _mountainTop) public {
        Player[] memory players = new Player[](_players.length);
        for (uint256 i = 0; i < _players.length; i++) {
            players[i] = Player({
                playerAddress: _players[i],
                position: 0,
                isActive: true,
                cardIds: new uint256[](0)
            });
        }
        games.push(GameInfo({
            state: GameState.SETUP,
            players: players,
            currentPlayerIndex: 0,
            mountainTop: _mountainTop
        }));
        emit GameCreated(games.length - 1);
    }

    function playCard(uint256 _gameIndex, uint256 _cardId) public {
        //TODO: Logic to play a card
    }

    function makeMove(uint256 _gameIndex) public {
        GameInfo storage game = games[_gameIndex];
        require(game.state == GameState.PLAY, "GameInfo is not in play state");
        Player storage currentPlayer = game.players[game.currentPlayerIndex];
        require(currentPlayer.playerAddress == msg.sender, "It's not your turn");
        require(currentPlayer.isActive, "You are not active in this game");

        // TODO: Logic to make a move, e.g., draw a card, play a card, etc.

        // Check if the player has reached the mountain top
        if (currentPlayer.position >= game.mountainTop) {
            game.state = GameState.END;
            emit GameEnded(msg.sender);
        } else {
            game.currentPlayerIndex = (game.currentPlayerIndex + 1) % game.players.length;
        }
    }

    function getPlayerCards(uint256 _gameIndex, address _playerAddress) public view returns (uint256[] memory) {
        uint256 gameIndex = playerGameIndex[_playerAddress];
        GameInfo storage game = games[gameIndex];
        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.players[i].playerAddress == _playerAddress) {
                return game.players[i].cardIds;
            }
        }
        revert("Player not found");
    }
}
