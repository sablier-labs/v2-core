// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IBlast } from "./IBlast.sol";

/// @title IBlastGovernor
/// @notice This interface acts as a periphery to interact with the Blast contracts.
/// @dev https://docs.blast.io/
interface IBlastGovernor {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the contract address for setting up yields for ETH.
    /// @dev This value is hard coded as a constant.
    function BLAST_ETH() external pure returns (IBlast);

    /// @notice Retrieves the contract address for setting up yield for USDB.
    /// @dev This value is hard coded as a constant.
    function BLAST_USDB() external pure returns (IBlast);

    /// @notice Retrieves the contract address for setting up yield for WETH.
    /// @dev This value is hard coded as a constant.
    function BLAST_WETH() external pure returns (IBlast);

    /// @notice Retrieves the claimable yield in an ERC20 token for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @param token The address of the ERC20 token.
    /// @return claimableYield Yield amount available to claim.
    function getClaimableAmount(IBlast token) external view returns (uint256 claimableYield);

    /// @notice Retrieves the claimable yield for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @return claimableYield Yield amount available to claim.
    function readClaimableYield() external view returns (uint256 claimableYield);

    /// @notice Retrieves the gas mode parameters for `account`.
    /// @return etherSeconds Number of seconds required for claimable gas to mature.
    /// @return etherBalance The amount of gas to claim in ETH.
    /// @return lastUpdated Timestamp when gas was updated.
    /// @return gasMode The Gas mode as a {GasMode} variant.
    function readGasParams()
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, IBlast.GasMode gasMode);

    /// @notice Retrieves the yield mode set for `account`.
    /// @return yieldMode The yield mode as an integer position in {YieldMode}.
    function readYieldConfiguration() external view returns (uint8 yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim all yield in an ERC20 token for `account`.
    /// @param recipientOfYield The recipient address for yield.
    /// @param amount Yield amount to claim.
    /// @param token The address of the ERC20 token.
    function claim(address recipientOfYield, uint256 amount, IBlast token) external returns (uint256);

    /// @notice Claim all gas in ETH for `account`.
    /// @param recipientOfGas The recipient address for gas.
    function claimAllGas(address recipientOfGas) external returns (uint256);

    /// @notice Claim all yield in ETH for `account`.
    /// @param recipientOfYield The recipient address for yield.
    function claimAllYield(address recipientOfYield) external returns (uint256);

    /// @notice Sets the yield mode for an ERC20 token.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param token The address of the ERC20 token.
    function configure(IBlast.YieldMode yieldMode, IBlast token) external;

    /// @notice Sets the yield mode, gas modes and governor address.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param gasMode Enum representing the gas mode to set.
    /// @param newGovernor The address of the new governor.
    function configure(IBlast.YieldMode yieldMode, IBlast.GasMode gasMode, address newGovernor) external;
}
