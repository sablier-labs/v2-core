// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IBlast, GasMode, YieldMode } from "./IBlast.sol";
import { IERC20Rebasing } from "./IERC20Rebasing.sol";

/// @title ISablierV2BlastGovernor
/// @notice This contract manages interactions with rebasing assets and configuring Blast L2's unique functionalities,
/// yield mode and gas mode.
/// @dev See: https://docs.blast.io/
interface ISablierV2BlastGovernor {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the claimable yield from `asset`.
    /// @dev Reverts if the yield mode is not set to `CLAIMABLE`.
    /// @param asset The address of the rebasing ERC-20 asset.
    function getClaimableAssetYield(IERC20Rebasing asset) external view returns (uint256 claimableYield);

    /// @notice Retrieves the configured yield mode from `asset`.
    /// @dev Reverts if the yield mode is not set to `CLAIMABLE`.
    /// @param asset The address of the rebasing ERC-20 asset.
    function getAssetConfiguration(IERC20Rebasing asset) external view returns (YieldMode yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim yield from `asset` and send to a recipient.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param amount Amount to claim.
    /// @param to Address to receive the claimed amount.
    /// @param asset The address of the ERC-20 asset.
    function claimRebasingAssetYield(uint256 amount, address to, IERC20Rebasing asset) external;

    /// @notice Sets the yield mode for a rebasing ERC-20 asset.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param asset The address of the rebasing ERC-20 asset.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @return balance The current balance of this contract.
    function configureRebasingAsset(IERC20Rebasing asset, YieldMode yieldMode) external returns (uint256 balance);

    /// @notice configures yield and gas modes and sets the governor.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param blast The address of the Blast contract.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param gasMode Enum representing the gas mode to set.
    /// @param governor The address of the governor to set.
    function configureYieldAndGas(IBlast blast, YieldMode yieldMode, GasMode gasMode, address governor) external;
}
