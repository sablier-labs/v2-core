// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC20Rebasing } from "src/interfaces/Blast/IERC20Rebasing.sol";
import { YieldMode } from "src/interfaces/Blast/IYield.sol";

contract ERC20Rebasing is ERC20, IERC20Rebasing {
    constructor() ERC20("Rebasing ERC20", "BERC20") { }

    function getClaimableAmount(address account) external view returns (uint256 amount) { }

    function getConfiguration(address account) external view returns (YieldMode) { }

    function claim(address recipient, uint256 amount) external returns (uint256) { }

    function configure(YieldMode yieldMode) external returns (uint256) { }
}
