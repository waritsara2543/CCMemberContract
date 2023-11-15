// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

import './Admin.sol';

import './interfaces/ICampaign.sol';

contract Campaign is ICampaign, Admin {
    uint256 private _campaignIdCounter;
    mapping(uint256 => campaignsInfo) public campaigns;

    constructor() Admin() {}

    // create campaign function
    function createCampaign(
        string memory _name,
        string memory _description,
        string memory _baseURI,
        uint256 _timeStart,
        uint256 _timeEnd
    ) onlyAdmins(msg.sender) public {
        //cannot create campaign if has another campaign running
        require(!hasCampaignRunning(_timeStart,_timeEnd ), 'has campaign running');

        uint256 campaignId = _campaignIdCounter;
        _campaignIdCounter += 1;
        campaigns[campaignId] = campaignsInfo({
            name: _name,
            description: _description,
            baseURI: _baseURI,
            timeStart: _timeStart,
            timeEnd: _timeEnd,
            nftId: new uint256[](0)
        });
    }

    // check has any campaign run with the same time
    function hasCampaignRunning(uint256 _timeStart,
        uint256 _timeEnd) public view returns (bool) {
        for (uint256 i = 0; i < _campaignIdCounter; i++) {
            if (
                campaigns[i].timeStart <= _timeStart &&
                campaigns[i].timeEnd >= _timeEnd
            ) {
                return true;
            }
        }
        return false;
    }

    function isRunningCampaign(uint256 _campaignId) public view returns (bool) {
        if (
            campaigns[_campaignId].timeStart <= block.timestamp &&
            campaigns[_campaignId].timeEnd >= block.timestamp
        ) {
            return true;
        }
        return false;
    }


    function getCampaignInfo(uint256 _campaignId)
        public
        view
        returns (campaignsInfo memory)
    {
        return campaigns[_campaignId];
    }

    function addNftToCampaign (uint256 _campaignId, uint256 _nftId) external {
        campaigns[_campaignId].nftId.push(_nftId);
    }


    // get all campaign
    function getAllCampaign()
        public
        view
        returns (uint256[] memory id)
    {
        uint256[] memory item = new uint256[](_campaignIdCounter);

        for (uint256 i = 0; i < _campaignIdCounter; i++) {
            item[i] = i;
        }

        return item;
       
    }

    function getCampaignByPeriod(string memory period)
        public
        view
        returns (uint256[] memory id)
    {
        uint256[] memory item = new uint256[](_campaignIdCounter);

        for (uint256 i = 0; i < _campaignIdCounter; i++) {
            if(compareStrings(period, 'running')){
                if (
                    campaigns[i].timeStart <= block.timestamp &&
                    campaigns[i].timeEnd >= block.timestamp
                ) {
                    item[i] = i;
                }
            }else if(compareStrings(period, 'upcoming')){
                if (
                    campaigns[i].timeStart > block.timestamp
                ) {
                    item[i] = i;
                }
            }else if(compareStrings(period, 'past')){
                if (
                    campaigns[i].timeEnd < block.timestamp
                ) {
                    item[i] = i;
                }
            }
        }

        return item;
       
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
}