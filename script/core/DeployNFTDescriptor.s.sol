// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { SablierNFTDescriptor } from "../../src/core/SablierNFTDescriptor.sol";

import { BaseScript } from "../Base.s.sol";

contract DeployNFTDescriptor is BaseScript {
    function run() public virtual broadcast returns (SablierNFTDescriptor nftDescriptor) {
        nftDescriptor = new SablierNFTDescriptor();
    }
}
