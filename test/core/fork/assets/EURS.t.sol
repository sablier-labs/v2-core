// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Lockup_Dynamic_Fork_Test } from "../LockupDynamic.t.sol";
import { Lockup_Linear_Fork_Test } from "../LockupLinear.t.sol";
import { Lockup_Tranched_Fork_Test } from "../LockupTranched.t.sol";

/// @dev An ERC-20 asset with 2 decimals.
IERC20 constant FORK_ASSET = IERC20(0xdB25f211AB05b1c97D595516F45794528a807ad8);
address constant FORK_ASSET_HOLDER = 0x1bee4F735062CD00841d6997964F187f5f5F5Ac9;

contract EURS_Lockup_Dynamic_Fork_Test is Lockup_Dynamic_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }

contract EURS_Lockup_Linear_Fork_Test is Lockup_Linear_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }

contract EURS_Lockup_Tranched_Fork_Test is Lockup_Tranched_Fork_Test(FORK_ASSET, FORK_ASSET_HOLDER) { }
