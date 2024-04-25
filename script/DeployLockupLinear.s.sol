// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Comptroller } from "../contracts/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "../contracts/interfaces/ISablierV2NFTDescriptor.sol";
import { SablierV2LockupLinear } from "../contracts/SablierV2LockupLinear.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployLockupLinear is BaseScript {
    function run(
        address initialAdmin,
        ISablierV2Comptroller initialComptroller,
        ISablierV2NFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        broadcast
        returns (SablierV2LockupLinear lockupLinear)
    {
        lockupLinear = new SablierV2LockupLinear(initialAdmin, initialComptroller, initialNFTDescriptor);
    }
}
