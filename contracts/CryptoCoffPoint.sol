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
        uint256 point = uint256(log.topics[2]);
        performData = abi.encode(customerAddress, point);
    }

    function performUpkeep(bytes calldata performData) external override {
        counted += 1;
        (address customerAddress, uint256 point) = abi.decode(performData, (address, uint256));
        emit Customer(customerAddress);
        addPoint(customerAddress, point);
    }

    function addPoint(address customerAddress, uint256 point) public {
        //add point
        uint256[] memory item = getTokenOfOwnerByIndex(customerAddress);

        uint256 archiveGoalPoint = IpfsUri.length;
        if(item.length > 0){
            for(uint i = 0; i < item.length; i++){
                if(IsAchieveGoal(item[i])){
                    safeMint(customerAddress, point);
                }else{
                    uint256 currentPoint = pointStage(item[i], 0) + 1;
                    uint256 remaining = archiveGoalPoint - currentPoint;
                    if(remaining < point){
                        setNewTokenUri(item[i], remaining);
                        addPointToNewNft(point - remaining, archiveGoalPoint, customerAddress);
                    }else{
                        setNewTokenUri(item[i], point);
                    }
                }
            }
        }else{
            addPointToNewNft(point, archiveGoalPoint, customerAddress);
            
        }
    }

    function addPointToNewNft (uint256 point, uint256 archiveGoalPoint, address customerAddress) internal{
        uint256 NftCount = point/archiveGoalPoint;
                if (point % archiveGoalPoint > 0) {
                    NftCount += 1;
                }
                for(uint i = 0; i < NftCount; i++){
                    if(i == NftCount - 1){
                        safeMint(customerAddress, point - archiveGoalPoint * i);
                    }else{
                        safeMint(customerAddress, archiveGoalPoint);
                    }
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

    function safeMint(address to, uint256 point) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[point-1]);
    }

    function setNewTokenUri (uint256 _tokenId, uint256 point) public  {
        uint newPoint = pointStage(_tokenId, point);
        string memory newUri = IpfsUri[newPoint];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    function pointStage(uint256 _tokenId,uint256 point) public view returns (uint256 newPoint) {
        string memory _uri = tokenURI(_tokenId);
        for (uint256 i = 0; i < IpfsUri.length; i++) {
            if (compareStrings(_uri, IpfsUri[i])) {
                return i + point;
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