# Avalanche Ascent

## Overview

Avalanche Ascent is an innovative blockchain-based Trading Card Game (TCG) built on the Avalanche platform. It combines the excitement of mountain climbing with the strategic depth of collectible card games, all powered by blockchain technology for true ownership and secure trading of digital assets.

## Game Concept

In Avalanche Ascent, players take on the role of mountain expedition leaders, competing to be the first to reach the summit. Each player uses a deck of cards representing climbers, gear, actions, and strategies to overcome challenges and outmaneuver opponents.

Key features:
- Unique blend of mountain climbing theme and TCG mechanics
- Multiple card types and colors for diverse strategies
- Blockchain-based card ownership and trading
- Competitive gameplay with multiplayer support

## Contract Network

Avalanche Ascent is powered by a network of smart contracts that work together to create a seamless gaming experience:

1. **Card Contract (`card.sol`)**: 
   - Manages the creation, minting, and attributes of all game cards
   - Implements ERC1155 standard for efficient multi-token management

2. **Pack Contract (`pack.sol`)**: 
   - Handles the creation and sale of booster packs and pre-built decks
   - Ensures fair and random card distribution

3. **Game Contract (`game.sol`)**: 
   - Manages game state, player actions, and win conditions
   - Implements core game logic and rules

4. **GameFactory Contract (`gamefactory.sol`)**: 
   - Facilitates the creation of new game instances
   - Manages matchmaking and game initialization

5. **Marketplace Contract (`marketplace.sol`)**: 
   - Enables players to buy, sell, and trade cards
   - Implements secure trading mechanisms and dispute resolution

## Technical Stack

- **Blockchain**: Avalanche
- **Smart Contract Language**: Solidity
- **Token Standards**: ERC1155

## Getting Started

TODO: add instructions for setting up the development environment, deploying contracts, and running tests

## Documentation

Detailed documentation for each contract can be found in their respective markdown files:

- [Card Contract](./docs/Card.md)
- [Pack Contract](./docs/Pack.md)
- [Game Contract](./docs/Game.md)
- [GameFactory Contract](./docs/GameFactory.md)
- [Marketplace Contract](./docs/Marketplace.md)

## Contributing

TODO: Include guidelines for contributing to the project if I make it open-source

## License

TODO: Include license information if I make it open-source, for now it's
UNLICENSED

