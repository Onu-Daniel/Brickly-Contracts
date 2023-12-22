// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Asset.sol";

/// @title Brickly
/// @author Jude (https://github.com/iammrjude)
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

    // Define a variable to represent the total rental income
    uint256 public rentalIncome;

    // Mapping to track the total units owned by each user
    mapping(address => uint256) public userOwnedUnits;

    // Mapping to store metadata URIs associated with token IDs for each real estate company
    mapping(address => mapping(uint256 => string)) private _tokenURIsByCompany;

    // Event to notify when rental income is collected and distributed
    event RentalIncomeDistributed(uint256 propertyId, uint256 totalIncome);

    mapping (uint => uint) listingIndex;

    address feeReceiver = msg.sender;

    // Constructor function to initialize the contract
    constructor() {
        feeReceiver = msg.sender; //The deployer of the contract will get the NFTto widthraw the earned fees
        Register sfsContract = Register(0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6); // This address is the address of the SFS contract
        sfsContract.register(msg.sender); //Registers this contract and assigns the NFT to the owner of this contract
    }

    // Function to tokenize a new property
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

        Asset nft = new Asset(name, symbol, msg.sender, location, description, propertyValue, totalUnits, rentalPrice);

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

    // Function to list an individual unit for sale
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

    // Function to set or update the rental price for a property
    function setRentalPrice(
        uint256 _propertyId,
        uint256 _newRentalPrice
    ) external onlyOwner {
        // Ensure that the property exists
        require(_propertyId < properties.length, "Invalid property ID");

        // Update the rental price for the property
        properties[_propertyId].rentalPrice = _newRentalPrice;
    }

    // Function to buy property units
    function buyUnit(
        uint256 _propertyId,
        uint256 _tokenId
    ) external payable {
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

        // remove property from list of properties for sale
        listings[index].isActive = false;

        // Emit an event to notify the purchase
        emit UnitPurchased(_propertyId, msg.sender, seller, _tokenId, salePrice);
    }

    // delist: token transferred back to the initial owner
    function delistUnit() external {}

    function payRent() external payable {}
}