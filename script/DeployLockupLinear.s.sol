// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2NFTDescriptor } from "../src/interfaces/ISablierV2NFTDescriptor.sol";
import { SablierV2LockupLinear } from "../src/SablierV2LockupLinear.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployLockupLinear is BaseScript {
    function run(
        address initialAdmin,
        ISablierV2NFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        sphinx
        returns (SablierV2LockupLinear lockupLinear)
    {
        lockupLinear = new SablierV2LockupLinear(initialAdmin, initialNFTDescriptor);
    }
}
