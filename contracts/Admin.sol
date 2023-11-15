// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract Admin {
    address public rootAdmin;

    mapping(address => bool) public admins;

    event RootAdminChanged(address indexed oldRoot, address indexed newRoot);

    constructor() {
        rootAdmin = msg.sender;
    }

    modifier onlyRootAdmin() {
        require(msg.sender == rootAdmin, 'must be root admin');
        _;
    }

    modifier onlyAdmins(address _sender) {
        require(admins[_sender] || msg.sender == rootAdmin, 'must be admin');
        _;
    }

    function changeRootAdmin(address _newRootAdmin) public onlyRootAdmin {
        address oldRoot = rootAdmin;
        rootAdmin = _newRootAdmin;
        emit RootAdminChanged(oldRoot, rootAdmin);
    }

    function addAdmin(address _admin) public onlyRootAdmin {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) public onlyRootAdmin {
        admins[_admin] = false;
    }

    function isAdmin(address _admin) public view returns (bool) {
        return admins[_admin];
    }
}
