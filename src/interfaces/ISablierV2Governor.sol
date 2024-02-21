// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IBlast } from "./blast/IBlast.sol";
import { IERC20Rebasing } from "./blast/IERC20Rebasing.sol";
import { GasMode } from "./blast/IGas.sol";
import { YieldMode } from "./blast/IYield.sol";

/// @title ISablierV2Governor
/// @notice This interface acts as a periphery to interact with the yield modules on Blast L2.
/// @dev https://docs.blast.io/
interface ISablierV2Governor {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the claimable yield from `token`.
    /// @dev Requires YieldMode set to CLAIMABLE.
    /// @param token The address of the ERC20 token.
    /// @return claimableYield Claimable amount.
    function getClaimableAmount(IERC20Rebasing token) external view returns (uint256 claimableYield);

    /// @notice Retrieves the configured yield mode from `token`.
    /// @dev Requires YieldMode set to CLAIMABLE.
    /// @param token The address of the ERC20 token.
    /// @return Configured yield mode.
    function getConfiguration(IERC20Rebasing token) external view returns (YieldMode);

    /// @notice Reads the claimable yield.
    /// @dev Requires YieldMode set to CLAIMABLE.
    /// @param blastEth The address of the Blast ETH contract.
    /// @return claimableYield claimable yield.
    function readClaimableYield(IBlast blastEth) external view returns (uint256 claimableYield);

    /// @notice Retrieves the gas mode parameters.
    /// @param blastEth The address of the Blast ETH contract.
    /// @return etherSeconds Number of seconds required for claimable gas to mature.
    /// @return etherBalance The amount of gas to claim in ETH.
    /// @return lastUpdated Timestamp when gas was updated.
    /// @return gasMode The Gas mode as a GasMode variant.
    function readGasParams(IBlast blastEth)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode);

    /// @notice Reads the yield configuration.
    /// @param blastEth The address of the Blast ETH contract.
    /// @return yieldMode representing yield enum.
    function readYieldConfiguration(IBlast blastEth) external view returns (uint8 yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim yield from `token` and send to a recipient.
    /// @dev Only callable by the admin.
    /// @param amount Amount to claim.
    /// @param recipientOfYield Address to receive the claimed balance.
    /// @param token The address of the ERC20 token.
    /// @return uint256 Amount claimed.
    function claim(uint256 amount, address recipientOfYield, IERC20Rebasing token) external returns (uint256);

    /// @notice Claim all gas in ETH for when Claimable configuration is used.
    /// @dev Only callable by the admin.
    /// @param blastEth The address of the Blast ETH contract.
    /// @param recipientOfGas The address of the recipient of the gas.
    /// @return uint256 The amount of gas that was claimed
    function claimAllGas(IBlast blastEth, address recipientOfGas) external returns (uint256);

    /// @notice Claim all yield in ETH for when Claimable configuration is used.
    /// @dev Only callable by the admin.
    /// @param blastEth The address of the Blast ETH contract.
    /// @param recipientOfYield The address of the recipient of the yield.
    /// @return uint256 The amount of yield that was claimed
    function claimAllYield(IBlast blastEth, address recipientOfYield) external returns (uint256);

    /// @notice Sets the yield mode for an ERC20 token.
    /// @dev Only callable by the admin.
    /// @param token The address of the ERC20 token.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @return uint256 Current user balance
    function configureYieldForToken(IERC20Rebasing token, YieldMode yieldMode) external returns (uint256);

    /// @notice configures yield and gas modes and sets the governor.
    /// @dev Only callable by the admin.
    /// @param blastEth The address of the Blast ETH contract.
    /// @param governor The address of the governor to set.
    function configureVoidYieldAndClaimableGas(IBlast blastEth, address governor) external;
}
