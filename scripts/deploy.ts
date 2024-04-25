import { Addressable } from "ethers";
import hre, { ethers} from "hardhat";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { Wallet } from "zksync-ethers";

async function main() {
    const network = await hre.network.config;
    const networkName = await hre.network.name;
    const chainId = Number(network.chainId);

    const deployerAddressPV  = new Wallet(process.env.PV_KEY as string);
    
    
    const deployerAddress = deployerAddressPV.address;

    if (!deployerAddress) {
      console.error("Please set the PV_KEY in your .env file");
      return;
    }
  
    console.table({
      contract: "SablierV2Comptroller & SablierV2NFTDescriptor & SablierV2LockupDynamic & SablierV2LockupLinear",
      chainId: chainId,
      network: networkName,
      deployerAddress: deployerAddress,
    });

    const deployer = new Deployer(hre, deployerAddressPV);

    const artifactComptroller = await deployer.loadArtifact("SablierV2Comptroller");
    const artifactNFTDescriptor = await deployer.loadArtifact("SablierV2NFTDescriptor");
    const artifactLockupDynamic = await deployer.loadArtifact("SablierV2LockupDynamic");
    const artifactLockupLinear = await deployer.loadArtifact("SablierV2LockupLinear");

    // Deploy the SablierV2Comptroller contract
    const comptroller = await deployer.deploy(artifactComptroller, [deployerAddress]);
    const comptrollerAddress = comptroller.target;
    console.log("SablierV2Comptroller deployed to:", comptrollerAddress);
    await verifyContract(comptrollerAddress, [deployerAddress]);

    // Deploy the SablierV2NFTDescriptor contract
    const nftDescriptor = await deployer.deploy(artifactNFTDescriptor, []);
    const nftDescriptorAddress = nftDescriptor.target;
    console.log("SablierV2NFTDescriptor deployed to:", nftDescriptorAddress);
    await verifyContract(nftDescriptorAddress, []);


    // Deploy the SablierV2LockupDynamic contract
    const maxSegmentCount = 300;
    const dynamic = await deployer.deploy(artifactLockupDynamic, [deployerAddress, comptrollerAddress, nftDescriptorAddress, maxSegmentCount]);
    const dynamicAddress = dynamic.target;
    console.log("SablierV2LockupDynamic deployed to:", dynamicAddress);
    await verifyContract(dynamicAddress, [deployerAddress, comptrollerAddress, nftDescriptorAddress, maxSegmentCount]);

    // // Deploy the SablierV2LockupLinear contract
    const linear = await deployer.deploy(artifactLockupLinear, [deployerAddress, comptrollerAddress, nftDescriptorAddress]);
    const linearAddress = linear.target;
    console.log("SablierV2LockupLinear deployed to:", linearAddress);
    await verifyContract(linearAddress, [deployerAddress, deployerAddress, deployerAddress]);
}

const verifyContract = async (
    contractAddress: string | Addressable,
    verifyArgs: string[],
  ): Promise<boolean> => {
    console.log("\nVerifying contract...");
    await new Promise((r) => setTimeout(r, 20000));
    try {
      await hre.run("verify:verify", {
        address: contractAddress.toString(),
        constructorArguments: verifyArgs,
        noCompile: true,
      });
    } catch (e) {
      console.log(e);
    }
    return true;
  };
  
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
