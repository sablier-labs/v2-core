// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

import { Broker, LockupDynamic } from "../src/types/DataTypes.sol";
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
        benchmarkResultsFile = string.concat(benchmarkResults, "SablierV2LockupDynamic.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
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

        (uint256 streamId1, uint256 streamId2, uint256 streamId3, uint256 streamId4) =
            _createFourStreams({ totalSegments: 2 });

        gasWithdraw_ByRecipient(streamId1, streamId2, "(2 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(2 segments)");

        (streamId1, streamId2, streamId3, streamId4) = _createFourStreams({ totalSegments: 10 });
        gasWithdraw_ByRecipient(streamId1, streamId2, "(10 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(10 segments)");

        (streamId1, streamId2, streamId3, streamId4) = _createFourStreams({ totalSegments: 100 });
        gasWithdraw_ByRecipient(streamId1, streamId2, "(100 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(100 segments)");
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
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint256 gas = computeGas_CreateWithDurations(totalSegments);

        contentToAppend = string.concat(
            "| `createWithDurations` (",
            vm.toString(totalSegments),
            " segments) (Broker fee set) | ",
            vm.toString(gas),
            " |"
        );

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithDurations({ params: _createWithDurationParams(totalSegments) });
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurations` (", vm.toString(totalSegments), " segments) (Broker fee not set) | ", gasUsed, " |"
        );

        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestamps(uint128 totalSegments) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });

        LockupDynamic.CreateWithTimestamps memory params = _createWithTimestampParams(totalSegments);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithTimestamps(params);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestamps` (", vm.toString(totalSegments), " segments) (Broker fee set) | ", gasUsed, " |"
        );

        // Append the data to the file
        _appendToFile(benchmarkResultsFile, contentToAppend);

        params = _createWithTimestampParams(totalSegments, ud(0));

        beforeGas = gasleft();
        lockupDynamic.createWithTimestamps(params);
        gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestamps` (",
            vm.toString(totalSegments),
            " segments) (Broker fee not set) | ",
            gasUsed,
            " |"
        );

        // Append the data to the file
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createFourStreams(uint128 totalSegments)
        private
        returns (uint256 streamId1, uint256 streamId2, uint256 streamId3, uint256 streamId4)
    {
        streamId1 = lockupDynamic.createWithDurations({ params: _createWithDurationParams(totalSegments) });
        streamId2 = lockupDynamic.createWithDurations({ params: _createWithDurationParams(totalSegments) });
        streamId3 = lockupDynamic.createWithDurations({ params: _createWithDurationParams(totalSegments) });
        streamId4 = lockupDynamic.createWithDurations({ params: _createWithDurationParams(totalSegments) });
    }

    function _createWithDurationParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithDurations memory)
    {
        return _createWithDurationParams(totalSegments, defaults.BROKER_FEE());
    }

    function _createWithDurationParams(
        uint128 totalSegments,
        UD60x18 brokerFee
    )
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

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalSegments;

        return LockupDynamic.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: _calculateTotalAmount(depositAmount, brokerFee),
            asset: dai,
            cancelable: true,
            transferable: true,
            segments: segments_,
            broker: Broker({ account: users.broker, fee: brokerFee })
        });
    }

    function _createWithTimestampParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithTimestamps memory)
    {
        return _createWithTimestampParams(totalSegments, defaults.BROKER_FEE());
    }

    function _createWithTimestampParams(
        uint128 totalSegments,
        UD60x18 brokerFee
    )
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

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalSegments;

        return LockupDynamic.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: _calculateTotalAmount(depositAmount, brokerFee),
            asset: dai,
            cancelable: true,
            transferable: true,
            startTime: getBlockTimestamp(),
            segments: segments_,
            broker: Broker({ account: users.broker, fee: brokerFee })
        });
    }
}
