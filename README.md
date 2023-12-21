# Real Estate Tokenization Smart Contract

## Overview

The Real Estate Tokenization Smart Contract is a decentralized application (DApp) built on the Ethereum blockchain that enables real estate companies to tokenize properties, allowing users to buy units of these properties as non-fungible tokens (NFTs). These NFTs represent ownership of a portion of the property. The smart contract also handles rental income distribution, unit resale, and token metadata management.

### Features

- **Property Tokenization:** Real estate companies can tokenize their properties, creating NFTs representing ownership.

- **Unit Purchases:** Users can buy units of a property, with each unit represented by an NFT.

- **Rental Income Distribution:** The contract automates rental income collection and distributes it among property owners based on unit ownership.

- **Unit Resale:** Users can list their units for sale on the platform and facilitate the transfer of NFT ownership and payment between the seller and buyer.

- **Token Metadata Management:** Metadata associated with NFTs, including property details and ownership information, can be managed by the contract.

## Getting Started

### Prerequisites

- Install Node.js and npm
- Install Hardhat (Ethereum development environment) and dependencies
- Install a development Ethereum node (e.g., [Hardhat Network](https://hardhat.org/hardhat-network/), [Ganache](https://www.trufflesuite.com/ganache))

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/Onu-Daniel/Brickly-Contracts.git
   ```

2. Navigate to the project directory:

   ```bash
   cd Brickly-Contracts
   ```

3. Install project dependencies:

   ```bash
   npm install
   ```

### Usage

1. Compile the smart contract:

   ```bash
   npx hardhat compile
   ```

## Contract Architecture

The contract is organized into multiple parts, each in a separate Solidity file within the `contracts/` directory:

- `Brickly.sol`:
This is the contract that tokenizes proprties by deploying an NFT which is a new instance of the `Asset` contract.
This contract also allows the owner of a tokenized asset to list the units for sale

- `Asset.sol`:
This is the NFT contract. A new NFT is created each time to represent a unique property.
A property can have different units which is represented with a unique `tokenId`.
