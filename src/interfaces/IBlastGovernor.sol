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

    /// @notice Retrieves the claimable yield in an ERC20 token for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @param token The address of the ERC20 token.
    /// @return claimableYield Yield amount available to claim.
    function getClaimableAmount(IBlast token) external view returns (uint256 claimableYield);

    /// @notice Retrieves the claimable yield for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @return claimableYield Yield amount available to claim.
    function readClaimableYield(IBlast blastEthAddress) external view returns (uint256 claimableYield);

    /// @notice Retrieves the gas mode parameters for `account`.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @return etherSeconds Number of seconds required for claimable gas to mature.
    /// @return etherBalance The amount of gas to claim in ETH.
    /// @return lastUpdated Timestamp when gas was updated.
    /// @return gasMode The Gas mode as a {GasMode} variant.
    function readGasParams(IBlast blastEthAddress)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, IBlast.GasMode gasMode);

    /// @notice Retrieves the yield mode set for `account`.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @return yieldMode The yield mode as an integer position in {YieldMode}.
    function readYieldConfiguration(IBlast blastEthAddress) external view returns (uint8 yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim all yield in an ERC20 token for `account`.
    /// @dev Only callable by the admin.
    /// @param amount Yield amount to claim.
    /// @param recipientOfYield The recipient address for yield.
    /// @param token The address of the ERC20 token.
    function claim(uint256 amount, address recipientOfYield, IBlast token) external returns (uint256);

    /// @notice Claim all gas in ETH for `account`.
    /// @dev Only callable by the admin.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @param recipientOfGas The recipient address for gas.
    function claimAllGas(IBlast blastEthAddress, address recipientOfGas) external returns (uint256);

    /// @notice Claim all yield in ETH for `account`.
    /// @dev Only callable by the admin.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @param recipientOfYield The recipient address for yield.
    function claimAllYield(IBlast blastEthAddress, address recipientOfYield) external returns (uint256);

    /// @notice Sets the yield mode for an ERC20 token.
    /// @dev Only callable by the admin.
    /// @param token The address of the ERC20 token.
    /// @param yieldMode Enum representing the yield mode to set.
    function configure(IBlast token, IBlast.YieldMode yieldMode) external;

    /// @notice Sets the yield mode, gas modes and governor address.
    /// @dev Only callable by the admin.
    /// @param blastEthAddress The address of the Blast ETH contract.
    /// @param gasMode Enum representing the gas mode to set.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param governor The address of the new governor.
    function configure(
        IBlast blastEthAddress,
        IBlast.GasMode gasMode,
        IBlast.YieldMode yieldMode,
        address governor
    )
        external;
}
