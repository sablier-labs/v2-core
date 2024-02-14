// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { LockupDynamic_Fork_Test } from "../LockupDynamic.t.sol";
import { LockupLinear_Fork_Test } from "../LockupLinear.t.sol";

/// @dev A USD token with rebasing yield deployed on Blast L2.
IERC20 constant ASSET = IERC20(0x4200000000000000000000000000000000000022);
address constant HOLDER = 0xA721084c35755015961BDFb1C91B3EFdeDd9987E;

contract USDB_LockupDynamic_Fork_Test is LockupDynamic_Fork_Test(ASSET, HOLDER) { }

contract USDB_LockupLinear_Fork_Test is LockupLinear_Fork_Test(ASSET, HOLDER) { }
