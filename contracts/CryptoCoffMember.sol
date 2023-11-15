// SPDX-License-Identifier: MIT
// This is for DEMO purposes only and should not be used in production!

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./interfaces/ICryptoCoffMember.sol";
import "./interfaces/ICryptoCoffPoint.sol";


contract CryptoCoffMember is ICryptoCoffMember, ERC721, ERC721URIStorage,  ERC721Enumerable {
    uint256 private _tokenIdCounter;
    // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json"
    ];

    ICryptoCoffPoint public point;

    constructor(address _pointAddress) ERC721("CryptoCoffMemberNFTs", "CryptoCoffMemberNFT") {
        point = ICryptoCoffPoint(_pointAddress);
    }

    function checkLog(
        Log calldata log,
        bytes memory
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = true;
        address customerAddress = bytes32ToAddress(log.topics[1]);
        uint256 pointItemId = uint256(log.topics[2]);
        string memory request = bytes32ToStr(log.topics[3]);        
        performData = abi.encode(customerAddress, pointItemId, request);
    }

    function performUpkeep(bytes calldata performData) external override {
        (address customerAddress, uint256 pointItemId, string memory request)= abi.decode(performData, (address, uint256, string));
        if(compareStrings(request, "coffee")){
            point.claimPoint(pointItemId);
        }else{
           //upgrate member
            upgradeMember(pointItemId, customerAddress);
        }
    }

    function upgradeMember (uint256 _pointTokenId, address customerAddress) internal{
        uint256[] memory item = getTokenOfOwnerByIndex(customerAddress);
        point.claimPoint(_pointTokenId);
        if(item.length > 0){
            uint256 itemId = item[0];
            if (MemberStage(itemId) >= 2) {
                return;
            }
            // Get the current stage of the member and add 1
            uint256 newVal = MemberStage(itemId) + 1;
            // store the new URI
            string memory newUri = IpfsUri[newVal];
            // Update the URI
            _setTokenURI(itemId, newUri);
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

    function safeMint(address to) internal {
        uint256[] memory item = getTokenOfOwnerByIndex(to);
        require(item.length == 0, "You already have a member");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function MemberStage(uint256 _tokenId) internal view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // bronze
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Silver
        if (compareStrings(_uri, IpfsUri[1])) {
            return 1;
        }
        // Gold
        return 2;
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function bytes32ToAddress(bytes32 _address) internal pure returns (address) {
        return address(uint160(uint256(_address)));
    }

    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
            }
        return string(bytesArray);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ICryptoCoffMember,ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ICryptoCoffMember,ERC721, ERC721URIStorage, ERC721Enumerable)
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

}