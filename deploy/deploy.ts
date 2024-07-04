import { Addressable } from "ethers";
import hre from "hardhat";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { Wallet, Provider } from "zksync-ethers";

export default async function () {
  const network = await hre.network.config;
  const networkName = await hre.network.name;
  const chainId = Number(network.chainId);

  const provider = new Provider(hre.network.config.url);
  const deployerAddressPV = new Wallet(process.env.PV_KEY as string).connect(provider);
  const deployerAddress = deployerAddressPV.address;

  if (!deployerAddress) {
    console.error("Please set the PV_KEY in your .env file");
    return;
  }

  console.table({
    contract: "SablierV2NFTDescriptor & SablierV2LockupDynamic & SablierV2LockupLinear & SablierV2LockupTranched",
    chainId: chainId,
    network: networkName,
    deployerAddress: deployerAddress,
  });

  const deployer = new Deployer(hre, deployerAddressPV);

  const artifactSVG = await deployer.loadArtifact("NFTSVG");
  const artifactSVGElements = await deployer.loadArtifact("SVGElements");
  const artifactNFTDescriptor = await deployer.loadArtifact("SablierV2NFTDescriptor");
  const artifactLockupDynamic = await deployer.loadArtifact("SablierV2LockupDynamic");
  const artifactLockupLinear = await deployer.loadArtifact("SablierV2LockupLinear");
  const artifactLockupTranched = await deployer.loadArtifact("SablierV2LockupTranched");

  const safeMultisig = "0xaFeA787Ef04E280ad5Bb907363f214E4BAB9e288";

  const svg = await deployer.deploy(artifactSVG, []);
  console.log("NFTSVG deployed to:", svg.target);
  const svg_element = await deployer.deploy(artifactSVGElements, []);
  console.log("SVGElements deployed to:", svg_element.target);

  const nftDescriptor = await deployer.deploy(artifactNFTDescriptor, []);
  const nftDescriptorAddress =
    typeof nftDescriptor.target === "string" ? nftDescriptor.target : nftDescriptor.target.toString();
  console.log("SablierV2NFTDescriptor deployed to:", nftDescriptorAddress);
  await verifyContract(nftDescriptorAddress, []);

  // Deploy the SablierV2LockupDynamic contract
  const dynamic = await deployer.deploy(artifactLockupDynamic, [safeMultisig, nftDescriptorAddress, "2000"]);
  const dynamicAddress = typeof dynamic.target === "string" ? dynamic.target : dynamic.target.toString();
  console.log("SablierV2LockupDynamic deployed to:", dynamicAddress);
  await verifyContract(dynamicAddress, [safeMultisig, nftDescriptorAddress, "2000"]);

  // Deploy the SablierV2LockupLinear contract
  const linear = await deployer.deploy(artifactLockupLinear, [safeMultisig, nftDescriptorAddress]);
  const linearAddress = linear.target;
  console.log("SablierV2LockupLinear deployed to:", linearAddress);
  await verifyContract(linearAddress, [safeMultisig, nftDescriptorAddress]);

  // Deploy the SablierV2LockupTranched contract
  const tranched = await deployer.deploy(artifactLockupTranched, [safeMultisig, nftDescriptorAddress, "2000"]);
  const tranchedAddress = tranched.target;
  console.log("SablierV2LockupTranched deployed to:", tranchedAddress);
  await verifyContract(tranchedAddress, [safeMultisig, nftDescriptorAddress, "2000"]);
}

const verifyContract = async (contractAddress: string | Addressable, verifyArgs: string[]): Promise<boolean> => {
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
