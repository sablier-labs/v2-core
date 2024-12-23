// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

/// @notice This contract implements logic to batch call any function.
interface IBatch {
    /// @notice Allows batched call to self, `this` contract.
    /// @dev `results` contains `0x` for calls that do not return anything.
    ///
    /// Note:
    /// - Since `msg.value` can be reused across the calls, be VERY CAREFUL when using it. Refer to
    /// https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong for more information.
    ///
    /// @param calls An array of inputs for each call.
    /// @return results An array of results from each call.
    function batch(bytes[] calldata calls) external payable returns (bytes[] memory results);
}
