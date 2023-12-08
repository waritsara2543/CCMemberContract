// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./interfaces/ICampaign.sol";
import "./interfaces/ICryptoCoffPoint.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";


contract ExpiredClaim  {

    ICampaign public campaign;
    ICryptoCoffPoint public point;

    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    constructor(address _campaignAddress, address _pointAddress, uint256 _interval) {
        campaign = ICampaign(_campaignAddress);
        point = ICryptoCoffPoint(_pointAddress);
        lastTimeStamp = block.timestamp;
        interval = _interval;
        //60 * 60 * 24 ; // 1 day
    }

    function updateExpireClaim() public {
         uint256[] memory campaignItem = campaign.getCampaignByPeriod("past");
        for (uint256 i = 0; i < campaignItem.length; i++) {
            ICampaign.campaignsInfo memory info = campaign.getCampaignInfo(campaignItem[i]);
            // info.expireClaim = Time to expire claim
            if (((info.timeEnd + info.expireClaim) < block.timestamp)) {
                uint256[] memory nftId = info.nftId;
                for (uint256 j = 0; j < nftId.length; j++) {
                // update status of nft
                if(point.IsAchieveGoal(nftId[j])){
                    point.setNewTokenURI(nftId[j], string(abi.encodePacked(info.baseURI, "expired.json")));
                }
                }
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
}