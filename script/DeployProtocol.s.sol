// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { SablierLockupDynamic } from "../src/core/SablierLockupDynamic.sol";
import { SablierLockupLinear } from "../src/core/SablierLockupLinear.sol";
import { SablierLockupTranched } from "../src/core/SablierLockupTranched.sol";
import { SablierNFTDescriptor } from "../src/core/SablierNFTDescriptor.sol";
import { SablierMerkleLockupFactory } from "../src/periphery/SablierMerkleLockupFactory.sol";
import { SablierBatchLockup } from "../src/periphery/SablierBatchLockup.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Deploys the Lockup Protocol.
contract DeployProtocol is BaseScript {
    /// @dev Deploy via Forge.
    function run(address initialAdmin)
        public
        virtual
        broadcast
        returns (
            SablierLockupDynamic lockupDynamic,
            SablierLockupLinear lockupLinear,
            SablierLockupTranched lockupTranched,
            SablierNFTDescriptor nftDescriptor,
            SablierBatchLockup batchLockup,
            SablierMerkleLockupFactory merkleLockupFactory
        )
    {
        // Deploy Core.
        nftDescriptor = new SablierNFTDescriptor();
        lockupDynamic = new SablierLockupDynamic(initialAdmin, nftDescriptor, segmentCountMap[block.chainid]);
        lockupLinear = new SablierLockupLinear(initialAdmin, nftDescriptor);
        lockupTranched = new SablierLockupTranched(initialAdmin, nftDescriptor, trancheCountMap[block.chainid]);

        // Deploy Periphery.
        batchLockup = new SablierBatchLockup();
        merkleLockupFactory = new SablierMerkleLockupFactory();
    }
}
