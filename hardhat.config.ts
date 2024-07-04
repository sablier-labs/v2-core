import * as dotenv from "dotenv";

require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

dotenv.config();

let deployPrivateKey = process.env.PV_KEY as string;
if (!deployPrivateKey) {
  // default first account deterministically created by local nodes like `npx hardhat node` or `anvil`
  throw "No deployer private key set in .env";
}

module.exports = {
  solidity: {
    version: "0.8.20",
    evmVersion: "shanghai",
    settings: {
      optimizer: {
        enabled: true,
        runs: 500,
      },
      viaIR: true,
    },
    // @ts-ignore
  },
  networks: {
    iotex: {
      chainId: 4689,
      url: "https://babel-api.mainnet.iotex.io",
      accounts: [deployPrivateKey],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY as string,
    customChains: [
      {
        network: "iotex",
        chainId: 4689,
        urls: {
          apiURL: "https://IoTeXscout.io/api",
          browserURL: "https://IoTeXscan.io",
        },
      },
    ],
  },
};
