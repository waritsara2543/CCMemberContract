import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Admin, Campaign } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("Campaign contract", function () {
  let campaignContract: Campaign;
  let owner: SignerWithAddress;

  beforeEach(async function () {
    const Campaign = await ethers.getContractFactory("Campaign"); // Adjust the contract name
    campaignContract = await Campaign.deploy();
    await campaignContract.deployed();

    [owner] = await ethers.getSigners();
  });

  it("Should create campaign", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1699944892,
      1700031292
    );

    const campaign = await campaignContract.getAllCampaign();

    expect(campaign[0]).to.equal(0);
  });

  it("Should get current campaign", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1699944892,
      1700031292
    );

    const campaign = await campaignContract.getAllCampaign();
    const hasCampaignRunning = await campaignContract.hasCampaignRunning(
      1699944892,
      1700031292
    );
    const currentCampaign = await campaignContract.getCampaignByPeriod(
      "running"
    );

    expect(campaign[0]).to.equal(0);
    expect(hasCampaignRunning).to.equal(true);
    expect(currentCampaign[0]).to.equal(0);
  });

  it("Should get past campaign", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1699685692,
      1699858492
    );

    const campaign = await campaignContract.getAllCampaign();
    const currentCampaign = await campaignContract.getCampaignByPeriod("past");

    expect(campaign[0]).to.equal(0);
    expect(currentCampaign[0]).to.equal(0);
  });

  it("Should get upcoming campaign", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1700117692,
      1700204092
    );

    const campaign = await campaignContract.getAllCampaign();
    const currentCampaign = await campaignContract.getCampaignByPeriod(
      "upcoming"
    );

    expect(campaign[0]).to.equal(0);
    expect(currentCampaign[0]).to.equal(0);
  });

  it("Should get campaign info", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1700117692,
      1700204092
    );

    const campaign = await campaignContract.getCampaignInfo(0);

    expect(campaign.name).to.equal("test");
    expect(campaign.description).to.equal("test");
    expect(campaign.baseURI).to.equal("test");
    expect(campaign.timeStart).to.equal(1700117692);
    expect(campaign.timeEnd).to.equal(1700204092);
  });

  it("Should revert", async function () {
    // Mint an NFT
    await campaignContract.createCampaign(
      "test",
      "test",
      "test",
      1699944892,
      1700031292
    );

    await expect(
      campaignContract.createCampaign(
        "test",
        "test",
        "test",
        1699944892,
        1700031292
      )
    ).to.be.revertedWith("has campaign running");
  });
});
