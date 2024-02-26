// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { YieldMode } from "./IBlast.sol";

/// @title IERC20Rebasing
/// @notice Interface for ERC-20 rebasing assets on Blast L2.
/// @dev See: https://docs.blast.io/
interface IERC20Rebasing {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Query an `CLAIMABLE` account's claimable yield.
    /// @param account Address to query the claimable amount.
    /// @return amount Claimable amount.
    function getClaimableAmount(address account) external view returns (uint256 amount);

    /// @notice Query an account's configured yield mode.
    /// @param account Address to query the configuration.
    /// @return Configured yield mode.
    function getConfiguration(address account) external view returns (YieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim yield from a `CLAIMABLE` account and send to a recipient.
    /// @param recipient Address to receive the claimed balance.
    /// @param amount Amount to claim.
    /// @return uint256 Amount claimed.
    function claim(address recipient, uint256 amount) external returns (uint256);

    /// @notice Sets the yield mode for an ERC-20 asset.
    /// @dev This function should only be called by the contract itself.
    /// @param yieldMode Yield mode to configure.
    /// @return uint256 Current user balance
    function configure(YieldMode yieldMode) external returns (uint256);
}
