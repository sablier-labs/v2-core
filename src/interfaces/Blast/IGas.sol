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

    /// @notice Allows a contract to claim a specified amount of gas, at a claim rate set by the number of gas seconds
    /// @param contractAddress The address of the contract
    /// @param recipient The address of the recipient of the gas
    /// @param gasToClaim The amount of gas to claim
    /// @param gasSecondsToConsume The amount of gas seconds to consume
    /// @return The amount of gas claimed (gasToClaim - penalty)
    function claim(
        address contractAddress,
        address recipient,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        returns (uint256);

    /// @notice Allows a contract to claim all gas
    /// @param contractAddress The address of the contract
    /// @param recipient The address of the recipient of the gas
    /// @return The amount of gas claimed
    function claimAll(address contractAddress, address recipient) external returns (uint256);

    /// @notice Allows a user to claim gas at a minimum claim rate
    /// @param contractAddress The address of the contract
    /// @param recipient The address of the recipient of the gas
    /// @param minClaimRateBips The minimum claim rate in basis points
    /// @return The amount of gas claimed
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipient,
        uint256 minClaimRateBips
    )
        external
        returns (uint256);

    /// @notice Allows a contract to claim all gas at the highest possible claim rate
    /// @param contractAddress The address of the contract
    /// @param recipient The address of the recipient of the gas
    /// @return The amount of gas claimed
    function claimMax(address contractAddress, address recipient) external returns (uint256);

    /// @notice Allows an authorized user to set the gas mode for a contract via the BlastConfigurationContract
    /// @param contractAddress The address of the contract
    /// @param mode The new gas mode for the contract
    function setGasMode(address contractAddress, GasMode mode) external;
}
