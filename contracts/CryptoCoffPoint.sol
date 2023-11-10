// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/ILogAutomation.sol";
import "./interfaces/ICryptoCoffPoint.sol";


contract CryptoCoffPoint is ICryptoCoffPoint, ERC721, ERC721URIStorage,  ERC721Enumerable {

    uint256 private _tokenIdCounter;

    // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/1point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/2point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/3point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/4point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/5point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/6point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/7point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/8point.json",
        "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/9point.json"
    ];

    constructor() ERC721("CryptoCoffPointNFTs", "CryptoCoffPointNFT") {}

    event Customer(address indexed customerAddress);

    uint256 public counted = 0;

    function checkLog(
        Log calldata log,
        bytes memory
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = true;
        address customerAddress = bytes32ToAddress(log.topics[1]);
        // uint point = uint(log.topics[2]);
        performData = abi.encode(customerAddress);
        // performData = abi.encode(point);
    }

    function performUpkeep(bytes calldata performData) external override {
        counted += 1;
        address customerAddress = abi.decode(performData, (address));
        // uint point = abi.decode(performData, (uint));
        emit Customer(customerAddress);

        //add point
        uint256[] memory item = getTokenOfOwnerByIndex(customerAddress);
        if(item.length > 0){
            uint256 itemId = item[0];
            addPoint(itemId);
        }else{
            safeMint(customerAddress);
        }
        
    }

    function getTokenOfOwnerByIndex(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 size = ERC721.balanceOf(owner);
        uint256[] memory item = new uint256[](size);

        for (uint256 i = 0; i < size; i++) {
            item[i] = tokenOfOwnerByIndex(owner, i);
        }
        return item;
    }

    function safeMint(address to) public {
        uint256[] memory item = getTokenOfOwnerByIndex(to);
        require(item.length == 0, "You already have a point NFT");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function addPoint (uint256 _tokenId) public  {
        string memory newUri = getNewUri(_tokenId);
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    function getNewUri(uint256 _tokenId) public view returns (string memory newUri) {
        string memory _uri = tokenURI(_tokenId);
        for (uint256 i = 0; i < IpfsUri.length; i++) {
            if (compareStrings(_uri, IpfsUri[i])) {
                return IpfsUri[i+1];
            }
        }
    }

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

        function bytes32ToAddress(bytes32 _address) public pure returns (address) {
        return address(uint160(uint256(_address)));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ICryptoCoffPoint,ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ICryptoCoffPoint, ERC721, ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

     function _update(address to, uint256 tokenId, address auth)  internal override(ERC721, ERC721Enumerable) returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        if (previousOwner == address(0)) {
            // _addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            // _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) {
            // _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            // _addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(account, amount);
    }

    function IsAchieveGoal(uint256 tokenId)public view returns (bool){
        string memory _uri = tokenURI(tokenId);
        if(compareStrings(_uri, IpfsUri[IpfsUri.length - 1])){
            return true;
        }
        return false;
    }

    function burn(uint256 tokenId) public override {
        _burn(tokenId);
    }

}