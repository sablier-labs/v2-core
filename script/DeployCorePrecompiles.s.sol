// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Precompiles } from "../precompiles/Precompiles.sol";
import { ISablierV2LockupDynamic } from "../src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "../src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "../src/interfaces/ISablierV2LockupTranched.sol";
import { ISablierV2NFTDescriptor } from "../src/interfaces/ISablierV2NFTDescriptor.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Using precompiles, deploys the Sablier V2 core contracts in the following order:
///
/// 1. {SablierV2NFTDescriptor}
/// 2. {SablierV2LockupDynamic}
/// 3. {SablierV2LockupLinear}
/// 4. {SablierV2LockupTranched}
contract DeployCorePrecompiles is BaseScript {
    function run(address initialAdmin)
        public
        broadcast
        returns (
            ISablierV2LockupDynamic lockupDynamic,
            ISablierV2LockupLinear lockupLinear,
            ISablierV2LockupTranched lockupTranched,
            ISablierV2NFTDescriptor nftDescriptor
        )
    {
        (lockupDynamic, lockupLinear, lockupTranched, nftDescriptor) = new Precompiles().deployCore(initialAdmin);
    }
}
