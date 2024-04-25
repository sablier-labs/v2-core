// solhint-disable no-console
pragma solidity >=0.8.22 <0.9.0;

import { LockupDynamic_Gas_Test } from "test/benchmark/LockupDynamic.Gas.t.sol";
import { LockupTranched_Gas_Test } from "test/benchmark/LockupTranched.Gas.t.sol";

import { BaseScript } from "./Base.s.sol";

contract EstimateMaxCount is BaseScript {
    /// @notice Estimate the maximum number of segments
    /// @param blockGasLimit The block gas limit
    /// @return count maximum number of segments that can be created within the block gas limit
    /// @return gasUsed gas consumed by the function when maximum number of segments are created
    function estimateSegments(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = 240;

        LockupDynamic_Gas_Test lockupDynamicGasTest = new LockupDynamic_Gas_Test();
        lockupDynamicGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed + 21_000) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupDynamicGasTest.computeGas_CreateWithDurations(count + 10);
        }

        // Subtract 10 from `count` as an additional precaution and add 21,000 to `gasUsed` to account for the minimum
        // transaction gas limit.
        return (count - 10, gasUsed + 21_000);
    }

    /// @notice Estimate the maximum number of tranches
    /// @param blockGasLimit The block gas limit
    /// @return count maximum number of tranches that can be created within the block gas limit
    /// @return gasUsed gas consumed by the function when maximum number of tranches are created
    function estimateTranches(uint256 blockGasLimit) public virtual returns (uint128 count, uint256 gasUsed) {
        count = 240;

        LockupTranched_Gas_Test lockupTranchedGasTest = new LockupTranched_Gas_Test();
        lockupTranchedGasTest.setUp();

        uint256 gasConsumed = 0;
        while (blockGasLimit > gasConsumed + 21_000) {
            count += 10;
            gasUsed = gasConsumed;

            // Estimate the gas consumed by adding 10 segments
            gasConsumed = lockupTranchedGasTest.computeGas_CreateWithDurations(count + 10);
        }

        // Subtract 10 from `count` as an additional precaution and add 21,000 to `gasUsed` to account for the minimum
        // transaction gas limit.
        return (count - 10, gasUsed + 21_000);
    }
}
