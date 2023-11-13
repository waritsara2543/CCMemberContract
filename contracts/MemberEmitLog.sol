// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MemberEmitLog {
    event WantsToUpgrade(address indexed customerAddress);
    event WantsToAddPoint(address indexed customerAddress, uint256 indexed point);
    constructor() {}

    function emitMemberLog(address target) public {
        // if point collected has 9 then  _burn point collected NFT and Emit event WantsToUpgrade
        emit WantsToUpgrade(target);
    }

    function emitPointLog(address target, uint256 point) public {
        emit WantsToAddPoint(target, point);
    }
}