// SPDX-License-Identifier: BSL 1.1 - Copyright 2024 MetaLayer Labs Ltd.
pragma solidity >=0.8.19;

/// @notice Enum representing the gas modes on the Blast network.
/// @custom:value0 VOID base + priority fees go to the sequencer operator.
/// @custom:value1 CLAIMABLE base + priority fees spent on the protocol can be claimed separately.
enum GasMode {
    VOID,
    CLAIMABLE
}

/// @title IGas
/// @notice This interface is responsible for interacting with the Gas module of Blast L2.
/// @dev https://docs.blast.io/
interface IGas {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the gas mode parameters for `account`.
    /// @param contractAddress The address of the contract for which the gas params are to be read
    /// @return etherSeconds Number of seconds required for claimable gas to mature.
    /// @return etherBalance The amount of gas to claim in ETH.
    /// @return lastUpdated Timestamp when gas was updated.
    /// @return gasMode The Gas mode as a {GasMode} variant.
    function readGasParams(address contractAddress)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function claim(
        address contractAddress,
        address recipient,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        returns (uint256);

    function claimAll(address contractAddress, address recipient) external returns (uint256);

    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipient,
        uint256 minClaimRateBips
    )
        external
        returns (uint256);

    function claimMax(address contractAddress, address recipient) external returns (uint256);

    function setGasMode(address contractAddress, GasMode mode) external;
}
