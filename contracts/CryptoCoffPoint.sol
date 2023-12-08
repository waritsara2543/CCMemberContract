// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/ILogAutomation.sol";
import "./interfaces/ICryptoCoffPoint.sol";
import "./interfaces/ICampaign.sol";


contract CryptoCoffPoint is ICryptoCoffPoint, ERC721, ERC721URIStorage,  ERC721Enumerable {

    uint256 private _tokenIdCounter;
    uint256 private archiveGoalPoint = 9;
    uint256 private campaignId;
    ICampaign public campaign;

    constructor(address _campaignAddress) ERC721("CryptoCoffPointNFTs", "CryptoCoffPointNFT") {
        campaign = ICampaign(_campaignAddress);
    }

    function checkLog(
        Log calldata log,
        bytes memory
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = true;
        address customerAddress = bytes32ToAddress(log.topics[1]);
        uint256 point = uint256(log.topics[2]);
        uint256 cid = uint256(log.topics[3]);
        performData = abi.encode(customerAddress, point, cid);
    }

    function performUpkeep(bytes calldata performData) external override {
        (address customerAddress, uint256 point, uint256 _campaignId) = abi.decode(performData, (address, uint256,uint256));
        addPoint(customerAddress, point, _campaignId);
    }

    function setCampaignId(uint256 _campaignId) public {
        campaignId = _campaignId;
    }

    function addPoint(address _customerAddress, uint256 _point, uint256 _campaignId) public {
        //TODO: require the NFT is on active campaign 
        require(campaign.isRunningCampaign(_campaignId), "This campaign is not running");

        //add point
        uint256[] memory item = getTokenOfOwnerByIndex(_customerAddress);
        if(item.length > 0 && !IsAchieveGoal(item[item.length-1])){
                    uint256 currentPoint = pointStage(item[item.length-1], 0) + 1;
                    uint256 remaining = archiveGoalPoint - currentPoint;
                    if(remaining <= _point){
                        updateTokenUri(item[item.length-1], remaining);
                        addPointToNewNft(_point - remaining, _customerAddress,_campaignId);
                    }else{
                        updateTokenUri(item[item.length-1], _point);
                    }
        }else{
            addPointToNewNft(_point, _customerAddress,_campaignId);
        }
    }

    function addPointToNewNft (uint256 _point, address _customerAddress, uint256 _campaignId) internal{
        uint256 NftCount = _point/archiveGoalPoint;
                if (_point % archiveGoalPoint > 0) {
                    NftCount += 1;
                }
                for(uint i = 0; i < NftCount; i++){
                    if(i == NftCount - 1){
                        safeMint(_customerAddress, _point - archiveGoalPoint * i,_campaignId);
                    }else{
                        safeMint(_customerAddress, archiveGoalPoint,_campaignId);
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

    function getTokenOfOwnerByCampaign(address owner, uint256 _campaignId)
    public
    view
    returns (uint256[] memory)
    {
    uint256[] memory item = getTokenOfOwnerByIndex(owner);
    ICampaign.campaignsInfo memory info = campaign.getCampaignInfo(_campaignId);

    uint256[] memory result = new uint256[](item.length); // Initialize result array

    uint256 size = 0;
    for (uint256 i = 0; i < item.length; i++) {
        for (uint256 j = 0; j < info.nftId.length; j++) {
            if (item[i] == info.nftId[j]) {
                result[size] = item[i]; // Assign to result[size]
                size += 1;
            }
        }
    }

    // Trim the result array to the actual size
    uint256[] memory trimmedResult = new uint256[](size);
    for (uint256 k = 0; k < size; k++) {
        trimmedResult[k] = result[k];
    }

    return trimmedResult;
    }


    function safeMint(address to, uint256 point, uint256 _campaignId) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        
        //push nftId to campaign
        campaign.addNftToCampaign(_campaignId, tokenId);

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, getMetadata()[point-1]);
    }

    function updateTokenUri (uint256 _tokenId, uint256 point) internal  {
        uint newPoint = pointStage(_tokenId, point);
        string memory newUri = getMetadata()[newPoint];
        // Update the URI
       setNewTokenURI(_tokenId, newUri);
    }

    function setNewTokenURI (uint256 _tokenId, string memory _tokenURI) public  {
        _setTokenURI(_tokenId, _tokenURI);
    }

    function pointStage(uint256 _tokenId,uint256 point) internal view returns (uint256 newPoint) {
        string memory _uri = tokenURI(_tokenId);
        for (uint256 i = 0; i < archiveGoalPoint ; i++) {
            if (compareStrings(_uri, getMetadata()[i])) {
                return i + point;
            }
        }
    }

    function compareStrings(string memory a, string memory b)
        internal
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

    function IsAchieveGoal(uint256 tokenId) public view returns (bool){
        string memory _uri = tokenURI(tokenId);
        if(compareStrings(_uri, getMetadata()[archiveGoalPoint-1]) || compareStrings(_uri, getMetadata()[archiveGoalPoint])){
            return true;
        }
        return false;
    }

    function IsClaimed(uint256 tokenId) public view returns (bool){
        string memory _uri = tokenURI(tokenId);
        if(compareStrings(_uri, getMetadata()[archiveGoalPoint])){
            return true;
        }
        return false;
    }

    function claimPoint (uint256 _tokenId) external {
        require(IsAchieveGoal(_tokenId), "You don't have enough NFT point" );
        require(!IsClaimed(_tokenId), "This NFT was claimed");    

        _setTokenURI(_tokenId, getMetadata()[archiveGoalPoint]);
    }

    function getMetadata() public view returns (string[] memory){
        string[] memory metadata = new string[](archiveGoalPoint+1);
        ICampaign.campaignsInfo memory campaignDetail = campaign.getCampaignInfo(campaignId);
        for (uint256 i = 0; i < archiveGoalPoint+1 ; i++) {
            if(i == archiveGoalPoint){
                metadata[i] = string(abi.encodePacked(campaignDetail.baseURI, "claimed.json"));
                }else{
                metadata[i] = string(abi.encodePacked(campaignDetail.baseURI, uint2str(i + 1), "point.json"));
                }
           
        }
        return metadata;
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

}