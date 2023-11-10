// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./ILogAutomation.sol";

interface ICryptoCoffPoint is ILogAutomation {

    function checkLog(
        Log calldata log,
        bytes memory checkData
    ) external returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
    
    function getTokenOfOwnerByIndex(address owner) external view returns (uint256[] memory);

    function safeMint(address to) external;

    function burn(uint256 tokenId) external;

    function addPoint(uint256 tokenId) external;

    function getNewUri(uint256 tokenId) external view returns (string memory newUri);

    function compareStrings(string memory a, string memory b) external pure returns (bool);

    function bytes32ToAddress(bytes32 _address) external pure returns (address);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function IsAchieveGoal(uint256 tokenId) external view returns (bool);
}
