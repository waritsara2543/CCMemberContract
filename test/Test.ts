import { ExpiredClaim, CryptoCoffPoint, Campaign } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("YourContract", function () {
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
  });

  it("Test", async function () {
    const currentTime = Math.floor(Date.now() / 1000);
    const timeEnd = currentTime + 10; // Set the campaign end time to 10 seconds ahead
    const oneDay = 1 * 24 * 60 * 60; // Seven days in seconds

    await campaignContract.createCampaign(
      "test",
      "test",
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/",
      1701921651,
      timeEnd,
      10
    );

    await campaignContract.createCampaign(
      "test",
      "test",
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/",
      timeEnd,
      timeEnd + oneDay,
      10
    );

    let running = await campaignContract.getCampaignByPeriod("running");
    console.log("running ===>", running);
    addPointContract.addPoint(owner.address, 9, 0);
    const tokenURI0Before = await addPointContract.tokenURI(0);
    console.log("tokenURI0Before ===> ", tokenURI0Before);

    expect(tokenURI0Before).to.equal(
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/9point.json"
    );

    await ethers.provider.send("evm_increaseTime", [oneDay]);
    await ethers.provider.send("evm_mine", []); // Mine a new block to ensure the timestamp update

    addPointContract.addPoint(owner.address, 9, 1);
    const tokenURI1Before = await addPointContract.tokenURI(1);
    console.log("tokenURI1Before ===> ", tokenURI1Before);

    expect(tokenURI1Before).to.equal(
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/9point.json"
    );

    // Fast-forward time by seven days
    await ethers.provider.send("evm_increaseTime", [oneDay * 7]);
    await ethers.provider.send("evm_mine", []); // Mine a new block to ensure the timestamp update

    const Past = await campaignContract.getCampaignByPeriod("past");
    console.log("Past ===> ", Past);

    const token = await addPointContract.getTokenOfOwnerByIndex(owner.address);
    console.log("token ===> ", token);

    await expiredClaimContract.updateExpireClaim();

    const tokenURI0After = await addPointContract.tokenURI(0);
    console.log("tokenURIAfter ===> ", tokenURI0After);

    expect(tokenURI0After).to.equal(
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/expired.json"
    );

    const tokenURI1After = await addPointContract.tokenURI(1);
    console.log("tokenURIAfter ===> ", tokenURI1After);

    expect(tokenURI1After).to.equal(
      "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/expired.json"
    );
  });
});
