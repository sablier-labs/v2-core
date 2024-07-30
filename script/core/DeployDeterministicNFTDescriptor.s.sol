// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { SablierNFTDescriptor } from "../../src/core/SablierNFTDescriptor.sol";

import { BaseScript } from "../Base.s.sol";

/// @dev Deploys {SablierNFTDescriptor} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicNFTDescriptor is BaseScript {
    function run() public virtual broadcast returns (SablierNFTDescriptor nftDescriptor) {
        bytes32 salt = constructCreate2Salt();
        nftDescriptor = new SablierNFTDescriptor{ salt: salt }();
    }
}
