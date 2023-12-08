import hre, { ethers } from "hardhat";
import { saveAddresses, getAddressList } from "../utils/address";

async function main() {
  const addressList = await getAddressList(hre.network.name);

  // deploy Campaign
  // const CampaignFactory = await ethers.getContractFactory("Campaign");
  // const Campaign = await CampaignFactory.deploy();
  // await Campaign.deployed();

  // // deploy CryptoCoffPoint
  // const CryptoCoffPointFactory = await ethers.getContractFactory(
  //   "CryptoCoffPoint"
  // );
  // const CryptoCoffPoint = await CryptoCoffPointFactory.deploy(Campaign.address);
  // await CryptoCoffPoint.deployed();

  // // deploy CryptoCoffMember
  // const CryptoCoffMemberFactory = await ethers.getContractFactory(
  //   "CryptoCoffMember"
  // );
  // const CryptoCoffMember = await CryptoCoffMemberFactory.deploy(
  //   CryptoCoffPoint.address
  // );
  // await CryptoCoffMember.deployed();

  // deploy ExpiredClaim
  const ExpiredClaimFactory = await ethers.getContractFactory("ExpiredClaim");
  console.log(addressList.Campaign, addressList.CryptoCoffPoint);

  const ExpiredClaim = await ExpiredClaimFactory.deploy(
    addressList.Campaign,
    addressList.CryptoCoffPoint,
    60 * 1 // 1 minutes
  );
  await ExpiredClaim.deployed();

  // deploy MemberEmitLog
  // const MemberEmitLogFactory = await ethers.getContractFactory("MemberEmitLog");
  // const MemberEmitLog = await MemberEmitLogFactory.deploy();
  // await MemberEmitLog.deployed();

  await saveAddresses(hre.network.name, {
    // Campaign: Campaign.address,
    // CryptoCoffPoint: CryptoCoffPoint.address,
    // CryptoCoffMember: CryptoCoffMember.address,
    // MemberEmitLog: MemberEmitLog.address,
    ExpiredClaim: ExpiredClaim.address,
  });

  // console.log(`Campaign deployed to ${Campaign.address}`);
  // console.log(`CryptoCoffPoint deployed to ${CryptoCoffPoint.address}`);
  // console.log(`CryptoCoffMember deployed to ${CryptoCoffMember.address}`);
  // console.log(`MemberEmitLog deployed to ${MemberEmitLog.address}`);
  console.log(`ExpiredClaim deployed to ${ExpiredClaim.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
