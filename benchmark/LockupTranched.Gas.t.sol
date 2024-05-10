// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

import { Broker, LockupTranched } from "../src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Tests used to benchmark LockupTranched.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupTranched_Gas_Test is Benchmark_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();

        lockup = lockupTranched;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testGas_Implementations() external {
        // Set the file path.
        benchmarkResultsFile = string.concat(benchmarkResults, "SablierV2LockupTranched.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
            data: string.concat(
                "# Benchmarks for LockupTranched\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();

        // Create streams with different number of tranches.
        gasCreateWithDurations({ totalTranches: 2 });
        gasCreateWithDurations({ totalTranches: 10 });
        gasCreateWithDurations({ totalTranches: 100 });
        gasCreateWithTimestamps({ totalTranches: 2 });
        gasCreateWithTimestamps({ totalTranches: 10 });
        gasCreateWithTimestamps({ totalTranches: 100 });

        gasRenounce();

        (uint256 streamId1, uint256 streamId2, uint256 streamId3, uint256 streamId4) =
            _createFourStreams({ totalTranches: 2 });
        gasWithdraw_ByRecipient(streamId1, streamId2, "(2 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(2 segments)");

        (streamId1, streamId2, streamId3, streamId4) = _createFourStreams({ totalTranches: 10 });
        gasWithdraw_ByRecipient(streamId1, streamId2, "(10 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(10 segments)");

        (streamId1, streamId2, streamId3, streamId4) = _createFourStreams({ totalTranches: 100 });
        gasWithdraw_ByRecipient(streamId1, streamId2, "(100 segments)");
        gasWithdraw_ByAnyone(streamId3, streamId4, "(100 segments)");
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    // The following function is also used in the estimation of `MAX_TRANCHE_COUNT`
    function computeGas_CreateWithDurations(uint128 totalTranches) public returns (uint256 gasUsage) {
        LockupTranched.CreateWithDurations memory params = _createWithDurationParams(totalTranches);

        uint256 beforeGas = gasleft();
        lockupTranched.createWithDurations(params);
        uint256 afterGas = gasleft();

        gasUsage = beforeGas - afterGas;
    }

    function gasCreateWithDurations(uint128 totalTranches) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint256 gas = computeGas_CreateWithDurations(totalTranches);

        contentToAppend = string.concat(
            "| `createWithDurations` (",
            vm.toString(totalTranches),
            " tranches) (Broker fee set) | ",
            vm.toString(gas),
            " |"
        );

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);

        uint256 beforeGas = gasleft();
        lockupTranched.createWithDurations({ params: _createWithDurationParams(totalTranches, ud(0)) });
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithDurations` (", vm.toString(totalTranches), " tranches) (Broker fee not set) | ", gasUsed, " |"
        );

        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestamps(uint128 totalTranches) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint256 beforeGas = gasleft();
        lockupTranched.createWithTimestamps({ params: _createWithTimestampParams(totalTranches) });
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestamps` (", vm.toString(totalTranches), " tranches) (Broker fee set) | ", gasUsed, " |"
        );

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);

        beforeGas = gasleft();
        lockupTranched.createWithTimestamps({ params: _createWithTimestampParams(totalTranches, ud(0)) });
        gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend = string.concat(
            "| `createWithTimestamps` (",
            vm.toString(totalTranches),
            " tranches) (Broker fee not set) | ",
            gasUsed,
            " |"
        );

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createFourStreams(uint128 totalTranches)
        private
        returns (uint256 streamId1, uint256 streamId2, uint256 streamId3, uint256 streamId4)
    {
        streamId1 = lockupTranched.createWithDurations({ params: _createWithDurationParams(totalTranches) });
        streamId2 = lockupTranched.createWithDurations({ params: _createWithDurationParams(totalTranches) });
        streamId3 = lockupTranched.createWithDurations({ params: _createWithDurationParams(totalTranches) });
        streamId4 = lockupTranched.createWithDurations({ params: _createWithDurationParams(totalTranches) });
    }

    function _createWithDurationParams(uint128 totalTranches)
        private
        view
        returns (LockupTranched.CreateWithDurations memory)
    {
        return _createWithDurationParams(totalTranches, defaults.BROKER_FEE());
    }

    function _createWithDurationParams(
        uint128 totalTranches,
        UD60x18 brokerFee
    )
        private
        view
        returns (LockupTranched.CreateWithDurations memory)
    {
        LockupTranched.TrancheWithDuration[] memory tranches_ = new LockupTranched.TrancheWithDuration[](totalTranches);

        // Populate tranches
        for (uint256 i = 0; i < totalTranches; ++i) {
            tranches_[i] = (
                LockupTranched.TrancheWithDuration({ amount: AMOUNT_PER_TRANCHE, duration: defaults.CLIFF_DURATION() })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalTranches;

        return LockupTranched.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: _calculateTotalAmount(depositAmount, brokerFee),
            asset: dai,
            cancelable: true,
            transferable: true,
            tranches: tranches_,
            broker: Broker({ account: users.broker, fee: brokerFee })
        });
    }

    function _createWithTimestampParams(uint128 totalTranches)
        private
        view
        returns (LockupTranched.CreateWithTimestamps memory)
    {
        return _createWithTimestampParams(totalTranches, defaults.BROKER_FEE());
    }

    function _createWithTimestampParams(
        uint128 totalTranches,
        UD60x18 brokerFee
    )
        private
        view
        returns (LockupTranched.CreateWithTimestamps memory)
    {
        LockupTranched.Tranche[] memory tranches_ = new LockupTranched.Tranche[](totalTranches);

        // Populate tranches.
        for (uint256 i = 0; i < totalTranches; ++i) {
            tranches_[i] = (
                LockupTranched.Tranche({
                    amount: AMOUNT_PER_TRANCHE,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalTranches;

        return LockupTranched.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: _calculateTotalAmount(depositAmount, brokerFee),
            asset: dai,
            cancelable: true,
            transferable: true,
            startTime: getBlockTimestamp(),
            tranches: tranches_,
            broker: Broker({ account: users.broker, fee: brokerFee })
        });
    }
}
