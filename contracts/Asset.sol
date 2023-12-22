// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Register {
    function register(address _recipient) public returns (uint256 tokenId) {}
}

/**
 * @title Asset - Real Estate Property NFT Contract
 * @author Jude (https://github.com/iammrjude)
 * @dev ERC721-compliant contract representing real estate properties as NFTs.
 */
contract Asset is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    // Define a struct to represent a real estate property
    struct Props {
        string location;
        string description;
        uint256 propertyValue;
        uint256 totalUnits;
        uint256 rentalPrice;
    }

    // Mapping to store property details by token ID
    mapping(uint256 => Props) public props;

    // Mapping to track the owner of each property unit
    mapping(uint256 => address) public propertyToOwner;

    // Counter for generating unique token IDs
    Counters.Counter private _tokenIdCounter;

    // Address to receive fees from property tokenization
    address feeReceiver = msg.sender;

    /**
     * @dev Constructor function to initialize the Asset contract.
     * @param name The name of the NFT contract.
     * @param symbol The symbol of the NFT contract.
     * @param recipient The initial owner of the property units.
     * @param location The location of the real estate property.
     * @param description The description of the real estate property.
     * @param propertyValue The value of the real estate property.
     * @param totalUnits The total number of units in the property.
     * @param rentalPrice The rental price for each unit.
     */
    constructor(
        string memory name,
        string memory symbol,
        address recipient,
        string memory location,
        string memory description,
        uint256 propertyValue,
        uint256 totalUnits,
        uint256 rentalPrice
    ) ERC721(name, symbol) {
        tokenize(
            recipient,
            location,
            description,
            propertyValue,
            totalUnits,
            rentalPrice
        );
        feeReceiver = msg.sender; //The deployer of the contract will get the NFTto widthraw the earned fees
        Register sfsContract = Register(
            0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6
        ); // This address is the address of the SFS contract
        sfsContract.register(msg.sender); //Registers this contract and assigns the NFT to the owner of this contract
    }

    /**
     * @dev Internal function to mint NFTs for each unit and assign ownership to the recipient.
     * @param recipient The address to receive the minted NFTs.
     * @param location The location of the real estate property.
     * @param description The description of the real estate property.
     * @param propertyValue The value of the real estate property.
     * @param totalUnits The total number of units in the property.
     * @param rentalPrice The rental price for each unit.
     */
    function tokenize(
        address recipient,
        string memory location,
        string memory description,
        uint256 propertyValue,
        uint256 totalUnits,
        uint256 rentalPrice
    ) internal {
        // Mint NFTs for each unit and assign ownership to the caller
        for (uint256 i; i < totalUnits; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(recipient, tokenId);
            propertyToOwner[tokenId] = recipient;
            props[tokenId] = Props(
                location,
                description,
                propertyValue,
                totalUnits,
                rentalPrice
            );
        }
    }

    /**
     * @dev Internal function to specify the base URI for token metadata.
     * @return The base URI for token metadata.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "https://brickly.com/api/maker/";
    }

    /**
     * @dev External function to retrieve the token IDs owned by a specific address.
     * @param owner The address of the owner.
     * @return An array of token IDs owned by the specified address.
     */
    function ownerTokenIds(
        address owner
    ) external view returns (uint[] memory) {
        uint balance = balanceOf(owner);
        require(balance > 0, "Owner dont have tokens");
        uint[] memory result = new uint[](balance);
        for (uint i; i < balance; i++) {
            result[i] = tokenOfOwnerByIndex(owner, i);
        }
        return result;
    }

    /**
     * @dev External function to calculate earnings for a property owner based on the total income.
     * @param propertyOwner The address of the property owner.
     * @return The calculated earnings for the property owner.
     */
    function calculateEarnings(
        address propertyOwner
    ) external view returns (uint256) {
        uint256 totalIncome = address(this).balance;
        uint256 tokenId = _tokenIdCounter.current();
        return ((balanceOf(propertyOwner) * totalIncome) /
            props[tokenId].totalUnits);
    }

    // The following functions are overrides required by Solidity.

    /**
     * @dev Internal function to handle logic before transferring tokens.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /**
     * @dev Internal function to handle logic after transferring tokens.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721) {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /**
     * @dev External function to check if a contract supports a specific interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
