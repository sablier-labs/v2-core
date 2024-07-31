// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierNFTDescriptor } from "../../src/core/interfaces/ISablierNFTDescriptor.sol";
import { SablierLockupDynamic } from "../../src/core/SablierLockupDynamic.sol";

import { BaseScript } from "../Base.s.sol";

contract DeployLockupDynamic is BaseScript {
    function run(
        address initialAdmin,
        ISablierNFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        broadcast
        returns (SablierLockupDynamic lockupDynamic)
    {
        lockupDynamic = new SablierLockupDynamic(initialAdmin, initialNFTDescriptor, segmentCountMap[block.chainid]);
    }
}