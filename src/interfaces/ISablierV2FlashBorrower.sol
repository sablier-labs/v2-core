// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

/// @title ISablierV2FlashBorrower
/// @notice Interface for Sablier V2 flash loans.
/// @dev Implementing this interface is necessarily. If a contract does not implement this interface,
/// the `flashLoan` function execution will revert.
interface ISablierV2FlashBorrower {
    /// @dev Receive a flash loan.
    /// @param initiator The address of the flash loan initiator.
    /// @param token The address of the token borrowed.
    /// @param amount The amount of tokens to be borrowed.
    /// @param feeAmount The additional amount of tokens to repay.
    /// @param data Any data passed through by the caller via the {ISablierV2-flashLoan} call.
    /// @return Whether the borrow execution succeeds.
    function onFlashLoan(
        address initiator,
        IERC20 token,
        uint256 amount,
        uint256 feeAmount,
        bytes calldata data
    ) external returns (bool);
}
