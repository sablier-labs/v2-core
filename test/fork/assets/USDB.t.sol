// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { LockupDynamic_Fork_Test } from "../LockupDynamic.t.sol";
import { LockupLinear_Fork_Test } from "../LockupLinear.t.sol";

/// @dev A USD token with rebasing yield deployed on Blast L2.
IERC20 constant ASSET = IERC20(0x4300000000000000000000000000000000000003);
address constant HOLDER = 0x020cA66C30beC2c4Fe3861a94E4DB4A498A35872;

contract USDB_LockupDynamic_Fork_Test is LockupDynamic_Fork_Test(ASSET, HOLDER) { }

contract USDB_LockupLinear_Fork_Test is LockupLinear_Fork_Test(ASSET, HOLDER) { }
