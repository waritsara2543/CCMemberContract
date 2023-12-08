import { ExpiredClaim, CryptoCoffPoint, Campaign } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { AbiCoder } from "ethers/lib/utils";

describe("expiredClaim contract", function () {
  let expiredClaimContract: ExpiredClaim;
  let addPointContract: CryptoCoffPoint;
  let campaignContract: Campaign;
  let owner: SignerWithAddress;

  beforeEach(async function () {
    const Campaign = await ethers.getContractFactory("Campaign"); // Adjust the contract name
    campaignContract = await Campaign.deploy();
    await campaignContract.deployed();

    const CryptoCoffPoint = await ethers.getContractFactory("CryptoCoffPoint"); // Adjust the contract name
    addPointContract = await CryptoCoffPoint.deploy(campaignContract.address);
    await addPointContract.deployed();

    const expiredClaim = await ethers.getContractFactory("ExpiredClaim"); // Adjust the contract name
    expiredClaimContract = await expiredClaim.deploy(
      campaignContract.address,
      addPointContract.address,
      1
    );

    await expiredClaimContract.deployed();
    [owner] = await ethers.getSigners();

    // Create a campaign
    // const timeEnd = (new Date().getTime() / 1000 + 10).toFixed(0);
    // await campaignContract.createCampaign(
    //   "test",
    //   "test",
    //   "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/",
    //   1701921651,
    //   timeEnd,
    //   1
    // );
    // await addPointContract.addPoint(owner.address, 9, 0);
  });

  it("upkeep need must be false", async function () {
    const result = await expiredClaimContract.checkUpkeep([]);
    const upkeepNeeded = result.upkeepNeeded;
    const abiCoder = ethers.utils.defaultAbiCoder;
    const performData = abiCoder.decode(["bytes"], result.performData)[0];
    console.log(performData);

    expect(upkeepNeeded).to.equal(false);
  });

  //   it("upkeep need must be true", async function () {
  //     await new Promise((resolve) => setTimeout(resolve, 20000)); // wait 20 seconds
  //     const c = await campaignContract.getCampaignByPeriod("running");
  //     console.log("running", c);
  //     const result = await expiredClaimContract.checkUpkeep([]);
  //     console.log(result);
  //     const upkeepNeeded = result.upkeepNeeded;
  //     const abiCoder = ethers.utils.defaultAbiCoder;
  //     const performData = abiCoder.decode(["bytes"], result.performData)[0];
  //     expect(upkeepNeeded).to.equal(true);
  //   });

  //   it("getCampaignByPeriod should return campaigns in the 'Past' period", async function () {
  //     const timeEnd = Math.floor(Date.now() / 1000) + 1; // Set the end time 10 seconds ahead
  //     await campaignContract.createCampaign(
  //       "test",
  //       "test",
  //       "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/",
  //       1701921651,
  //       timeEnd,
  //       1
  //     );

  //     const pastCampaignsTest = await campaignContract.getCampaignByPeriod(
  //       "running"
  //     );

  //     await addPointContract.addPoint(owner.address, 9, 0);
  //     console.log("Running =====>", pastCampaignsTest);
  //     await new Promise((resolve) => setTimeout(resolve, 15000));
  //     const pastCampaigns = await campaignContract.getCampaignByPeriod("past");
  //     console.log("Past =====>", pastCampaigns);
  //     expect(pastCampaigns.length).to.be.greaterThan(0);
  //   });

  it("Test campaign lifecycle", async function () {
    // Check if there are campaigns in the "running" period before starting the test loop
    const runningCampaignsBefore = await campaignContract.getCampaignByPeriod(
      "running"
    );

    if (runningCampaignsBefore.length === 0) {
      console.log(
        "No campaigns in 'running' period. Proceeding with the test loop."
      );

      for (let i = 0; i < 5; i++) {
        const timeEnd = Math.floor(Date.now() / 1000) + 1; // Set the end time 1 second ahead

        // Create a campaign
        await campaignContract.createCampaign(
          "test",
          "test",
          "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/",
          1701921651,
          timeEnd,
          1
        );

        // Get campaigns in the "running" period
        const runningCampaigns = await campaignContract.getCampaignByPeriod(
          "running"
        );
        console.log(`Running Campaigns (${i + 1}):`, runningCampaigns);

        if (runningCampaigns.length > 0) {
          await addPointContract.addPoint(owner.address, 9, 0);

          await new Promise((resolve) => setTimeout(resolve, 10000));

          const pastCampaigns = await campaignContract.getCampaignByPeriod(
            "past"
          );

          console.log(`Past Campaigns (${i + 1}):`, pastCampaigns);
          expect(pastCampaigns.length).to.be.greaterThan(0);
        } else {
          console.log(
            "No campaigns in 'running' period. Skipping addPoint and 'past' check."
          );
        }
      }
    } else {
      console.log(
        "There are campaigns in 'running' period. Skipping test loop."
      );
    }
  });

  //   it("getCampaignByPeriod should return campaigns in the 'Past' period", async function () {
  //     await new Promise((resolve) => setTimeout(resolve, 20000));
  //     const pastCampaigns = await campaignContract.getCampaignByPeriod("past");
  //     console.log("pastCampaigns =====>", pastCampaigns);
  //     expect(pastCampaigns.length).to.be.greaterThan(0);
  //   });
});
