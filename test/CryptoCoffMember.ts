import { expect } from "chai";
import {
  Campaign,
  CryptoCoffMember,
  CryptoCoffPoint,
} from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

describe("Upgrade Member", function () {
  let MemberContract: CryptoCoffMember;
  let addPointContract: CryptoCoffPoint;
  let campaignContract: Campaign;
  let owner: SignerWithAddress;
  const baseURI = [
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
    "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json",
  ];
  const pointBaseURI =
    "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmY9hAHLQ3wc6EgQ3m7QmthfMYKQM9WMTD8PzQEn4eLRWF/";

  beforeEach(async function () {
    const CryptoCoffMember = await ethers.getContractFactory(
      "CryptoCoffMember"
    );
    const CryptoCoffPoint = await ethers.getContractFactory("CryptoCoffPoint"); // Adjust the contract name

    const Campaign = await ethers.getContractFactory("Campaign"); // Adjust the contract name
    campaignContract = await Campaign.deploy();
    await campaignContract.deployed();

    addPointContract = await CryptoCoffPoint.deploy(campaignContract.address);
    await addPointContract.deployed();

    MemberContract = await CryptoCoffMember.deploy(addPointContract.address);
    await MemberContract.deployed();

    await campaignContract.createCampaign(
      "test",
      "test",
      pointBaseURI,
      1699944892,
      1700463292
    );

    await addPointContract.setCampaignId(0);

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
    const pointURIBefore = await addPointContract.tokenURI(0);

    await MemberContract.upgradeMember(0, owner.address);
    const tokenURI = await MemberContract.tokenURI(0);
    const pointURIAfter = await addPointContract.tokenURI(0);

    expect(tokenURI).to.equal(baseURI[0]);
    expect(pointURIBefore).to.equal(`${pointBaseURI}9point.json`);
    expect(pointURIAfter).to.equal(`${pointBaseURI}claimed.json`);
  });

  it("Should upgrate NFT to level 2", async function () {
    await addPointContract.addPoint(owner.address, 18);

    const pointURI0Before = await addPointContract.tokenURI(0);
    const pointURI1Before = await addPointContract.tokenURI(1);
    await MemberContract.upgradeMember(0, owner.address);
    const tokenURIBefore = await MemberContract.tokenURI(0);

    await MemberContract.upgradeMember(1, owner.address);

    const pointURI0After = await addPointContract.tokenURI(0);
    const pointURI1After = await addPointContract.tokenURI(1);

    const tokenURIAfter = await MemberContract.tokenURI(0);

    expect(tokenURIBefore).to.equal(baseURI[0]);
    expect(tokenURIAfter).to.equal(baseURI[1]);
    expect(pointURI0Before).to.equal(`${pointBaseURI}9point.json`);
    expect(pointURI0After).to.equal(`${pointBaseURI}claimed.json`);
    expect(pointURI1Before).to.equal(`${pointBaseURI}9point.json`);
    expect(pointURI1After).to.equal(`${pointBaseURI}claimed.json`);
  });
});
