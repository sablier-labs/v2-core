// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { stdJson } from "forge-std/src/StdJson.sol";

import { BaseScript } from "../Base.s.sol";

abstract contract ProtocolScript is BaseScript {
    using Strings for uint256;
    using Strings for address;
    using stdJson for string;

    /// @dev The path to the file where the deployment addresses are stored.
    string internal deploymentFile = "deployments/";

    string internal version = getVersion();

    constructor() {
        string memory chainId = block.chainid.toString();
        deploymentFile = string.concat(deploymentFile, chainId, ".md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({ path: deploymentFile, data: string.concat("# Deployed Addresses for chain ", chainId, "\n\n") });
    }

    // forgefmt: disable-start

    // ### Core

    // | Contract              | Address                                       | Deployment                                                                                |
    // | :-------------------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------- |
    // | SablierLockupDynamic  | [0x...](https://<explorer_url>/address/0x...) | [core-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/core/<version>) |
    // | SablierLockupLinear   | [0x...](https://<explorer_url>/address/0x...) | [core-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/core/<version>) |
    // | SablierLockupTranched | [0x...](https://<explorer_url>/address/0x...) | [core-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/core/<version>) |
    // | LockupNFTDescriptor   | [0x...](https://<explorer_url>/address/0x...) | [core-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/core/<version>) |

    // ### Periphery

    // | Contract                   | Address                                       | Deployment                                                                                          |
    // | :------------------------- | :-------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
    // | SablierBatchLockup         | [0x...](https://<explorer_url>/address/0x...) | [periphery-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/periphery/<version>) |
    // | SablierMerkleLockupFactory | [0x...](https://<explorer_url>/address/0x...) | [periphery-<version>](https://github.com/sablier-labs/v2-deployments/tree/main/periphery/<version>) |

    // forgefmt: disable-end

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
            "](https://<explorer_url>/address/",
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
            "](https://<explorer_url>/address/",
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
            "](https://<explorer_url>/address/",
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
            "](https://<explorer_url>/address/",
            nftDescriptorHex,
            ") | [core-",
            version,
            "](https://github.com/sablier-labs/v2-deployments/tree/main/core/",
            version,
            ") |"
        );
        _appendToFile(nftDescriptorLine);

        string memory periphery = " ### Periphery\n\n";
        _appendToFile(periphery);
        _appendToFile(firstTwoLines);

        string memory batchLockupHex = batchLockup.toHexString();
        string memory batchLockupLine = string.concat(
            "| SablierBatchLockup | [",
            batchLockupHex,
            "](https://<explorer_url>/address/",
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
            "| SablierBatchLockup | [",
            merkleFactoryHex,
            "](https://<explorer_url>/address/",
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
}
