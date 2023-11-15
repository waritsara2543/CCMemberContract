// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MemberEmitLog {
    event WantsToUpgrade(address indexed _customerAddress, uint256 indexed _pointItemId, string indexed _request);
    event WantsToAddPoint(address indexed _customerAddress, uint256 indexed _point, uint256 indexed _campaignId);
    constructor() {}

    function emitMemberLog(address _target, uint256 _pointItemId, string memory _request) public {
        emit WantsToUpgrade(_target, _pointItemId, _request);
    }

    function emitPointLog(address _target, uint256 _point, uint256 _campaignId) public {
        emit WantsToAddPoint(_target, _point, _campaignId);
    }
}