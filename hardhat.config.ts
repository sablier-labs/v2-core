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
    tangle: {
      chainId: 5845,
      url: "https://rpc.tangle.tools",
      accounts: [deployPrivateKey],
    },
  },
  etherscan: {
    apiKey: {
      tangle: "empty",
    },
    customChains: [
      {
        network: "tangle",
        chainId: 5845,
        urls: {
          apiURL: "https://explorer.tangle.tools/api",
          browserURL: "http://explorer.tangle.tools",
        },
      },
    ],
  },
};
