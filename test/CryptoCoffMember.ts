import { expect } from "chai";
import { CryptoCoffMember, CryptoCoffPoint } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

describe("Upgrade Member", function () {
  let MemberContract: CryptoCoffMember;
  let addPointContract: CryptoCoffPoint;
  let owner: SignerWithAddress;
  const baseURI = [
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json",
  ];

  beforeEach(async function () {
    const CryptoCoffMember = await ethers.getContractFactory(
      "CryptoCoffMember"
    );
    const CryptoCoffPoint = await ethers.getContractFactory("CryptoCoffPoint"); // Adjust the contract name

    addPointContract = await CryptoCoffPoint.deploy();
    await addPointContract.deployed();

    MemberContract = await CryptoCoffMember.deploy(addPointContract.address);
    await MemberContract.deployed();

    [owner] = await ethers.getSigners();
  });

  it("Should mint only 1 NFT", async function () {
    await MemberContract.safeMint(owner.address);
    await expect(MemberContract.safeMint(owner.address)).to.be.revertedWith(
      "You already have a member"
    );
  });

  it("Should revert because not enough point", async function () {
    await addPointContract.addPoint(owner.address, 2);
    await expect(
      MemberContract.upgradeMember(0, owner.address)
    ).to.be.revertedWith("You don't have enough NFT point");
  });

  it("Should create NFT level 1 for member", async function () {
    await addPointContract.addPoint(owner.address, 9);
    const getPointNFTBefore = await addPointContract.getTokenOfOwnerByIndex(
      owner.address
    );
    await MemberContract.upgradeMember(0, owner.address);
    const tokenURI = await MemberContract.tokenURI(0);
    const getPointNFTAfter = await addPointContract.getTokenOfOwnerByIndex(
      owner.address
    );

    expect(tokenURI).to.equal(baseURI[0]);
    expect(getPointNFTBefore.length).to.equal(1);
    expect(getPointNFTAfter.length).to.equal(0);
  });

  it("Should upgrate NFT to level 2", async function () {
    await addPointContract.addPoint(owner.address, 18);

    const getPointNFTBefore = await addPointContract.getTokenOfOwnerByIndex(
      owner.address
    );
    await MemberContract.upgradeMember(0, owner.address);
    const tokenURIBefore = await MemberContract.tokenURI(0);

    await MemberContract.upgradeMember(1, owner.address);

    const getPointNFTAfter = await addPointContract.getTokenOfOwnerByIndex(
      owner.address
    );

    const tokenURIAfter = await MemberContract.tokenURI(0);

    expect(tokenURIBefore).to.equal(baseURI[0]);
    expect(tokenURIAfter).to.equal(baseURI[1]);
    expect(getPointNFTBefore.length).to.equal(2);
    expect(getPointNFTAfter.length).to.equal(0);
  });
});
