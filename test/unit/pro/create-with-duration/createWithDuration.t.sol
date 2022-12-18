// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SD1x18 } from "@prb/math/SD1x18.sol";

import { DataTypes } from "src/libraries/DataTypes.sol";
import { Errors } from "src/libraries/Errors.sol";

import { SablierV2ProTest } from "../SablierV2ProTest.t.sol";

contract CreateWithDuration__Test is SablierV2ProTest {
    /// @dev it should revert.
    function testCannotCreateWithDuration__LoopCalculationOverflowsBlockGasLimit() external {
        uint40[] memory segmentDeltas = new uint40[](1_000_000);
        vm.expectRevert(bytes(""));
        sablierV2Pro.createWithDuration(
            daiStream.sender,
            users.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.cancelable,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            segmentDeltas
        );
    }

    modifier LoopCalculationDoesNotOverflowBlockGasLimit() {
        _;
    }

    /// @dev it should revert.
    function testCannotCreateWithDuration__SegmentDeltaCountNotEqual()
        external
        LoopCalculationDoesNotOverflowBlockGasLimit
    {
        uint256 deltaCount = daiStream.segmentAmounts.length + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2Pro__SegmentCountsNotEqual.selector,
                daiStream.segmentAmounts.length,
                daiStream.segmentExponents.length,
                deltaCount
            )
        );
        uint40[] memory segmentDeltas = new uint40[](deltaCount);
        for (uint40 i = 0; i < deltaCount; ) {
            segmentDeltas[i] = i;
            unchecked {
                i += 1;
            }
        }
        sablierV2Pro.createWithDuration(
            daiStream.sender,
            users.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.cancelable,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            segmentDeltas
        );
    }

    modifier SegmentDeltaEqual() {
        _;
    }

    modifier MilestonesCalculationOverflows() {
        _;
    }

    /// @dev it should revert.
    function testCannotCreateWithDuration__StartTimeGreaterThanCalculatedFirstMilestone()
        external
        LoopCalculationDoesNotOverflowBlockGasLimit
        SegmentDeltaEqual
        MilestonesCalculationOverflows
    {
        uint40 startTime = uint40(block.timestamp);
        uint40[] memory segmentDeltas = createDynamicUint40Array(UINT40_MAX, 1);
        uint40[] memory segmentMilestones = new uint40[](2);
        unchecked {
            segmentMilestones[0] = startTime + segmentDeltas[0];
            segmentMilestones[1] = segmentMilestones[0] + segmentDeltas[1];
        }
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2Pro__StartTimeGreaterThanFirstMilestone.selector,
                startTime,
                segmentMilestones[0]
            )
        );
        sablierV2Pro.createWithDuration(
            daiStream.sender,
            users.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.cancelable,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            segmentDeltas
        );
    }

    /// @dev it should revert.
    function testCannotCreateWithDuration__SegmentMilestonesNotOrdered()
        external
        LoopCalculationDoesNotOverflowBlockGasLimit
        SegmentDeltaEqual
        MilestonesCalculationOverflows
    {
        uint40 startTime = uint40(block.timestamp);
        uint128[] memory segmentAmounts = createDynamicUint128Array(0, SEGMENT_AMOUNTS_DAI[0], SEGMENT_AMOUNTS_DAI[1]);
        SD1x18[] memory segmentExponents = createDynamicArray(
            SD1x18.wrap(1e18),
            SEGMENT_EXPONENTS[0],
            SEGMENT_EXPONENTS[1]
        );
        uint40[] memory segmentDeltas = createDynamicUint40Array(uint40(1), UINT40_MAX, 1);
        uint40[] memory segmentMilestones = new uint40[](3);
        unchecked {
            segmentMilestones[0] = startTime + segmentDeltas[0];
            segmentMilestones[1] = segmentMilestones[0] + segmentDeltas[1];
            segmentMilestones[2] = segmentMilestones[1] + segmentDeltas[2];
        }
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2Pro__SegmentMilestonesNotOrdered.selector,
                1,
                segmentMilestones[0],
                segmentMilestones[1]
            )
        );
        sablierV2Pro.createWithDuration(
            daiStream.sender,
            users.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.cancelable,
            segmentAmounts,
            segmentExponents,
            segmentDeltas
        );
    }

    modifier MilestonesCalculationDoesNotOverflow() {
        _;
    }

    /// @dev it should create the stream with duration.
    function testCreateWithDuration()
        external
        LoopCalculationDoesNotOverflowBlockGasLimit
        SegmentDeltaEqual
        MilestonesCalculationDoesNotOverflow
    {
        uint256 daiStreamId = sablierV2Pro.createWithDuration(
            daiStream.sender,
            users.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.cancelable,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            SEGMENT_DELTAS
        );
        DataTypes.ProStream memory actualStream = sablierV2Pro.getStream(daiStreamId);
        DataTypes.ProStream memory expectedStream = daiStream;
        assertEq(actualStream, expectedStream);
    }
}