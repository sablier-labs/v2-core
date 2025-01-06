import * as dotenv from "dotenv";

import "@nomicfoundation/hardhat-foundry";
import "@matterlabs/hardhat-zksync";
import "@nomiclabs/hardhat-solhint";
import "@typechain/hardhat";
import fs from "fs";
import "hardhat-preprocessor";
import { HardhatUserConfig } from "hardhat/config";

dotenv.config();

let deployPrivateKey = process.env.PRIVATE_KEY as string;
if (!deployPrivateKey) {
  // default first account deterministically created by local nodes like `npx hardhat node` or `anvil`
  throw "No deployer private key set in .env";
}

/**
 * Generates hardhat network configuration
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
      viaIR: true,
    },
    // @ts-ignore
  },
  defaultNetwork: "abstractMainnet",
  networks: {
    abstractMainnet: {
      url: "https://api.raas.matterhosted.dev",
      ethNetwork: "mainnet",
      zksync: true,
      chainId: 2741,
    },
  },
  paths: {
    sources: "./contracts",
    cache: "./cache_hardhat",
  },
  etherscan: {
    apiKey: {
      abstractMainnet: "IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A",
    },
    customChains: [
      {
        network: "abstractMainnet",
        chainId: 2741,
        urls: {
          apiURL: "https://api.abscan.org/api",
          browserURL: "https://explorer.mainnet.abs.xyz/",
        },
      },
    ],
  },
  zksolc: {
    version: "1.5.7",
    settings: {
      enableEraVMExtensions: false,
      optimizer: {
        enabled: true,
        mode: "z",
        fallback_to_optimizing_for_size: true,
      },
    },
  },
};

export default config;
