// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title IBlast
/// @notice This interface is responsible for interacting with the Blast contracts.
/// @dev https://docs.blast.io/
interface IBlast {
    /// @notice Enum representing the gas modes on the Blast network.
    /// @custom:value0 VOID base + priority fees go to the sequencer operator.
    /// @custom:value1 CLAIMABLE base + priority fees spent on the protocol can be claimed separately.
    enum GasMode {
        VOID,
        CLAIMABLE
    }

    /// @notice Enum representing the yield modes on the Blast network.
    /// @custom:value0 AUTOMATIC yield is accumulated through rebasing; this changes the account balance.
    /// @custom:value1 VOID No yield is earned.
    /// @custom:value2 CLAIMABLE yield can be claimed separately; no change in account balance.
    enum YieldMode {
        AUTOMATIC,
        VOID,
        CLAIMABLE
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the claimable yield in an ERC20 token for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @param account The address of the account.
    /// @return claimableYield Yield amount available to claim.
    function getClaimableAmount(address account) external view returns (uint256 claimableYield);

    /// @notice Retrieves the claimable yield for `account`.
    /// @dev Requires {YieldMode} set to CLAIMABLE.
    /// @param account The address of the account.
    /// @return claimableYield Yield amount available to claim.
    function readClaimableYield(address account) external view returns (uint256 claimableYield);

    /// @notice Retrieves the gas mode parameters for `account`.
    /// @param account The address of the account.
    /// @return etherSeconds Number of seconds required for claimable gas to mature.
    /// @return etherBalance The amount of gas to claim in ETH.
    /// @return lastUpdated Timestamp when gas was updated.
    /// @return gasMode The Gas mode as a {GasMode} variant.
    function readGasParams(address account)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode);

    /// @notice Retrieves the yield mode set for `account`.
    /// @param account The address of the account.
    /// @return yieldMode The yield mode as an integer position in {YieldMode}.
    function readYieldConfiguration(address account) external view returns (uint8 yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim all yield in an ERC20 token for `account`.
    /// @dev This function should only be called by the contract itself.
    /// @param recipientOfYield The recipient address for yield.
    /// @param amount Yield amount to claim.
    function claim(address recipientOfYield, uint256 amount) external returns (uint256);

    /// @notice Claim all gas in ETH for `account`.
    /// @dev This function should only be called by the contract itself.
    /// @param account The address of the account.
    /// @param recipientOfGas The recipient address for gas.
    function claimAllGas(address account, address recipientOfGas) external returns (uint256);

    /// @notice Claim all yield in ETH for `account`.
    /// @dev This function should only be called by the contract itself.
    /// @param account The address of the account.
    /// @param recipientOfYield The recipient address for yield.
    function claimAllYield(address account, address recipientOfYield) external returns (uint256);

    /// @notice Sets the yield mode for an ERC20 token.
    /// @dev This function should only be called by the contract itself.
    /// @param yieldMode Enum representing the yield mode to set.
    function configure(YieldMode yieldMode) external;

    /// @notice Sets the yield mode, gas modes and governor address.
    /// @dev This function should only be called by the contract itself.
    /// @param yieldMode Enum representing the yield mode to set.
    /// @param gasMode Enum representing the gas mode to set.
    /// @param governor The address of the new governor.
    function configure(YieldMode yieldMode, GasMode gasMode, address governor) external;
}
