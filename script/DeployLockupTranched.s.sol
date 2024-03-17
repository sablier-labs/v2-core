// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2NFTDescriptor } from "../src/interfaces/ISablierV2NFTDescriptor.sol";
import { SablierV2LockupTranched } from "../src/SablierV2LockupTranched.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployLockupTranched is BaseScript {
    /// @dev Deploy using Forge CLI.
    function runBroadcast(
        address initialAdmin,
        ISablierV2NFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        broadcast
        returns (SablierV2LockupTranched lockupTranched)
    {
        lockupTranched = _run(initialAdmin, initialNFTDescriptor);
    }

    /// @dev Deploy using Sphinx CLI.
    function runSphinx(
        address initialAdmin,
        ISablierV2NFTDescriptor initialNFTDescriptor
    )
        public
        virtual
        sphinx
        returns (SablierV2LockupTranched lockupTranched)
    {
        lockupTranched = _run(initialAdmin, initialNFTDescriptor);
    }

    function _run(
        address initialAdmin,
        ISablierV2NFTDescriptor initialNFTDescriptor
    )
        internal
        returns (SablierV2LockupTranched lockupTranched)
    {
        lockupTranched = new SablierV2LockupTranched(initialAdmin, initialNFTDescriptor, maxCount);
    }
}
