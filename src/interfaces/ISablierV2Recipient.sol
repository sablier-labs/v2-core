// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

/// @title ISablierV2Recipient
/// @notice Interface for Sablier V2 recipients that react to cancellations and withdrawals.
interface ISablierV2Recipient {
    /// @notice Handles the cancellation of a stream.
    /// @notice Sablier V2 invokes this function on the recipient after a cancellation.
    /// This function MAY revert, but the Sablier V2 contract will ignore the revert.
    /// @param streamId The id of the stream that was canceled.
    /// @param caller The address of the account who performed the cancellation.
    /// @param withdrawAmount The amount of tokens withdrawn to the recipient, in units of the token's decimals.
    /// @param returnAmount The amount of tokens returned to the sender, in units of the token's decimals.
    function onStreamCanceled(
        uint256 streamId,
        address caller,
        uint256 withdrawAmount,
        uint256 returnAmount
    ) external;

    /// @notice Handles a withdrawal from a stream.
    /// @dev Sablier V2 invokes this function on the recipient after a withdrawal.
    /// This function MAY revert, but the Sablier V2 contract will ignore the revert.
    /// @param streamId The id of the stream that was canceled.
    /// @param caller The address of the account who performed the withdrawal.
    /// @param withdrawAmount The amount of tokens that were withdrawn, in units of the token's decimals.
    function onStreamWithdrawn(
        uint256 streamId,
        address caller,
        uint256 withdrawAmount
    ) external;
}
