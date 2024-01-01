pragma solidity ^0.8.20;

import "./game.sol";

contract GameFactory {
    Game[] public games;

    event GameCreated(address gameAddress, uint256 gameIndex);

    function createGame(address[] memory _players) public {
        Game game = new Game(_players);
        games.push(game);
        emit GameCreated(address(game), games.length - 1);
    }
}
