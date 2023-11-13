import hre, { ethers } from "hardhat";
import { saveAddresses, getAddressList } from "../utils/address";

async function main() {
  const addressList = await getAddressList(hre.network.name);

  // deploy CryptoCoffPoint
  const CryptoCoffPointFactory = await ethers.getContractFactory(
    "CryptoCoffPoint"
  );
  const CryptoCoffPoint = await CryptoCoffPointFactory.deploy();
  await CryptoCoffPoint.deployed();

  // deploy CryptoCoffMember
  // const CryptoCoffMemberFactory = await ethers.getContractFactory(
  //   "CryptoCoffMember"
  // );
  // const CryptoCoffMember = await CryptoCoffMemberFactory.deploy(
  //   CryptoCoffPoint.address
  // );
  // await CryptoCoffMember.deployed();

  // deploy MemberEmitLog
  // const MemberEmitLogFactory = await ethers.getContractFactory("MemberEmitLog");
  // const MemberEmitLog = await MemberEmitLogFactory.deploy();
  // await MemberEmitLog.deployed();

  await saveAddresses(hre.network.name, {
    CryptoCoffPoint: CryptoCoffPoint.address,
    // CryptoCoffMember: CryptoCoffMember.address,
    // MemberEmitLog: MemberEmitLog.address,
  });
  console.log(`CryptoCoffPoint deployed to ${CryptoCoffPoint.address}`);
  // console.log(`CryptoCoffMember deployed to ${CryptoCoffMember.address}`);
  // console.log(`MemberEmitLog deployed to ${MemberEmitLog.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
