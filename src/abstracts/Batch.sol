// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable no-inline-assembly
pragma solidity >=0.8.22;

import { IBatch } from "../interfaces/IBatch.sol";

/// @title Batch
/// @notice See the documentation in {IBatch}.
/// @dev Forked from: https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/BoringBatchable.sol
abstract contract Batch is IBatch {
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBatch
    /// @dev Since `msg.value` can be reused across the calls, BE VERY CAREFUL when using it. Refer to
    /// https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong for more information.
    function batch(bytes[] calldata calls) external payable override returns (bytes[] memory results) {
        uint256 count = calls.length;
        results = new bytes[](count);

        for (uint256 i = 0; i < count; ++i) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);

            // Revert with result data if delegatecall fails. Assembly code is used to bubble up the revert reason.
            if (!success) {
                assembly {
                    // Get the length of the result stored in the first 32 bytes.
                    let resultSize := mload(result)

                    // Forward the pointer by 32 bytes at the beginning of the result data.
                    revert(add(32, result), resultSize)
                }
            }

            // Store the result of the delegatecall.
            results[i] = result;
        }
    }
}
