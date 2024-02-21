// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { IERC20Rebasing } from "src/interfaces/blast/IERC20Rebasing.sol";
import { YieldMode } from "src/interfaces/blast/IYield.sol";

contract ERC20Rebasing is ERC20, IERC20Rebasing, PRBTest, StdCheats {
    mapping(address account => uint256) public claimableYield;
    mapping(address account => YieldMode) public yieldMode;

    constructor() ERC20("Rebasing ERC20", "BUSDToken") { }

    function getClaimableAmount(address account) public view returns (uint256 amount) {
        return claimableYield[account];
    }

    function getConfiguration(address account) public view returns (YieldMode) {
        return yieldMode[account];
    }

    /// @dev This function is used to simulate claiming yield. It updates the `claimableYield` and sends the desired
    /// amount to the recipient.
    function claim(address recipient, uint256 amount) public returns (uint256) {
        address account = msg.sender;
        if (yieldMode[account] == YieldMode.CLAIMABLE) {
            claimableYield[account] = claimableYield[account] - amount;
            deal(address(this), recipient, balanceOf(recipient) + amount);
            return amount;
        }
        return 0;
    }

    function configure(YieldMode yieldMode_) public returns (uint256) {
        yieldMode[msg.sender] = yieldMode_;
        return balanceOf(msg.sender);
    }
}
