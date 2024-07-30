// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierNFTDescriptor } from "../../src/core/interfaces/ISablierNFTDescriptor.sol";
import { SablierLockupDynamic } from "../../src/core/SablierLockupDynamic.sol";

import { BaseScript } from "../Base.s.sol";

/// @notice Deploys {SablierLockupDynamic} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicLockupDynamic is BaseScript {
    function run(
        address initialAdmin,
        ISablierNFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        broadcast
        returns (SablierLockupDynamic lockupDynamic)
    {
        bytes32 salt = constructCreate2Salt();
        lockupDynamic =
            new SablierLockupDynamic{ salt: salt }(initialAdmin, initialNFTDescriptor, segmentCountMap[block.chainid]);
    }
}
