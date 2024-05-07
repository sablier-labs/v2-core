// solhint-disable no-console
pragma solidity >=0.8.22 <0.9.0;

import { LockupDynamic_Gas_Test } from "../test/benchmark/LockupDynamic.Gas.t.sol";
import { LockupTranched_Gas_Test } from "../test/benchmark/LockupTranched.Gas.t.sol";

import { BaseScript } from "./Base.s.sol";

contract EstimateMaxCount is BaseScript {
    // Buffer gas units to be deducted from the block gas limit so that the max count never exceeds the block limit.
    uint256 public constant BUFFER_GAS = 1_000_000;

    // Initial guess for the maximum number of segments/tranches.
    uint128 public constant INITIAL_GUESS = 240;

    /// @notice Estimate the maximum number of segments allowed in LockupDynamic.
    /// @param blockGasLimit The block gas limit of the chain.
    /// @return count The maximum number of segments that can be created given the block gas limit.
    /// @return gasUsed The gas consumed by the function when maximum number of segments are created.
    function estimateSegments(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = INITIAL_GUESS;

        // Subtract `BUFFER_GAS` from `blockGasLimit` as an additional precaution to account for the dynamic gas for
        // ether transfer on different chains.
        blockGasLimit -= BUFFER_GAS;

        LockupDynamic_Gas_Test lockupDynamicGasTest = new LockupDynamic_Gas_Test();
        lockupDynamicGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupDynamicGasTest.computeGas_CreateWithDurations(count + 10);
        }

        return (count, gasUsed);
    }

    /// @notice Estimate the maximum number of tranches allowed in LockupTranched.
    /// @param blockGasLimit The block gas limit of the chain.
    /// @return count The maximum number of tranches that can be created given the block gas limit.
    /// @return gasUsed The gas consumed by the function when maximum number of tranches are created.
    function estimateTranches(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = INITIAL_GUESS;

        // Subtract `BUFFER_GAS` from `blockGasLimit` as an additional precaution to account for the dynamic gas for
        // ether transfer on different chains.
        blockGasLimit -= BUFFER_GAS;

        LockupTranched_Gas_Test lockupTranchedGasTest = new LockupTranched_Gas_Test();
        lockupTranchedGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupTranchedGasTest.computeGas_CreateWithDurations(count + 10);
        }

        return (count, gasUsed);
    }
}
