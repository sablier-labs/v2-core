// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { LockupNFTDescriptor } from "../../src/core/LockupNFTDescriptor.sol";
import { SablierLockup } from "../../src/core/SablierLockup.sol";
import { BaseScript } from "../Base.s.sol";

/// @notice Deploys all Core contracts at deterministic addresses across chains.
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicCore is BaseScript {
    function run(address initialAdmin)
        public
        virtual
        broadcast
        returns (LockupNFTDescriptor nftDescriptor, SablierLockup lockup)
    {
        bytes32 salt = constructCreate2Salt();
        nftDescriptor = new LockupNFTDescriptor{ salt: salt }();
        lockup = new SablierLockup{ salt: salt }(initialAdmin, nftDescriptor, maxCountMap[block.chainid]);
    }
}
