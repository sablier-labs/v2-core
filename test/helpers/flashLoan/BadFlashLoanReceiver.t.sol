// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { ISablierV2FlashBorrower } from "src/interfaces/ISablierV2FlashBorrower.sol";

contract BadFlashLoanReceiver is ISablierV2FlashBorrower {
    function onFlashLoan(
        address initiator,
        IERC20 token,
        uint256 amount,
        uint256 flashFeeAmout,
        bytes calldata data
    ) external pure returns (bool) {
        initiator;
        token;
        amount;
        flashFeeAmout;
        data;
        return false;
    }
}
