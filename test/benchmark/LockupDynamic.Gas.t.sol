// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { ud } from "@prb/math/src/UD60x18.sol";
import { Broker, LockupDynamic } from "src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Tests used to benchmark LockupDynamic.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupDynamic_Gas_Test is Benchmark_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/
    function setUp() public override {
        super.setUp();

        lockup = lockupDynamic;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testGas_Implementations() external {
        // Set the file path.
        benchmarksFile = string.concat(benchmarksDir, "SablierV2LockupDynamic.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarksFile,
            data: string.concat("# Benchmarks for LockupDynamic\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n")
        });

        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();

        // Create streams with different number of segments
        gasCreateWithDurations({ totalSegments: 2 });
        gasCreateWithDurations({ totalSegments: 10 });
        gasCreateWithDurations({ totalSegments: 100 });
        gasCreateWithTimestamps({ totalSegments: 2 });
        gasCreateWithTimestamps({ totalSegments: 10 });
        gasCreateWithTimestamps({ totalSegments: 100 });

        gasRenounce();
        gasWithdraw();

        gasWithdraw_ByRecipient();
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    // The following function is also used in the estimation of `MAX_SEGMENT_COUNT`.
    function computeGas_CreateWithDurations(uint128 totalSegments) public returns (uint256 gasUsage) {
        LockupDynamic.CreateWithDurations memory params = _createWithDurationParams(totalSegments);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithDurations(params);
        uint256 afterGas = gasleft();

        gasUsage = beforeGas - afterGas;
    }

    function gasCreateWithDurations(uint128 totalSegments) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });

        uint256 gas = computeGas_CreateWithDurations(totalSegments);

        contentToAppend = string.concat(
            "| `createWithDurations` (", vm.toString(totalSegments), " segments) | ", vm.toString(gas), " |"
        );

        // Append the data to the file
        _appendToFile(benchmarksFile, contentToAppend);
    }

    function gasCreateWithTimestamps(uint128 totalSegments) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });

        LockupDynamic.CreateWithTimestamps memory params = _createWithTimestampParams(totalSegments);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat(
            "| `createWithTimestamps` (",
            vm.toString(totalSegments),
            " segments) | ",
            vm.toString(beforeGas - afterGas),
            " |"
        );

        // Append the data to the file
        _appendToFile(benchmarksFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createWithDurationParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithDurations memory)
    {
        LockupDynamic.SegmentWithDuration[] memory segments_ = new LockupDynamic.SegmentWithDuration[](totalSegments);

        // Populate segments.
        for (uint256 i = 0; i < totalSegments; ++i) {
            segments_[i] = (
                LockupDynamic.SegmentWithDuration({
                    amount: AMOUNT_PER_SEGMENT,
                    exponent: ud2x18(0.5e18),
                    duration: defaults.CLIFF_DURATION()
                })
            );
        }

        return LockupDynamic.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: AMOUNT_PER_SEGMENT * totalSegments,
            asset: dai,
            cancelable: true,
            transferable: true,
            segments: segments_,
            broker: Broker({ account: users.broker, fee: ud(0) })
        });
    }

    function _createWithTimestampParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithTimestamps memory)
    {
        LockupDynamic.Segment[] memory segments_ = new LockupDynamic.Segment[](totalSegments);

        // Populate segments.
        for (uint256 i = 0; i < totalSegments; ++i) {
            segments_[i] = (
                LockupDynamic.Segment({
                    amount: AMOUNT_PER_SEGMENT,
                    exponent: ud2x18(0.5e18),
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        return LockupDynamic.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: AMOUNT_PER_SEGMENT * totalSegments,
            asset: dai,
            cancelable: true,
            transferable: true,
            startTime: getBlockTimestamp(),
            segments: segments_,
            broker: Broker({ account: users.broker, fee: ud(0) })
        });
    }
}
