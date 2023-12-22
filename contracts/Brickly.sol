// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Asset.sol";

/// @title Brickly - A decentralized real estate marketplace
/// @author Jude (https://github.com/iammrjude)
/// @dev This smart contract enables the creation, buying, selling, and renting of real estate properties as NFTs.
contract Brickly is Ownable {
    // Define a struct to represent a real estate property
    struct Property {
        string location;
        string description;
        uint256 propertyValue;
        uint256 totalUnits;
        uint256 rentalPrice;
        IERC721 nft;
    }

    // Array to store all the properties
    Property[] public properties;

    // Define a struct to represent a property listing
    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 salePrice;
        bool isActive;
    }

    // Array to store property listings
    Listing[] public listings;

    // Mapping to track the owner of each property unit
    mapping(uint256 => address) public propertyToOwner;

    // Define events to log important contract actions
    event PropertyTokenized(
        uint256 propertyId,
        address indexed owner,
        string location,
        string description,
        uint256 propertyValue,
        uint256 totalUnits
    );

    event UnitPurchased(
        uint256 propertyId,
        address buyer,
        address seller,
        uint256 tokenId,
        uint256 salePrice
    );

    event UnitListedForSale(
        uint256 listingId,
        address indexed seller,
        uint256 propertyId,
        uint256 tokenId,
        uint256 salePrice
    );

    // Event to notify when a unit is delisted
    event UnitDelisted(
        uint256 listingIndex,
        address indexed delistedBy,
        uint256 tokenId
    );

    // Define a variable to represent the total rental income
    uint256 public rentalIncome;

    // Mapping to track the total units owned by each user
    mapping(address => uint256) public userOwnedUnits;

    // Mapping to store metadata URIs associated with token IDs for each real estate company
    mapping(address => mapping(uint256 => string)) private _tokenURIsByCompany;

    // Event to notify when rental income is collected and distributed
    event RentalIncomeDistributed(uint256 propertyId, uint256 totalIncome);

    mapping(uint => uint) listingIndex;

    address feeReceiver = msg.sender;

    constructor() {
        feeReceiver = msg.sender; //The deployer of the contract will get the NFTto widthraw the earned fees
        Register sfsContract = Register(
            0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6
        ); // This address is the address of the SFS contract
        sfsContract.register(msg.sender); //Registers this contract and assigns the NFT to the owner of this contract
    }

    /**
     * @notice Function to tokenize a new property
     * @dev Ensures that the total units are greater than 0 before tokenizing a new property.
     * @param name The name of the NFT contract representing the property.
     * @param symbol The symbol of the NFT contract representing the property.
     * @param location The location of the real estate property.
     * @param description The description of the real estate property.
     * @param propertyValue The value of the real estate property.
     * @param totalUnits The total number of units in the property.
     * @param rentalPrice The rental price for each unit.
     */
    function tokenizeProperty(
        string memory name,
        string memory symbol,
        string memory location,
        string memory description,
        uint256 propertyValue,
        uint256 totalUnits,
        uint256 rentalPrice
    ) external {
        // Ensure that the total units are greater than 0
        require(totalUnits > 0, "Total units must be greater than 0");

        Asset nft = new Asset(
            name,
            symbol,
            msg.sender,
            location,
            description,
            propertyValue,
            totalUnits,
            rentalPrice
        );

        // Create a new Property struct with the provided information
        Property memory newProperty = Property({
            location: location,
            description: description,
            propertyValue: propertyValue,
            totalUnits: totalUnits,
            rentalPrice: rentalPrice,
            nft: IERC721(nft)
        });

        // Generate a unique property ID and add the property to the array
        uint256 propertyId = properties.length;
        properties.push(newProperty);

        // Emit an event to notify the property tokenization
        emit PropertyTokenized(
            propertyId,
            msg.sender,
            location,
            description,
            propertyValue,
            totalUnits
        );
    }

    /**
     * @dev Lists an individual unit for sale, ensuring that the caller owns the unit and the sale price is valid.
     * @param _propertyId The ID of the property to which the unit belongs.
     * @param _tokenId The ID of the unit (NFT) to be listed for sale.
     * @param _salePrice The sale price for the listed unit.
     */
    function listUnitForSale(
        uint256 _propertyId,
        uint256 _tokenId,
        uint256 _salePrice
    ) external {
        // Ensure that the caller owns the unit they are trying to list
        IERC721 nft = properties[_propertyId].nft;
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "You can only list units you own"
        );

        // Ensure that the sale price is greater than 0
        require(_salePrice > 0, "Sale price must be greater than 0");

        // Create a new listing and add it to the array
        Listing memory newListing = Listing({
            tokenId: _tokenId,
            seller: msg.sender,
            salePrice: _salePrice,
            isActive: true
        });

        listingIndex[_tokenId] = listings.length;
        listings.push(newListing);
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        // Emit an event to notify the listing
        emit UnitListedForSale(
            listings.length - 1,
            msg.sender,
            _propertyId,
            _tokenId,
            _salePrice
        );
    }

    /**
     * @dev Sets or updates the rental price for a property, restricted to the contract owner.
     * @param _propertyId The ID of the property for which the rental price is to be set or updated.
     * @param _newRentalPrice The new rental price for each unit in the property.
     */
    function setRentalPrice(
        uint256 _propertyId,
        uint256 _newRentalPrice
    ) external onlyOwner {
        // Ensure that the property exists
        require(_propertyId < properties.length, "Invalid property ID");

        // Update the rental price for the property
        properties[_propertyId].rentalPrice = _newRentalPrice;
    }

    /**
     * @dev Allows users to buy property units, transferring ownership of NFTs and handling payments.
     * @param _propertyId The ID of the property from which the unit is being purchased.
     * @param _tokenId The ID of the unit (NFT) being purchased.
     */
    function buyUnit(uint256 _propertyId, uint256 _tokenId) external payable {
        // Validate that the property exists
        require(_propertyId < properties.length, "Invalid property ID");

        uint index = listingIndex[_tokenId];
        bool isListed = listings[index].isActive;
        address seller = listings[index].seller;
        require(isListed, "property is not listed for sale");

        // Calculate the total price for the units to buy
        uint salePrice = listings[index].salePrice;

        // Ensure that the buyer has sent enough Ether
        require(msg.value >= salePrice, "Insufficient Ether sent");

        // Transfer ownership of the selected NFTs from the seller to the buyer
        IERC721 nft = properties[_propertyId].nft;
        require(
            nft.ownerOf(_tokenId) == address(this),
            "Seller does not own this unit"
        );
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // Transfer the sale price to the seller
        payable(seller).transfer(salePrice);

        // Refund any excess Ether sent
        if (msg.value > salePrice) {
            payable(msg.sender).transfer(msg.value - salePrice);
        }

        // Remove property from list of properties for sale
        listings[index].isActive = false;

        // Emit an event to notify the purchase
        emit UnitPurchased(
            _propertyId,
            msg.sender,
            seller,
            _tokenId,
            salePrice
        );
    }

    /**
     * @dev Delists a unit, transferring it back to the initial owner and removing it from the list of properties for sale.
     * @param _tokenId The ID of the unit (NFT) to be delisted.
     */
    function delistUnit(uint256 _tokenId) external {
        uint index = listingIndex[_tokenId];
        require(index < listings.length, "Listing not found");

        Listing storage listing = listings[index];
        require(listing.isActive, "Unit is not currently listed for sale");

        // Ensure that the caller is the current owner of the listing
        require(
            msg.sender == listing.seller,
            "You can only delist your own unit"
        );

        // Transfer the unit back to the original owner
        IERC721 nft = properties[index].nft;
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // Remove the listing from the array
        delete listings[index];

        // Emit an event to notify the delisting
        // Note: It's a good practice to emit an event even for deletions to keep track of actions.
        emit UnitDelisted(index, msg.sender, _tokenId);
    }

    function payRent() external payable {}
}
