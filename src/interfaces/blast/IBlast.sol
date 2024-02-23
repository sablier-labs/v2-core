// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

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

/// @title IBlast
/// @notice Interface for Blast contract.
/// @dev See: https://docs.blast.io/
interface IBlast {
    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Configures the yield and gas modes and sets the governor.
    /// @param yieldMode The yield mode to be set.
    /// @param gasMode The gas mode to be set.
    /// @param governor The address of the governor to be set.
    function configure(YieldMode yieldMode, GasMode gasMode, address governor) external;
}
