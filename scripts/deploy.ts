import { Addressable } from "ethers";
import hre, {ethers} from "hardhat";
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

    const safeMultisig = "0xaFeA787Ef04E280ad5Bb907363f214E4BAB9e288";

    // Deploy the SablierV2Comptroller contract
    const comptroller = await deployer.deploy(artifactComptroller, [safeMultisig]);
    const comptrollerAddress = typeof comptroller.target === 'string' ? comptroller.target : comptroller.target.toString();
    console.log("SablierV2Comptroller deployed to:", comptrollerAddress);
    await verifyContract(comptrollerAddress, [safeMultisig]);

    // Deploy the SablierV2NFTDescriptor contract
    const nftDescriptor = await deployer.deploy(artifactNFTDescriptor, []);
    const nftDescriptorAddress = typeof nftDescriptor.target === 'string' ? nftDescriptor.target : nftDescriptor.target.toString();
    console.log("SablierV2NFTDescriptor deployed to:", nftDescriptorAddress);
    await verifyContract(nftDescriptorAddress, []);

    // Deploy the SablierV2LockupDynamic contract
    const dynamic = await deployer.deploy(artifactLockupDynamic, [safeMultisig, comptrollerAddress, nftDescriptorAddress, "300"]);
    const dynamicAddress = typeof dynamic.target === 'string' ? dynamic.target : dynamic.target.toString();
    console.log("SablierV2LockupDynamic deployed to:", dynamicAddress);
    await verifyContract(dynamicAddress, [safeMultisig, comptrollerAddress, nftDescriptorAddress, "300"]);

    // Deploy the SablierV2LockupLinear contract
    const linear = await deployer.deploy(artifactLockupLinear, [safeMultisig, comptrollerAddress, nftDescriptorAddress]);
    const linearAddress = linear.target;
    console.log("SablierV2LockupLinear deployed to:", linearAddress);
    await verifyContract(linearAddress, [safeMultisig, comptrollerAddress, nftDescriptorAddress]);
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
