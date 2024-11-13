// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Lockup_Dynamic_Fork_Test } from "../LockupDynamic.t.sol";
import { Lockup_Linear_Fork_Test } from "../LockupLinear.t.sol";
import { Lockup_Tranched_Fork_Test } from "../LockupTranched.t.sol";

/// @dev An ERC-20 asset with a large total supply.
IERC20 constant FORK_ASSET = IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
address constant FORK_ASSET_HOLDER = 0x73AF3bcf944a6559933396c1577B257e2054D935;

contract SHIB_Lockup_Dynamic_Fork_Test is Lockup_Dynamic_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }

contract SHIB_Lockup_Linear_Fork_Test is Lockup_Linear_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }

contract SHIB_Lockup_Tranched_Fork_Test is Lockup_Tranched_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }
