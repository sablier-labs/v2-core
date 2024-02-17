// SPDX-License-Identifier: BSL 1.1 - Copyright 2024 MetaLayer Labs Ltd.
pragma solidity >=0.8.19;

import { GasMode, IGas } from "./IGas.sol";
import { IYield, YieldMode } from "./IYield.sol";

/// @title IBlast
/// @notice This interface is responsible for interacting with the Yield and Gas modules of Blast L2.
/// @dev https://docs.blast.io/
interface IBlast is IGas, IYield {
    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reads the claimable yield for a specific contract
    /// @param contractAddress The address of the contract for which the claimable yield is to be read.
    /// @return claimableYield claimable yield.
    function readClaimableYield(address contractAddress) external view returns (uint256 claimableYield);

    /// @notice Reads the yield configuration for a specific contract.
    /// @param contractAddress The address of the contract for which the yield configuration is to be read.
    /// @return yieldMode representing yield enum.
    function readYieldConfiguration(address contractAddress) external view returns (uint8 yieldMode);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claims all gas for a specific contract.
    /// @dev Called by an authorized user.
    /// @param contractAddress The address of the contract for which all gas is to be claimed.
    /// @param recipientOfGas The address of the recipient of the gas.
    /// @return uint256 The amount of gas that was claimed
    function claimAllGas(address contractAddress, address recipientOfGas) external returns (uint256);

    /// @notice Claims all yield for a specific contract.
    /// @dev Called by an authorized user.
    /// @param contractAddress The address of the contract for which all yield is to be claimed.
    /// @param recipientOfYield The address of the recipient of the yield.
    /// @return uint256 The amount of yield that was claimed
    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256);

    /// @notice contract configures its yield and gas modes and sets the governor.
    /// @dev This function should only be called by the contract itself.
    /// @param _yieldMode The yield mode to be set.
    /// @param _gasMode The gas mode to be set.
    /// @param governor The address of the governor to be set.
    function configure(YieldMode _yieldMode, GasMode _gasMode, address governor) external;
}
