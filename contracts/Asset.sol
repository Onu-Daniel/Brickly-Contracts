// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Asset
/// @author Jude (https://github.com/iammrjude)
contract Asset is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    // Define a struct to represent a real estate property
    struct Props {
        string location;
        string description;
        uint256 price;
        uint256 totalUnits;
        uint256 rentalPrice;
    }

    mapping(uint256 => Props) public props;
    // Mapping to track the owner of each property unit
    mapping(uint256 => address) public propertyToOwner;

    Counters.Counter private _tokenIdCounter;

    // Mapping to store metadata URIs associated with token IDs for each real estate company
    mapping(address => mapping(uint256 => string)) private _tokenURIsByCompany;

    constructor(
        string memory name,
        string memory symbol,
        address recipient,
        string memory location,
        string memory description,
        uint256 price,
        uint256 totalUnits,
        uint256 rentalPrice
    ) ERC721(name, symbol) {
        tokenize(recipient, location, description, price, totalUnits, rentalPrice);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://brickly.org/api/maker/";
    }

    // factory deploys the nft
    // the picture will be customized to have unit 1, unit 2, etc
    // keep track of the total unit (state variable)
    // the nft will be also a splitter contract to split payments according to the number of units
    // the more units you have the more you get. Map unit (tokenId) to owner
    function tokenize(
        address recipient,
        string memory location,
        string memory description,
        uint256 price,
        uint256 totalUnits,
        uint256 rentalPrice
    ) internal {
        // Mint NFTs for each unit and assign ownership to the caller
        for (uint256 i; i < totalUnits; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(recipient, tokenId);
            propertyToOwner[tokenId] = recipient;
            props[tokenId] = Props(location, description, price, totalUnits, rentalPrice);
        }
    }

    function ownerTokenIds(address owner) external view returns (uint[] memory) {
        uint balance = balanceOf(owner);
        require(balance > 0, "Owner dont have tokens");
        uint[] memory result = new uint[](balance);
        for (uint i; i < balance; i++) {
            result[i] = tokenOfOwnerByIndex(owner, i);
        }
        return result;
    }

    function calculateEarnings(address propertyOwner) external view returns (uint256) {
        uint256 totalIncome = address(this).balance;
        uint256 tokenId = _tokenIdCounter.current();
        return ((balanceOf(propertyOwner) * totalIncome) / props[tokenId].totalUnits);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    )
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721) {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}