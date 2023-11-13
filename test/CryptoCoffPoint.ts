import { expect } from "chai";
import { CryptoCoffPoint } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

describe("Add point contract", function () {
  let addPointContract: CryptoCoffPoint;
  let owner: SignerWithAddress;
  const baseURI =
    "https://lime-isolated-chinchilla-728.mypinata.cloud/ipfs/QmZZKCwCwEXrzhPs7r7ZcHv5V6rGXAQpdCgWgwFnV67PTJ/";

  beforeEach(async function () {
    const CryptoCoffPoint = await ethers.getContractFactory("CryptoCoffPoint"); // Adjust the contract name
    addPointContract = await CryptoCoffPoint.deploy();
    await addPointContract.deployed();

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
    await addPointContract.safeMint(owner.address, 1);

    // Add points to the NFT
    await addPointContract.addPoint(owner.address, 8);

    // Get the tokenURI
    const tokenURI = await addPointContract.tokenURI(0);

    // Check if points are correctly added
    expect(tokenURI).to.equal(`${baseURI}9point.json`);
  });

  it("Should mint new NFTs", async function () {
    // Mint an NFT
    await addPointContract.safeMint(owner.address, 9);

    // add points to the NFT
    await addPointContract.addPoint(owner.address, 2);

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);

    // Check if points are correctly added
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}2point.json`);
  });

  it("Should add points to an NFT and mint new NFT", async function () {
    // Mint an NFT
    await addPointContract.safeMint(owner.address, 1);

    // Add points to the NFT
    await addPointContract.addPoint(owner.address, 9);

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);

    // Check if points are correctly added
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}1point.json`);
  });

  it("Should mint 3 Nfts", async function () {
    // Mint an NFT
    await addPointContract.addPoint(owner.address, 20);

    // Get the tokenURI
    const tokenURI0 = await addPointContract.tokenURI(0);
    const tokenURI1 = await addPointContract.tokenURI(1);
    const tokenURI2 = await addPointContract.tokenURI(2);

    // Check if points are correctly added
    expect(tokenURI0).to.equal(`${baseURI}9point.json`);
    expect(tokenURI1).to.equal(`${baseURI}9point.json`);
    expect(tokenURI2).to.equal(`${baseURI}2point.json`);
  });
});
