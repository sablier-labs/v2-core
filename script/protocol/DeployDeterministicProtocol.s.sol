// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { LockupNFTDescriptor } from "../../src/core/LockupNFTDescriptor.sol";
import { SablierLockup } from "../../src/core/SablierLockup.sol";
import { SablierBatchLockup } from "../../src/periphery/SablierBatchLockup.sol";

import { DeploymentLogger } from "./DeploymentLogger.s.sol";

/// @notice Deploys the Lockup Protocol at deterministic addresses across chains.
contract DeployDeterministicProtocol is DeploymentLogger("deterministic") {
    /// @dev Deploys the protocol with the admin set in `adminMap`.
    function run()
        public
        virtual
        broadcast
        returns (LockupNFTDescriptor nftDescriptor, SablierLockup lockup, SablierBatchLockup batchLockup)
    {
        address initialAdmin = adminMap[block.chainid];

        (nftDescriptor, lockup, batchLockup) = _run(initialAdmin);
    }

    /// @dev Deploys the protocol with the given `initialAdmin`.
    function run(address initialAdmin)
        internal
        returns (LockupNFTDescriptor nftDescriptor, SablierLockup lockup, SablierBatchLockup batchLockup)
    {
        (nftDescriptor, lockup, batchLockup) = _run(initialAdmin);
    }

    /// @dev Common logic for the run functions.
    function _run(address initialAdmin)
        internal
        returns (LockupNFTDescriptor nftDescriptor, SablierLockup lockup, SablierBatchLockup batchLockup)
    {
        // Deploy Core.
        nftDescriptor = new LockupNFTDescriptor{ salt: SALT }();
        lockup = new SablierLockup{ salt: SALT }(initialAdmin, nftDescriptor, maxCountMap[block.chainid]);
        batchLockup = new SablierBatchLockup{ salt: SALT }();

        // Deploy Periphery.
        batchLockup = new SablierBatchLockup{ salt: salt }();

        appendToFileDeployedAddresses(address(lockup), address(nftDescriptor), address(batchLockup));
    }
}
