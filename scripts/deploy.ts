import hre, { ethers } from "hardhat";
import { saveAddresses } from "../utils/address";

async function main() {
  // deploy CryptoCoffMember
  const CryptoCoffMemberFactory = await ethers.getContractFactory(
    "CryptoCoffMember"
  );
  const CryptoCoffMember = await CryptoCoffMemberFactory.deploy();
  await CryptoCoffMember.deployed();

  // deploy MemberEmitLog
  const MemberEmitLogFactory = await ethers.getContractFactory("MemberEmitLog");
  const MemberEmitLog = await MemberEmitLogFactory.deploy();
  await MemberEmitLog.deployed();

  await saveAddresses(hre.network.name, {
    CryptoCoffMember: CryptoCoffMember.address,
    MemberEmitLog: MemberEmitLog.address,
  });

  console.log(`CryptoCoffMember deployed to ${CryptoCoffMember.address}`);
  console.log(`MemberEmitLog deployed to ${MemberEmitLog.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
