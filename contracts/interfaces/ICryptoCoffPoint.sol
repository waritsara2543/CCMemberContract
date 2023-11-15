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
    
    function addPoint(address customerAddress, uint256 point) external;
    
    function getTokenOfOwnerByIndex(address owner) external view returns (uint256[] memory);

    function safeMint(address to, uint256 point) external;

    function claimPoint (uint256 _tokenId) external;

    function setNewTokenUri(uint256 tokenId, uint256 point) external;

    function pointStage(uint256 tokenId, uint256 point) external view returns (uint256);

    function compareStrings(string memory a, string memory b) external pure returns (bool);

    function bytes32ToAddress(bytes32 _address) external pure returns (address);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function IsAchieveGoal(uint256 tokenId) external view returns (bool);

    function IsClaimed(uint256 tokenId) external view returns (bool);
}
