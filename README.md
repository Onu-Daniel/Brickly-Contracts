# Real Estate Tokenization Smart Contract

## Overview

Brickly, is a decentralized real estate marketplace that leverages blockchain technology, particularly Ethereum and the ERC-721 standard for non-fungible tokens (NFTs).

The Real Estate Tokenization Smart Contract is a decentralized application (DApp) built on the Mode blockchain that enables real estate companies to tokenize properties, allowing users to buy units of these properties as non-fungible tokens (NFTs). These NFTs represent ownership of a portion of the property. The smart contract also handles rental income distribution, unit resale, and token metadata management.

1. Deployed Frontend [dApp](brickly-wheat.vercel.app)
2. Frontend Repo [here](https://github.com/Onu-Daniel/brickly.git)

### Features

- **Property Tokenization:** Real estate companies can tokenize their properties, creating NFTs representing ownership.

- **Unit Purchases:** Users can buy units of a property, with each unit represented by an NFT.

- **Rental Income Distribution:** The contract automates rental income collection and distributes it among property owners based on unit ownership.

- **Unit Resale:** Users can list their units for sale on the platform and facilitate the transfer of NFT ownership and payment between the seller and buyer.

- **Token Metadata Management:** Metadata associated with NFTs, including property details and ownership information, can be managed by the contract.

### Key Features

- **Real Estate Tokenization:** Brickly allows users to tokenize real estate properties into NFTs. Each property is represented by a unique ERC-721 token.

- **Property Listing and Trading:** Users can list individual units of real estate properties for sale on the marketplace. Other users can purchase these units using Ether.

- **Rental Income:** The platform supports the setting and updating of rental prices for properties. Users can earn rental income based on the number of units they own.

- **User Interaction:** The contract keeps track of property ownership, allowing users to buy, sell, and list their property units. Property details are stored in a struct called `Property`.

- **Delisting Functionality:** Users can delist their property units, transferring them back to the original owner and removing them from the list of properties for sale.

- **Integration with Mode Network SFS:** The contract includes a reference to the Mode Network SFS contract (`Register`), suggesting integration with the Mode Network. This integration involves registering the Brickly contract with the SFS contract and assigning NFTs to the owner of the Brickly contract.

- **Earnings Calculation:** The `calculateEarnings` function allows property owners to estimate their earnings based on the total income of the platform.

### How it Works

- **Tokenization:** Users initiate the tokenization process by calling the `tokenizeProperty` function, providing details such as location, description, property value, total units, and rental price.

- **Listing Units:** Property owners can list individual units for sale using the `listUnitForSale` function, specifying the property ID, token ID, and sale price.

- **Buying Units:** Buyers can purchase listed units using the `buyUnit` function, transferring ownership of the NFT and handling payments in Ether.

- **Rental Income:** Property owners earn rental income, and the platform supports updating rental prices through the `setRentalPrice` function.

- **Delisting Units:** Users can delist their units using the `delistUnit` function, transferring the unit back to the original owner and removing it from the sale listings.

### Integration with Mode Network SFS

The integration with Mode Network SFS is primarily related to the registration of Brickly with the SFS contract (`Register`). This integration suggests that the NFTs created by Brickly are somehow associated with or recognized by the Mode Network.

### Unique Features or Innovations

- **Real Estate Tokenization:** Brickly innovatively tokenizes real estate properties, transforming them into tradeable NFTs on the blockchain.

- **Rental Income Distribution:** The platform facilitates the distribution of rental income among property owners based on the number of units they own.

- **Delisting Functionality:** The ability to delist units provides flexibility for property owners to manage their listings.

- **Integration with Mode Network SFS:** The integration with the Mode Network indicates a connection to a larger network or ecosystem, potentially enhancing the utility and interoperability of Brickly.

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
   yarn install
   ```

### Usage

1. Compile the smart contract:

   ```bash
   yarn build
   ```

2. Deploy to Mode Testnet:

   ```bash
   yarn modeTestnet:deploy
   ```

## Contract Architecture

The contract is organized into multiple parts, each in a separate Solidity file within the `contracts/` directory:

- `Brickly.sol`:
This is the contract that tokenizes proprties by deploying an NFT which is a new instance of the `Asset` contract.
This contract also allows the owner of a tokenized asset to list the units for sale

- `Asset.sol`:
This is the NFT contract. A new NFT is created each time to represent a unique property.
A property can have different units which is represented with a unique `tokenId`.
