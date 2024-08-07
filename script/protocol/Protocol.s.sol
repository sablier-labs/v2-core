// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { stdJson } from "forge-std/src/StdJson.sol";

import { BaseScript } from "../Base.s.sol";

/// @dev This contract creates a Markdown file with the deployed addresses with the format used in docs:
/// https://docs.sablier.com/contracts/v2/deployments
abstract contract ProtocolScript is BaseScript {
    using stdJson for string;
    using Strings for address;
    using Strings for string;
    using Strings for uint256;

    /// @dev The path to the file where the deployment addresses are stored.
    string internal deploymentFile;

    /// @dev Admin address mapped by the chain Id.
    mapping(uint256 chainId => address admin) internal adminMap;

    /// @dev Explorer URL mapped by the chain Id.
    mapping(uint256 chainId => string explorerUrl) internal explorerMap;

    constructor(string memory deterministicOrNot) {
        // Populate the admin map.
        populateAdminMap();

        // Populate the explorer URLs.
        populateExplorerMap();

        // If there is no admin set for a specific chain, use the Sablier deployer.
        if (adminMap[block.chainid] == address(0)) {
            adminMap[block.chainid] = SABLIER_DEPLOYER;
        }

        // If there is no explorer URL set for a specific chain, use a placeholder.
        if (explorerMap[block.chainid].equal("")) {
            explorerMap[block.chainid] = "<explorer_url_missing>";
        }

        // Create the deployment directory if it doesn't exist. This requires `--ffi` flag.
        if (!vm.isDir("deployments")) {
            string[] memory mkDirCommand = new string[](2);
            mkDirCommand[0] = "mkdir";
            mkDirCommand[1] = "deployments";
            vm.ffi(mkDirCommand);
        }

        // Set the deployment file path.
        deploymentFile = string.concat("deployments/", block.chainid.toString(), "_", deterministicOrNot, ".md");

        // TODO: if the file exists, first save a copy of it with a different name, then overwrite it.
        // if (vm.isFile(deploymentFile)) {
        //     deploymentFile = string.concat(deploymentFile, ".md");
        // }

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: deploymentFile,
            data: string.concat("# Deployed Addresses for chain ", block.chainid.toString(), "\n\n")
        });
    }

    /// @dev Function to append the deployed addresses to the deployment file.
    function appendToFileDeployedAddresses(
        address lockupDynamic,
        address lockupLinear,
        address lockupTranched,
        address nftDescriptor,
        address batchLockup,
        address merkleFactory
    )
        internal
    {
        string memory coreTitle = " ### Core\n\n";
        _appendToFile(coreTitle);

        string memory firstTwoLines = "| Contract | Address | Deployment |\n | :------- | :------ | :----------|";
        _appendToFile(firstTwoLines);

        string memory lockupDynamicLine = _getContractLine({
            contractName: "SablierLockupDynamic",
            contractAddress: lockupDynamic.toHexString(),
            coreOrPeriphery: "core"
        });
        _appendToFile(lockupDynamicLine);

        string memory lockupLinearLine = _getContractLine({
            contractName: "SablierLockupLinear",
            contractAddress: lockupLinear.toHexString(),
            coreOrPeriphery: "core"
        });
        _appendToFile(lockupLinearLine);

        string memory lockupTranchedLine = _getContractLine({
            contractName: "SablierLockupTranched",
            contractAddress: lockupTranched.toHexString(),
            coreOrPeriphery: "core"
        });
        _appendToFile(lockupTranchedLine);

        string memory nftDescriptorLine = _getContractLine({
            contractName: "SablierNFTDescriptor",
            contractAddress: nftDescriptor.toHexString(),
            coreOrPeriphery: "core"
        });
        _appendToFile(nftDescriptorLine);

        string memory peripheryTitle = "\n ### Periphery\n\n";
        _appendToFile(peripheryTitle);
        _appendToFile(firstTwoLines);

        string memory batchLockupLine = _getContractLine({
            contractName: "SablierBatchLockup",
            contractAddress: batchLockup.toHexString(),
            coreOrPeriphery: "periphery"
        });
        _appendToFile(batchLockupLine);

        string memory merkleFactoryLine = _getContractLine({
            contractName: "MerkleFactory",
            contractAddress: merkleFactory.toHexString(),
            coreOrPeriphery: "periphery"
        });
        _appendToFile(merkleFactoryLine);
    }

    /// @dev Append a line to the deployment file path.
    function _appendToFile(string memory line) private {
        vm.writeLine({ path: deploymentFile, data: line });
    }

    function _getContractLine(
        string memory contractName,
        string memory contractAddress,
        string memory coreOrPeriphery
    )
        private
        view
        returns (string memory)
    {
        string memory version = getVersion();
        version = string.concat("v", version);

        return string.concat(
            "| ",
            contractName,
            " | [",
            contractAddress,
            "](",
            explorerMap[block.chainid],
            contractAddress,
            ") | [",
            coreOrPeriphery,
            "-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/",
            coreOrPeriphery,
            "/",
            version,
            ") |"
        );
    }

    /// @dev Populates the admin map.
    function populateAdminMap() internal {
        adminMap[42_161] = 0xF34E41a6f6Ce5A45559B1D3Ee92E141a3De96376; // Arbitrum
        adminMap[43_114] = 0x4735517616373c5137dE8bcCDc887637B8ac85Ce; // Avalanche
        adminMap[8453] = 0x83A6fA8c04420B3F9C7A4CF1c040b63Fbbc89B66; // Base
        adminMap[56] = 0x6666cA940D2f4B65883b454b7Bc7EEB039f64fa3; // BNB
        adminMap[100] = 0x72ACB57fa6a8fa768bE44Db453B1CDBa8B12A399; // Gnosis
        adminMap[1] = 0x79Fb3e81aAc012c08501f41296CCC145a1E15844; // Mainnet
        adminMap[59_144] = 0x72dCfa0483d5Ef91562817C6f20E8Ce07A81319D; // Linea
        adminMap[10] = 0x43c76FE8Aec91F63EbEfb4f5d2a4ba88ef880350; // Optimism
        adminMap[137] = 0x40A518C5B9c1d3D6d62Ba789501CE4D526C9d9C6; // Polygon
        adminMap[534_352] = 0x0F7Ad835235Ede685180A5c611111610813457a9; // Scroll
    }

    /// @dev Populates the explorer map.
    function populateExplorerMap() internal {
        explorerMap[42_161] = "https://arbiscan.io/address/";
        explorerMap[43_114] = "https://snowtrace.io/address/";
        explorerMap[8453] = "https://basescan.org/address/";
        explorerMap[84_532] = "https://sepolia.basescan.org/address/";
        explorerMap[81_457] = "https://blastscan.io/address/";
        explorerMap[168_587_773] = "https://sepolia.blastscan.io/address/";
        explorerMap[56] = "https://bscscan.com/address/";
        explorerMap[1] = "https://etherscan.io/address/";
        explorerMap[100] = "https://gnosisscan.io/address/";
        explorerMap[59_144] = "https://lineascan.build/address/";
        explorerMap[59_141] = "https://sepolia.lineascan.build/address/";
        explorerMap[1890] = "https://phoenix.lightlink.io/address/";
        explorerMap[34_443] = "https://explorer.mode.network/address/";
        explorerMap[919] = "https://sepolia.explorer.mode.network/address/";
        explorerMap[333_000_333] = "https://meldscan.io/address/";
        explorerMap[10] = "https://optimistic.etherscan.io/address/";
        explorerMap[11_155_420] = "https://sepolia-optimistic.etherscan.io/address/";
        explorerMap[137] = "https://polygonscan.com/address/";
        explorerMap[534_352] = "https://scrollscan.com/address/";
        explorerMap[11_155_111] = "https://sepolia.etherscan.io/address/";
    }
}
