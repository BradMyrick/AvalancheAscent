// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./game.sol";

contract GameFactory is Ownable, ReentrancyGuard {
    Game[] public games;
    address public immutable cardContractAddress;
    uint256 public constant MIN_PLAYERS = 2;
    uint256 public constant MAX_PLAYERS = 4;
    uint256 public constant DEFAULT_MOUNTAIN_TOP = 100;

    event GameCreated(address indexed gameAddress, uint256 indexed gameIndex, address[] players);

    constructor(address _cardContractAddress) {
        cardContractAddress = _cardContractAddress;
    }

    function createGame(address[] memory _players) external nonReentrant {
        require(_players.length >= MIN_PLAYERS && _players.length <= MAX_PLAYERS, "Invalid number of players");
        
        for (uint256 i = 0; i < _players.length; i++) {
            require(_players[i] != address(0), "Invalid player address");
        }

        Game newGame = new Game(cardContractAddress);
        newGame.createGame(_players, DEFAULT_MOUNTAIN_TOP);
        games.push(newGame);

        emit GameCreated(address(newGame), games.length - 1, _players);
    }

    function getGameAddress(uint256 _gameIndex) external view returns (address) {
        require(_gameIndex < games.length, "Game does not exist");
        return address(games[_gameIndex]);
    }

    function getGamesCount() external view returns (uint256) {
        return games.length;
    }

    function getActiveGames() external view returns (address[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < games.length; i++) {
            if (games[i].getGameState() == Game.GameState.PLAY) {
                activeCount++;
            }
        }

        address[] memory activeGames = new address[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < games.length; i++) {
            if (games[i].getGameState() == Game.GameState.PLAY) {
                activeGames[index] = address(games[i]);
                index++;
            }
        }

        return activeGames;
    }

    function removeGame(uint256 _gameIndex) external onlyOwner {
        require(_gameIndex < games.length, "Game does not exist");
        games[_gameIndex] = games[games.length - 1];
        games.pop();
    }
}
