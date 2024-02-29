// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { LockupDynamic_Fork_Test } from "../LockupDynamic.t.sol";
import { LockupLinear_Fork_Test } from "../LockupLinear.t.sol";

/// @dev A WETH token with rebasing yield deployed on Blast L2.
IERC20 constant ASSET = IERC20(0x4300000000000000000000000000000000000004);
address constant HOLDER = 0x6301795aa55B90427CF74C18C8636E0443F2100b;

contract BWETH_LockupDynamic_Fork_Test is LockupDynamic_Fork_Test(ASSET, HOLDER) { }

contract BWETH_LockupLinear_Fork_Test is LockupLinear_Fork_Test(ASSET, HOLDER) { }
