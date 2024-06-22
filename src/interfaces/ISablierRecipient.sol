// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title ISablierRecipient
///
/// @notice Interface for recipient contracts capable of reacting to cancellations and withdrawals. Implementation of
/// this interface is optional. If a recipient contract doesn't implement this interface or implements it partially, the
/// function execution will not revert.
///
/// @dev See {IERC165-supportsInterface}.
/// - The implementation MUST implement the {IERC165-supportsInterface} method, which MUST return `true` when called
/// with `0xf8ee98d3`.
interface ISablierRecipient is IERC165 {
    /// @notice Responds to cancellations.
    ///
    /// @dev Notes:
    /// - The function MUST return the selector i.e. ISablierRecipient.onSablierLockupCancel.selector.
    /// - If this function reverts, the Sablier contract will revert as well.
    ///
    /// @param streamId The ID of the canceled stream.
    /// @param sender The stream's sender, who canceled the stream.
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param recipientAmount The amount of assets left for the stream's recipient to withdraw, denoted in units of
    /// the asset's decimals.
    ///
    /// @return selector The function selector for the hook.
    function onSablierLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        returns (bytes4 selector);

    /// @notice Responds to withdrawals triggered by any address except the contract implementing this interface.
    ///
    /// @dev Notes:
    /// - The function MUST return the selector i.e. ISablierRecipient.onSablierLockupWithdraw.selector.
    /// - If this function reverts, the Sablier contract will revert as well.
    ///
    /// @param streamId The ID of the stream being withdrawn from.
    /// @param caller The original `msg.sender` address that triggered the withdrawal.
    /// @param to The address receiving the withdrawn assets.
    /// @param amount The amount of assets withdrawn, denoted in units of the asset's decimals.
    ///
    /// @return selector The function selector for the hook.
    function onSablierLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        returns (bytes4 selector);
}
