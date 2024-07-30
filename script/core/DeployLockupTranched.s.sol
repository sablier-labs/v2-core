// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierNFTDescriptor } from "../../src/core/interfaces/ISablierNFTDescriptor.sol";
import { SablierLockupTranched } from "../../src/core/SablierLockupTranched.sol";

import { BaseScript } from "../Base.s.sol";

contract DeployLockupTranched is BaseScript {
    function run(
        address initialAdmin,
        ISablierNFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        broadcast
        returns (SablierLockupTranched lockupTranched)
    {
        lockupTranched = new SablierLockupTranched(initialAdmin, initialNFTDescriptor, trancheCountMap[block.chainid]);
    }
}
