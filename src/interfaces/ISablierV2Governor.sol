// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IBlast } from "./blast/IBlast.sol";
import { IERC20Rebasing } from "./blast/IERC20Rebasing.sol";
import { YieldMode } from "./blast/IYield.sol";

/// @title ISablierV2Governor
/// @notice This interface acts as a periphery to interact with the yield modules on Blast L2.
/// @dev https://docs.blast.io/
interface ISablierV2Governor {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the claimable yield from `asset`.
    /// @dev Requires YieldMode set to CLAIMABLE.
    /// @param asset The address of the ERC20 asset.
    /// @return claimableYield Claimable amount.
    function getClaimableAssetYield(IERC20Rebasing asset) external view returns (uint256 claimableYield);

    /// @notice Retrieves the configured yield mode from `asset`.
    /// @dev Requires YieldMode set to CLAIMABLE.
    /// @param asset The address of the ERC20 asset.
    /// @return Configured yield mode.
    function getAssetConfiguration(IERC20Rebasing asset) external view returns (YieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim yield from `asset` and send to a recipient.
    /// @dev Only callable by the admin.
    /// @param amount Amount to claim.
    /// @param recipientOfYield Address to receive the claimed balance.
    /// @param asset The address of the ERC20 asset.
    /// @return uint256 Amount claimed.
    function claimRebasingAssetYield(
        uint256 amount,
        address recipientOfYield,
        IERC20Rebasing asset
    )
        external
        returns (uint256);

    /// @notice Sets the yield mode for an ERC20 asset.
    /// @dev Only callable by the admin.
    /// @param asset The address of the ERC20 asset.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @return uint256 Current user balance
    function configureRebasingAsset(IERC20Rebasing asset, YieldMode yieldMode) external returns (uint256);

    /// @notice configures yield and gas modes and sets the governor.
    /// @dev Only callable by the admin.
    /// @param blastEth The address of the Blast ETH contract.
    /// @param governor The address of the governor to set.
    function configureYieldAndGas(IBlast blastEth, address governor) external;
}
