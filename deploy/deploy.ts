import { ethers, run } from "hardhat";

async function main() {
  // Admin address
  const initialAdmin = "0xb1bef51ebca01eb12001a639bdbbff6eeca12b9f";

  const SablierV2NFTDescriptor = await ethers.getContractFactory("SablierV2NFTDescriptor");
  const nftDescriptor = await SablierV2NFTDescriptor.deploy();

  await nftDescriptor.deployed();
  console.log("SablierV2NFTDescriptor deployed to:", nftDescriptor.address);

  const maxCount = 500;

  // Deploy SablierV2LockupDynamic contract with the deployed NFT descriptor address
  const SablierV2LockupDynamic = await ethers.getContractFactory("SablierV2LockupDynamic");
  const lockupDynamic = await SablierV2LockupDynamic.deploy(initialAdmin, nftDescriptor.address, maxCount);

  await lockupDynamic.deployed();
  console.log("SablierV2LockupDynamic deployed to:", lockupDynamic.address);

  // Deploy SablierV2LockupLinear contract with the deployed NFT descriptor address
  const SablierV2LockupLinear = await ethers.getContractFactory("SablierV2LockupLinear");
  const lockupLinear = await SablierV2LockupLinear.deploy(initialAdmin, nftDescriptor.address);

  await lockupLinear.deployed();
  console.log("SablierV2LockupLinear deployed to:", lockupLinear.address);

  // Deploy SablierV2LockupTranched contract with the deployed NFT descriptor address
  const SablierV2LockupTranched = await ethers.getContractFactory("SablierV2LockupTranched");
  const lockupTranched = await SablierV2LockupTranched.deploy(initialAdmin, nftDescriptor.address, maxCount);

  await lockupTranched.deployed();
  console.log("SablierV2LockupTranched deployed to:", lockupTranched.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
