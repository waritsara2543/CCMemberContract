// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

interface ICampaign {
    
    struct campaignsInfo {
        string name;
        string description;
        string baseURI;
        uint256 timeStart;
        uint256 timeEnd;
        uint256 expireClaim; // time to claim after campaign end (days)
        uint256[] nftId;
    }

    function createCampaign(
        string memory _name,
        string memory _description,
        string memory _baseURI,
        uint256 _timeStart,
        uint256 _timeEnd,
        uint256 _expireClaim
    ) external;

    function addNftToCampaign (uint256 _campaignId, uint256 _nftId) external;

    function hasCampaignRunning(uint256 _timeStart, uint256 _timeEnd) external view returns (bool);

    function isRunningCampaign(uint256 _campaignId) external view returns (bool);

    function getCampaignInfo(uint256 _campaignId)
        external
        view
        returns (
            campaignsInfo memory
        );
    
    
    function getCampaignByPeriod(string memory period) external  view
        returns (uint256[] memory id);

    function getAllCampaign() external view returns (uint256[] memory id);
   
}