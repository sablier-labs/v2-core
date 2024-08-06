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
    string internal deploymentFile = string.concat("deployments/", block.chainid.toString(), ".md");

    /// @dev The version of the deployment.
    string internal version = getVersion();

    /// @dev Admin address mapped by the chain Id.
    mapping(uint256 chainId => address admin) internal adminMap;

    /// @dev Explorer URL mapped by the chain Id.
    mapping(uint256 chainId => string explorerUrl) internal explorerMap;

    constructor() {
        // Populate the admin map.
        populateAdminMap();

        // Populate the explorer URLs.
        populateExplorerMap();

        // If there is no admin set for a specific chain, use the Sablier deployer.
        if (adminMap[block.chainid] == address(0)) {
            adminMap[block.chainid] = SABLIER_DEPLOYER;
        }

        // If there is no explorer URL set for a specific chain, use a placeholder.
        if (Strings.equal(explorerMap[block.chainid], "")) {
            explorerMap[block.chainid] = "<explorer_url_missing>";
        }

        // Create the deployment file if it doesn't exist.
        if (!vm.isDir("deployments")) {
            string[] memory mkDirCommand = new string[](2);
            mkDirCommand[0] = "mkdir";
            mkDirCommand[1] = "deployments";
            vm.ffi(mkDirCommand);
        }

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: deploymentFile,
            data: string.concat("# Deployed Addresses for chain ", block.chainid.toString(), "\n\n")
        });
    }

    /// @dev Function to append the deployed addresses to the deployment file.
    function _appendToFileDeployedAddresses(
        address lockupDynamic,
        address lockupLinear,
        address lockupTranched,
        address nftDescriptor,
        address batchLockup,
        address merkleFactory
    )
        internal
    {
        string memory core = " ### Core\n\n";
        _appendToFile(core);

        string memory firstTwoLines = "| Contract | Address | Deployment |\n | :------- | :------ | :----------|";
        _appendToFile(firstTwoLines);

        string memory lockupDynamicHex = lockupDynamic.toHexString();
        string memory lockupDynamicLine = string.concat(
            "| SablierLockupDynamic | [",
            lockupDynamicHex,
            "](",
            explorerMap[block.chainid],
            lockupDynamicHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(lockupDynamicLine);

        string memory lockupLinearHex = lockupLinear.toHexString();
        string memory lockupLinearLine = string.concat(
            "| SablierLockupLinear | [",
            lockupLinearHex,
            "](",
            explorerMap[block.chainid],
            lockupLinearHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(lockupLinearLine);

        string memory lockupTranchedHex = lockupTranched.toHexString();
        string memory lockupTranchedLine = string.concat(
            "| SablierLockupTranched | [",
            lockupTranchedHex,
            "](",
            explorerMap[block.chainid],
            lockupTranchedHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(lockupTranchedLine);

        string memory nftDescriptorHex = nftDescriptor.toHexString();
        string memory nftDescriptorLine = string.concat(
            "| LockupNFTDescriptor | [",
            nftDescriptorHex,
            "](",
            explorerMap[block.chainid],
            nftDescriptorHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(nftDescriptorLine);

        string memory periphery = "\n ### Periphery\n\n";
        _appendToFile(periphery);
        _appendToFile(firstTwoLines);

        string memory batchLockupHex = batchLockup.toHexString();
        string memory batchLockupLine = string.concat(
            "| SablierBatchLockup | [",
            batchLockupHex,
            "](",
            explorerMap[block.chainid],
            batchLockupHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(batchLockupLine);

        string memory merkleFactoryHex = merkleFactory.toHexString();
        string memory merkleFactoryLine = string.concat(
            "| SablierMerkleFactory | [",
            merkleFactoryHex,
            "](",
            explorerMap[block.chainid],
            merkleFactoryHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(merkleFactoryLine);
    }

    /// @dev Append a line to the deployment file path.
    function _appendToFile(string memory line) internal {
        vm.writeLine({ path: deploymentFile, data: line });
    }

    /// @dev Populates the admin map.
    function populateAdminMap() internal {
        adminMap[42_161] = 0xF34E41a6f6Ce5A45559B1D3Ee92E141a3De96376;
        adminMap[43_114] = 0x4735517616373c5137dE8bcCDc887637B8ac85Ce;
        adminMap[8453] = 0x83A6fA8c04420B3F9C7A4CF1c040b63Fbbc89B66;
        adminMap[56] = 0x6666cA940D2f4B65883b454b7Bc7EEB039f64fa3;
        adminMap[100] = 0x72ACB57fa6a8fa768bE44Db453B1CDBa8B12A399;
        adminMap[1] = 0x79Fb3e81aAc012c08501f41296CCC145a1E15844;
        adminMap[10] = 0x43c76FE8Aec91F63EbEfb4f5d2a4ba88ef880350;
        adminMap[137] = 0x40A518C5B9c1d3D6d62Ba789501CE4D526C9d9C6;
        adminMap[534_352] = 0x0F7Ad835235Ede685180A5c611111610813457a9;
    }

    function populateExplorerMap() internal {
        explorerMap[42_161] = "https://arbiscan.io/address/";
        explorerMap[43_114] = "https://snowtrace.io/address/";
        explorerMap[8453] = "https://basescan.org/address/";
        explorerMap[81_457] = "https://blastscan.io/address/";
        explorerMap[56] = "https://bscscan.com/address/";
        explorerMap[1] = "https://etherscan.io/address/";
        explorerMap[100] = "https://gnosisscan.io/address/";
        explorerMap[10] = "https://optimistic.etherscan.io/address/";
        explorerMap[137] = "https://polygonscan.com/address/";
        explorerMap[534_352] = "https://scrollscan.com/address/";
        explorerMap[11_155_111] = "https://sepolia.etherscan.io/address/";
    }
}
