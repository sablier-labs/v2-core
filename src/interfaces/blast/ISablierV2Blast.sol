// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IBlast, GasMode, YieldMode } from "./IBlast.sol";
import { IERC20Rebasing } from "./IERC20Rebasing.sol";

/// @title ISablierV2Blast
/// @notice This contract manages interactions with rebasing assets and configuring Blast L2's unique functionalities,
/// yield mode and gas mode.
/// @dev See: https://docs.blast.io/
interface ISablierV2Blast {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the claimable yield from rebasing `asset`.
    /// @dev Reverts if the yield mode is not set to `CLAIMABLE`.
    /// @param asset The address of the rebasing ERC-20 asset.
    function getClaimableRebasingAssetYield(IERC20Rebasing asset) external view returns (uint256 claimableYield);

    /// @notice Retrieves the configured yield mode from rebasing `asset`.
    /// @dev Reverts if the yield mode is not set to `CLAIMABLE`.
    /// @param asset The address of the rebasing ERC-20 asset.
    function getRebasingAssetConfiguration(IERC20Rebasing asset) external view returns (YieldMode yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim the provided amount of yield assets to the `to` address.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param asset The address of the ERC-20 asset.
    /// @param amount The amount to claim.
    /// @param to The address receiving the claimed assets.
    /// @return Amount claimed.
    function claimRebasingAssetYield(IERC20Rebasing asset, uint256 amount, address to) external returns (uint256);

    /// @notice Sets the yield mode for a rebasing ERC-20 asset.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param asset The address of the rebasing ERC-20 asset.
    /// @param yieldMode Enum representing the yield mode to set.
    function configureRebasingAsset(IERC20Rebasing asset, YieldMode yieldMode) external;

    /// @notice configures yield and gas modes and sets the governor.
    /// @dev Reverts if `msg.sender` is not the contract admin.
    /// @param blast The address of the Blast contract.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param gasMode Enum representing the gas mode to set.
    /// @param governor The address of the governor to set.
    function configureYieldAndGas(IBlast blast, YieldMode yieldMode, GasMode gasMode, address governor) external;
}
