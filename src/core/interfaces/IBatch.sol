// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

/// @notice This contract implements logic to batch call any function.
interface IBatch {
    /// @notice Allows batched call to self, `this` contract.
    /// @dev The `msg.value` should not be trusted for any method callable from batch.
    /// @param calls An array of inputs for each call.
    function batch(bytes[] calldata calls) external payable;
}
