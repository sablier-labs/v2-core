// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC20Rebasing, YieldMode } from "../../../src/interfaces/blast/IERC20Rebasing.sol";

abstract contract ERC20RebasingMock is ERC20("ERC20Rebasing Mock", "REB-MOCK"), IERC20Rebasing {
    mapping(address => YieldMode) private _yieldMode;

    function getClaimableAmount(address account) external view override returns (uint256 amount) {
        return balanceOf(account);
    }

    function getConfiguration(address account) external view override returns (YieldMode) {
        return _yieldMode[account];
    }

    function configure(YieldMode yieldMode) external override returns (uint256) {
        _yieldMode[msg.sender] = yieldMode;
        return balanceOf(msg.sender);
    }
}
