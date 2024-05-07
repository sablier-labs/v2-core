// solhint-disable no-console
pragma solidity >=0.8.22 <0.9.0;

import { LockupDynamic_Gas_Test } from "../test/benchmark/LockupDynamic.Gas.t.sol";
import { LockupTranched_Gas_Test } from "../test/benchmark/LockupTranched.Gas.t.sol";

import { BaseScript } from "./Base.s.sol";

contract EstimateMaxCount is BaseScript {
    // Gas units required for ether transfer.
    uint256 public constant ETH_TRANSFER_GAS = 21_000;

    // Initial guess for the maximum number of segments/tranches.
    uint128 public constant INITIAL_GUESS = 240;

    /// @notice Estimate the maximum number of segments allowed in LockupDynamic.
    /// @param blockGasLimit The block gas limit of the chain.
    /// @return count The maximum number of segments that can be created given the block gas limit.
    /// @return gasUsed The gas consumed by the function when maximum number of segments are created.
    function estimateSegments(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = INITIAL_GUESS;

        LockupDynamic_Gas_Test lockupDynamicGasTest = new LockupDynamic_Gas_Test();
        lockupDynamicGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed + ETH_TRANSFER_GAS) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupDynamicGasTest.computeGas_CreateWithDurations(count + 10);
        }

        // Subtract 10 from `count` as an additional precaution and add the base fee to `gasUsed` to account for the
        // minimum transaction gas limit.
        return (count - 10, gasUsed + ETH_TRANSFER_GAS);
    }

    /// @notice Estimate the maximum number of tranches allowed in LockupTranched.
    /// @param blockGasLimit The block gas limit of the chain.
    /// @return count The maximum number of tranches that can be created given the block gas limit.
    /// @return gasUsed The gas consumed by the function when maximum number of tranches are created.
    function estimateTranches(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = INITIAL_GUESS;

        LockupTranched_Gas_Test lockupTranchedGasTest = new LockupTranched_Gas_Test();
        lockupTranchedGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed + ETH_TRANSFER_GAS) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupTranchedGasTest.computeGas_CreateWithDurations(count + 10);
        }

        // Subtract 10 from `count` as an additional precaution and add the base fee to `gasUsed` to account for the
        // minimum transaction gas limit.
        return (count - 10, gasUsed + ETH_TRANSFER_GAS);
    }
}
