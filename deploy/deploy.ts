import { ethers, run } from "hardhat";

async function main() {
  // Admin address
  const initialAdmin = "0xb1bef51ebca01eb12001a639bdbbff6eeca12b9f";

  console.log("Deploying LockupNFTDescriptor...");
  const lockupNFTDescriptor = await ethers.getContractFactory("LockupNFTDescriptor");
  const nftDescriptor = await lockupNFTDescriptor.deploy();
  await nftDescriptor.deployed();
  console.log("LockupNFTDescriptor deployed to:", nftDescriptor.address);

  await verifyContract(nftDescriptor.address, []);

  // Deploy Helpers library
  console.log("Deploying Helpers library...");
  const helpersLib = await ethers.getContractFactory("Helpers");
  const helpers = await helpersLib.deploy();
  await helpers.deployed();
  console.log("Helpers library deployed to:", helpers.address);
  await verifyContract(helpers.address, []);

  // Deploy VestingMath library
  console.log("Deploying VestingMath library...");
  const vestingMathLib = await ethers.getContractFactory("VestingMath");
  const vestingMath = await vestingMathLib.deploy();
  await vestingMath.deployed();
  console.log("VestingMath library deployed to:", vestingMath.address);
  await verifyContract(vestingMath.address, []);

  // Deploy SablierLockup contract
  console.log("Deploying SablierLockup...");
  const sablierLockup = await ethers.getContractFactory("SablierLockup", {
    libraries: {
      Helpers: helpers.address,
      VestingMath: vestingMath.address,
    },
  });
  const lockup = await sablierLockup.deploy(initialAdmin, nftDescriptor.address, "500");
  await lockup.deployed();
  console.log("SablierLockup deployed to:", lockup.address);

  await verifyContract(lockup.address, [initialAdmin, nftDescriptor.address, "500"]);

  // Deploy BatchLockup contract
  console.log("Deploying BatchLockup...");
  const batchLockup = await ethers.getContractFactory("SablierBatchLockup");
  const batch = await batchLockup.deploy();
  await batch.deployed();
  console.log("BatchLockup deployed to:", batch.address);

  await verifyContract(batch.address, []);
}

// Helper function to verify a contract
async function verifyContract(address: string, constructorArgs: any[]) {
  console.log(`Verifying contract at address: ${address}`);
  try {
    await run("verify:verify", {
      address,
      constructorArguments: constructorArgs,
    });
    console.log(`Contract verified successfully: ${address}`);
  } catch (error: any) {
    if (error.message.includes("Already Verified")) {
      console.log(`Contract at ${address} is already verified`);
    } else {
      console.error(`Failed to verify contract at ${address}:`, error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
