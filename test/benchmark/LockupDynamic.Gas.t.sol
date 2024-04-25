// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { LockupDynamic } from "src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Benchmark Test for the LockupDynamic contract.
/// @dev This contract creates a markdown file with the gas usage of each function in the benchmarks directory.
contract LockupDynamic_Gas_Test is Benchmark_Test {
    function setUp() public override {
        super.setUp();

        benchmarksFile = string.concat(benchmarksDir, "SablierV2LockupDynamic.md");

        // Create the file if it doesn't exist, otherwise overwrite it
        vm.writeFile({
            path: benchmarksFile,
            data: string.concat(
                "# Benchmarks for implementations in the LockupDynamic contract\n\n",
                "| Implementation | Gas Usage |\n",
                "| --- | --- |\n"
            )
        });
    }

    function testGas_Implementations() external {
        // Set the caller to recipient for `burn` and change timestamp to end time
        resetPrank({ msgSender: users.recipient });
        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        // Set the caller to sender for the next few calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });
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

        // Set the caller to recipient for the next call
        resetPrank({ msgSender: users.recipient });
        gasWithdraw_ByRecipient();
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR EACH IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    function gasBurn() internal {
        lockupDynamic.withdraw(STREAM_1, users.recipient, defaults.DEPOSIT_AMOUNT());

        uint256 beforeGas = gasleft();
        lockupDynamic.burn(STREAM_1);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `burn` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCancel() internal {
        uint256 beforeGas = gasleft();
        lockupDynamic.cancel(STREAM_2);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `cancel` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCreateWithDurations(uint128 totalSegments) internal {
        LockupDynamic.CreateWithDurations memory params = _createWithDurationParams(totalSegments);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithDurations(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat(
            "| `createWithDurations` (",
            vm.toString(totalSegments),
            " segments) | ",
            vm.toString(beforeGas - afterGas),
            " |"
        );

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCreateWithTimestamps(uint128 totalSegments) internal {
        LockupDynamic.CreateWithTimestamps memory params = _createWithTimestampParams(totalSegments);

        uint256 beforeGas = gasleft();
        lockupDynamic.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat(
            "| `createWithTimestamps` (",
            vm.toString(totalSegments),
            " segments) | ",
            vm.toString(beforeGas - afterGas),
            " |"
        );

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasRenounce() internal {
        uint256 beforeGas = gasleft();
        lockupDynamic.renounce(STREAM_3);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `renounce` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw_ByRecipient() internal {
        uint256 beforeGas = gasleft();
        lockupDynamic.withdraw(STREAM_4, users.alice, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Recipient) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw() internal {
        uint256 beforeGas = gasleft();
        lockupDynamic.withdraw(STREAM_5, users.recipient, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Anyone) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createWithDurationParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithDurations memory)
    {
        uint128 amountInEachSegment = defaults.DEPOSIT_AMOUNT() / totalSegments;
        LockupDynamic.SegmentWithDuration[] memory segments_ = new LockupDynamic.SegmentWithDuration[](totalSegments);

        // Populate segments
        for (uint256 i = 0; i < totalSegments; ++i) {
            segments_[i] = (
                LockupDynamic.SegmentWithDuration({
                    amount: amountInEachSegment,
                    exponent: ud2x18(0.5e18),
                    duration: defaults.CLIFF_DURATION()
                })
            );
        }

        return LockupDynamic.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: defaults.TOTAL_AMOUNT(),
            asset: dai,
            cancelable: true,
            transferable: true,
            segments: segments_,
            broker: defaults.broker()
        });
    }

    function _createWithTimestampParams(uint128 totalSegments)
        private
        view
        returns (LockupDynamic.CreateWithTimestamps memory)
    {
        uint128 amountInEachSegment = defaults.DEPOSIT_AMOUNT() / totalSegments;

        LockupDynamic.Segment[] memory segments_ = new LockupDynamic.Segment[](totalSegments);

        // Populate segments
        for (uint256 i = 0; i < totalSegments; ++i) {
            segments_[i] = (
                LockupDynamic.Segment({
                    amount: amountInEachSegment,
                    exponent: ud2x18(0.5e18),
                    timestamp: uint40(block.timestamp + defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        return LockupDynamic.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: defaults.TOTAL_AMOUNT(),
            asset: dai,
            cancelable: true,
            transferable: true,
            startTime: uint40(block.timestamp),
            segments: segments_,
            broker: defaults.broker()
        });
    }
}
