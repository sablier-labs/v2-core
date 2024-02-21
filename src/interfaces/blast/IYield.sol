// SPDX-License-Identifier: BSL 1.1 - Copyright 2024 MetaLayer Labs Ltd.
pragma solidity >=0.8.19;

/// @notice Enum representing the yield modes on the Blast network.
/// @custom:value0 AUTOMATIC yield is accumulated through rebasing; this changes the account balance.
/// @custom:value1 VOID No yield is earned.
/// @custom:value2 CLAIMABLE yield can be claimed separately; no change in account balance.
enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

/// @title IYield
/// @notice This interface is responsible for interacting with the Yield module of Blast L2.
/// @dev https://docs.blast.io/
interface IYield {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Query an CLAIMABLE account's claimable yield.
    /// @param contractAddress The address of the contract for which the claimable amount is to be read
    /// @return amount Claimable amount.
    function getClaimableAmount(address contractAddress) external view returns (uint256 amount);

    /// @notice Query an account's configured yield mode.
    /// @param contractAddress The address of the contract for which the configuration is to be read.
    /// @return Configured yield mode.
    function getConfiguration(address contractAddress) external view returns (uint8);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function claim(
        address contractAddress,
        address recipientOfYield,
        uint256 desiredAmount
    )
        external
        returns (uint256);

    function configure(address contractAddress, uint8 flags) external returns (uint256);
}
