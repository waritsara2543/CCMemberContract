import { expect } from "chai";
import { Campaign, CryptoCoffPoint } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

describe("Add point contract", function () {
  let addPointContract: CryptoCoffPoint;
  let campaignContract: Campaign;
  let owner: SignerWithAddress;
  const baseURI =
    "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmY9hAHLQ3wc6EgQ3m7QmthfMYKQM9WMTD8PzQEn4eLRWF/";

  beforeEach(async function () {
    const Campaign = await ethers.getContractFactory("Campaign"); // Adjust the contract name
    campaignContract = await Campaign.deploy();
    await campaignContract.deployed();

    const CryptoCoffPoint = await ethers.getContractFactory("CryptoCoffPoint"); // Adjust the contract name
    addPointContract = await CryptoCoffPoint.deploy(campaignContract.address);
    await addPointContract.deployed();

    await campaignContract.createCampaign(
      "test",
      "test",
      baseURI,
      1699944892,
      1701224805
    );

    await campaignContract.createCampaign(
      "test",
      "test",
      baseURI,
      1701328153,
      1701414553
    );

    [owner] = await ethers.getSigners();
  });

  it("Should mint an NFT", async function () {
    // Mint an NFT
    await addPointContract.safeMint(owner.address, 3);

    // Get the tokenURI
    const tokenURI = await addPointContract.tokenURI(0);

    // Check if tokenURI is correct
    expect(tokenURI).to.equal(`${baseURI}3point.json`);
  });

  it("Should add points to an NFT", async function () {
    // Mint an NFT
    // await addPointContract.safeMint(owner.address, 1);

    // Add points to the NFT
    await addPointContract.addPoint(owner.address, 10, 0);

    const token = await addPointContract.getTokenOfOwnerByCampaign(
      owner.address,
      0
    );

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);

    // Check if points are correctly added
    expect(token.length).to.equal(2);
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}1point.json`);
  });

  it("Should mint new NFTs", async function () {
    // Mint an NFT
    await addPointContract.addPoint(owner.address, 9, 0);

    // add points to the NFT
    await addPointContract.addPoint(owner.address, 2, 0);

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);

    // Check if points are correctly added
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}2point.json`);
  });

  it("Should add points to an NFT and mint new NFT", async function () {
    // Mint an NFT
    await addPointContract.addPoint(owner.address, 1, 0);

    // Add points to the NFT
    await addPointContract.addPoint(owner.address, 9, 0);

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);

    // Check if points are correctly added
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}1point.json`);
  });

  it("Should mint 3 Nfts", async function () {
    // Mint an NFT
    await addPointContract.addPoint(owner.address, 20, 0);
    await addPointContract.addPoint(owner.address, 9, 0);

    // Get the tokenURI

    const token = await addPointContract.getTokenOfOwnerByCampaign(
      owner.address,
      0
    );

    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);
    const tokenURI2 = await addPointContract.tokenURI(2);
    const tokenURI3 = await addPointContract.tokenURI(3);

    // Check if points are correctly added
    expect(token.length).to.equal(4);
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}9point.json`);
    expect(tokenURI2).to.equal(`${baseURI}9point.json`);
    expect(tokenURI3).to.equal(`${baseURI}2point.json`);
  });

  it("Should claim point", async function () {
    await addPointContract.addPoint(owner.address, 9, 0);
    const tokenURIBefore = await addPointContract.tokenURI(0);

    await addPointContract.claimPoint(0);
    const tokenURIAfter = await addPointContract.tokenURI(0);

    expect(tokenURIBefore).to.equal(`${baseURI}9point.json`);
    expect(tokenURIAfter).to.equal(`${baseURI}claimed.json`);
  });

  it("Should revert because not running campaign", async function () {
    expect(addPointContract.addPoint(owner.address, 9, 1)).to.be.revertedWith(
      "This campaign is not running"
    );
  });

  it("Should get token in campaign", async function () {
    addPointContract.addPoint(owner.address, 10, 0);

    const tokenInCampaign = await addPointContract.getTokenOfOwnerByCampaign(
      owner.address,
      0
    );

    expect(tokenInCampaign[0]).to.equal(0);
    expect(tokenInCampaign[1]).to.equal(1);
  });
});
