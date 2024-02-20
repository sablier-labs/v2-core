// SPDX-License-Identifier: BSL 1.1 - Copyright 2024 MetaLayer Labs Ltd.
pragma solidity >=0.8.19;

import { IGas } from "src/interfaces/Blast/IGas.sol";
import { IYield } from "src/interfaces/Blast/IYield.sol";
import { GasMode } from "src/interfaces/Blast/IGas.sol";
import { YieldMode } from "src/interfaces/Blast/IYield.sol";

import { Gas } from "./Gas.sol";
import { Yield } from "./Yield.sol";

contract Blast {
    mapping(address => address) public governorMap;

    address public immutable YIELD_CONTRACT;
    address public immutable GAS_CONTRACT;

    constructor() {
        GAS_CONTRACT = address(new Gas());
        YIELD_CONTRACT = address(new Yield());
    }

    /// @notice Checks if the caller is the governor of the contract
    /// @param contractAddress The address of the contract
    /// @return A boolean indicating if the caller is the governor
    function isGovernor(address contractAddress) public view returns (bool) {
        return msg.sender == governorMap[contractAddress];
    }

    /// @notice Checks if the governor is not set for the contract
    /// @param contractAddress The address of the contract
    /// @return boolean indicating if the governor is not set
    function governorNotSet(address contractAddress) internal view returns (bool) {
        return governorMap[contractAddress] == address(0);
    }

    /// @notice Checks if the caller is authorized
    /// @param contractAddress The address of the contract
    /// @return A boolean indicating if the caller is authorized
    function isAuthorized(address contractAddress) public view returns (bool) {
        return isGovernor(contractAddress) || (governorNotSet(contractAddress) && msg.sender == contractAddress);
    }

    /// @notice contract configures its yield and gas modes and sets the governor. called by contract
    /// @param _yieldMode The yield mode to be set
    /// @param _gasMode The gas mode to be set
    /// @param governor The address of the governor to be set
    function configure(YieldMode _yieldMode, GasMode _gasMode, address governor) external {
        // requires that no governor is set for contract
        require(isAuthorized(msg.sender), "not authorized to configure contract");
        // set governor
        governorMap[msg.sender] = governor;
        // set gas mode
        IGas(GAS_CONTRACT).setGasMode(msg.sender, _gasMode);
        // set yield mode
        IYield(YIELD_CONTRACT).configure(msg.sender, uint8(_yieldMode));
    }

    /// @notice Claims all yield for a specific contract. Called by an authorized user
    /// @param contractAddress The address of the contract for which all yield is to be claimed
    /// @param recipientOfYield The address of the recipient of the yield
    /// @return The amount of yield that was claimed
    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256) {
        require(isAuthorized(contractAddress), "Not authorized to claim yield");
        uint256 amount = IYield(YIELD_CONTRACT).getClaimableAmount(contractAddress);
        return IYield(YIELD_CONTRACT).claim(contractAddress, recipientOfYield, amount);
    }

    /// @notice Claims all gas for a specific contract. Called by an authorized user
    /// @param contractAddress The address of the contract for which all gas is to be claimed
    /// @param recipientOfGas The address of the recipient of the gas
    /// @return The amount of gas that was claimed
    function claimAllGas(address contractAddress, address recipientOfGas) external returns (uint256) {
        require(isAuthorized(contractAddress), "Not allowed to claim all gas");
        return IGas(GAS_CONTRACT).claimAll(contractAddress, recipientOfGas);
    }

    /// @notice Claims gas at a minimum claim rate for a specific contract. Called by an authorized user
    /// @param contractAddress The address of the contract for which gas is to be claimed
    /// @param recipientOfGas The address of the recipient of the gas
    /// @param minClaimRateBips The minimum claim rate in basis points
    /// @return The amount of gas that was claimed
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    )
        external
        returns (uint256)
    {
        require(isAuthorized(contractAddress), "Not allowed to claim gas at min claim rate");
        return IGas(GAS_CONTRACT).claimGasAtMinClaimRate(contractAddress, recipientOfGas, minClaimRateBips);
    }

    /// @notice Reads the claimable yield for a specific contract
    /// @param contractAddress The address of the contract for which the claimable yield is to be read
    /// @return claimable yield
    function readClaimableYield(address contractAddress) public view returns (uint256) {
        return IYield(YIELD_CONTRACT).getClaimableAmount(contractAddress);
    }

    /// @notice Reads the yield configuration for a specific contract
    /// @param contractAddress The address of the contract for which the yield configuration is to be read
    /// @return uint8 representing yield enum
    function readYieldConfiguration(address contractAddress) public view returns (uint8) {
        return IYield(YIELD_CONTRACT).getConfiguration(contractAddress);
    }

    /// @notice Reads the gas parameters for a specific contract
    /// @param contractAddress The address of the contract for which the gas parameters are to be read
    /// @return uint256 representing the accumulated ether seconds
    /// @return uint256 representing ether balance
    /// @return uint256 representing last update timestamp
    /// @return GasMode representing the gas mode (VOID, CLAIMABLE)
    function readGasParams(address contractAddress) public view returns (uint256, uint256, uint256, GasMode) {
        return IGas(GAS_CONTRACT).readGasParams(contractAddress);
    }
}
