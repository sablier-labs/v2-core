// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-line-length
pragma solidity >=0.8.13 <0.9.0;
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";
import { Solarray } from "solarray/Solarray.sol";

import { Events } from "src/libraries/Events.sol";
import { Errors } from "src/libraries/Errors.sol";
import { Broker, LockupProStream, Segment } from "src/types/Structs.sol";

import { Pro_Test } from "../Pro.t.sol";

contract CreateWithDeltas_Pro_Test is Pro_Test {
    /// @dev it should revert.
    function test_RevertWhen_LoopCalculationOverflowsBlockGasLimit() external {
        uint40[] memory deltas = new uint40[](1_000_000);
        vm.expectRevert(bytes(""));
        createDefaultStreamWithDeltas(deltas);
    }

    modifier loopCalculationsDoNotOverflowBlockGasLimit() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_DeltasZero() external loopCalculationsDoNotOverflowBlockGasLimit {
        uint40 startTime = getBlockTimestamp();
        uint40[] memory deltas = Solarray.uint40s(DEFAULT_SEGMENT_DELTAS[0], 0);
        uint256 index = 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2LockupPro_SegmentMilestonesNotOrdered.selector,
                index,
                startTime + deltas[0],
                startTime + deltas[0]
            )
        );
        createDefaultStreamWithDeltas(deltas);
    }

    modifier deltasNotZero() {
        _;
    }

    /// @dev it should revert.
    function testFuzz_RevertWhen_SegmentArraysNotEqual(
        uint256 deltaCount
    ) external loopCalculationsDoNotOverflowBlockGasLimit deltasNotZero {
        deltaCount = bound(deltaCount, 1, 1_000);
        vm.assume(deltaCount != params.createWithDeltas.segments.length);

        uint40[] memory deltas = new uint40[](deltaCount);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2LockupPro_SegmentArraysNotEqual.selector,
                params.createWithDeltas.segments.length,
                deltaCount
            )
        );
        createDefaultStreamWithDeltas(deltas);
    }

    modifier segmentArraysEqual() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_MilestonesCalculationsOverflows_StartTimeGreaterThanCalculatedFirstMilestone()
        external
        loopCalculationsDoNotOverflowBlockGasLimit
        deltasNotZero
        segmentArraysEqual
    {
        uint40 startTime = getBlockTimestamp();
        uint40[] memory deltas = Solarray.uint40s(UINT40_MAX, 1);
        Segment[] memory segments = params.createWithDeltas.segments;
        unchecked {
            segments[0].milestone = startTime + deltas[0];
            segments[1].milestone = deltas[0] + deltas[1];
        }
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2LockupPro_StartTimeGreaterThanFirstMilestone.selector,
                startTime,
                segments[0].milestone
            )
        );
        createDefaultStreamWithDeltas(deltas);
    }

    /// @dev it should revert.
    function test_RevertWhen_MilestonesCalculationsOverflows_SegmentMilestonesNotOrdered()
        external
        loopCalculationsDoNotOverflowBlockGasLimit
        deltasNotZero
        segmentArraysEqual
    {
        uint40 startTime = getBlockTimestamp();

        // Create the deltas such that they overflow.
        uint40[] memory deltas = Solarray.uint40s(1, UINT40_MAX, 1);

        // Create new segments that overflow when the milestones are eventually calculated.
        Segment[] memory segments = new Segment[](3);
        unchecked {
            segments[0] = Segment({ amount: 0, exponent: ud2x18(1e18), milestone: startTime + deltas[0] });
            segments[1] = Segment({
                amount: DEFAULT_SEGMENTS[0].amount,
                exponent: DEFAULT_SEGMENTS[0].exponent,
                milestone: segments[0].milestone + deltas[1]
            });
            segments[2] = Segment({
                amount: DEFAULT_SEGMENTS[1].amount,
                exponent: DEFAULT_SEGMENTS[1].exponent,
                milestone: segments[1].milestone + deltas[2]
            });
        }

        // Expect an error.
        uint256 index = 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierV2LockupPro_SegmentMilestonesNotOrdered.selector,
                index,
                segments[0].milestone,
                segments[1].milestone
            )
        );

        // Create the stream.
        pro.createWithDeltas(
            params.createWithDeltas.sender,
            params.createWithDeltas.recipient,
            params.createWithDeltas.grossDepositAmount,
            segments,
            params.createWithDeltas.asset,
            params.createWithDeltas.cancelable,
            deltas,
            params.createWithDeltas.broker
        );
    }

    modifier milestonesCalculationsDoNotOverflow() {
        _;
    }

    /// @dev it should perform the ERC-20 transfers, create the stream, bump the next stream id, and mint the NFT.
    function testFuzz_CreateWithDeltas(
        uint40 delta0,
        uint40 delta1
    )
        external
        loopCalculationsDoNotOverflowBlockGasLimit
        deltasNotZero
        segmentArraysEqual
        milestonesCalculationsDoNotOverflow
    {
        delta0 = boundUint40(delta0, 0, 100);
        delta1 = boundUint40(delta1, 1, UINT40_MAX - getBlockTimestamp() - delta0);

        // Create the deltas.
        uint40[] memory deltas = Solarray.uint40s(delta0, delta1);

        // Adjust the segment milestones to match the fuzzed deltas.
        Segment[] memory segments = params.createWithDeltas.segments;
        segments[0].milestone = getBlockTimestamp() + delta0;
        segments[1].milestone = segments[0].milestone + delta1;

        // Make the sender the funder in this test.
        address funder = params.createWithDeltas.sender;

        // Expect the assets to be transferred from the funder to the SablierV2LockupPro contract.
        vm.expectCall(
            address(params.createWithDeltas.asset),
            abi.encodeCall(IERC20.transferFrom, (funder, address(pro), DEFAULT_NET_DEPOSIT_AMOUNT))
        );

        // Expect the broker fee to be paid to the broker.
        vm.expectCall(
            address(params.createWithDeltas.asset),
            abi.encodeCall(
                IERC20.transferFrom,
                (funder, params.createWithDeltas.broker.addr, DEFAULT_BROKER_FEE_AMOUNT)
            )
        );

        // Create the stream.
        uint256 streamId = pro.createWithDeltas(
            params.createWithDeltas.sender,
            params.createWithDeltas.recipient,
            params.createWithDeltas.grossDepositAmount,
            segments,
            params.createWithDeltas.asset,
            params.createWithDeltas.cancelable,
            deltas,
            params.createWithDeltas.broker
        );

        // Assert that the stream was created.
        LockupProStream memory actualStream = pro.getStream(streamId);
        assertEq(actualStream.amounts, defaultStream.amounts);
        assertEq(actualStream.isCancelable, defaultStream.isCancelable);
        assertEq(actualStream.sender, defaultStream.sender);
        assertEq(actualStream.segments, segments);
        assertEq(actualStream.startTime, defaultStream.startTime);
        assertEq(actualStream.status, defaultStream.status);
        assertEq(actualStream.asset, defaultStream.asset);

        // Assert that the next stream id was bumped.
        uint256 actualNextStreamId = pro.nextStreamId();
        uint256 expectedNextStreamId = streamId + 1;
        assertEq(actualNextStreamId, expectedNextStreamId);

        // Assert that the NFT was minted.
        address actualNFTOwner = pro.ownerOf({ tokenId: streamId });
        address expectedNFTOwner = params.createWithDeltas.recipient;
        assertEq(actualNFTOwner, expectedNFTOwner);
    }

    /// @dev it should record the protocol fee.
    function test_CreateWithDeltas_ProtocolFee()
        external
        loopCalculationsDoNotOverflowBlockGasLimit
        deltasNotZero
        segmentArraysEqual
        milestonesCalculationsDoNotOverflow
    {
        // Load the initial protocol revenues.
        uint128 initialProtocolRevenues = pro.getProtocolRevenues(params.createWithDeltas.asset);

        // Create the default stream.
        createDefaultStreamWithDeltas();

        // Assert that the protocol fee was recorded.
        uint128 actualProtocolRevenues = pro.getProtocolRevenues(params.createWithDeltas.asset);
        uint128 expectedProtocolRevenues = initialProtocolRevenues + DEFAULT_PROTOCOL_FEE_AMOUNT;
        assertEq(actualProtocolRevenues, expectedProtocolRevenues);
    }

    /// @dev it should create a CreateLockupProStream event.
    function test_CreateWithDeltas_Event()
        external
        loopCalculationsDoNotOverflowBlockGasLimit
        deltasNotZero
        segmentArraysEqual
        milestonesCalculationsDoNotOverflow
    {
        uint256 streamId = pro.nextStreamId();
        address funder = params.createWithDeltas.sender;
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.CreateLockupProStream({
            streamId: streamId,
            funder: funder,
            sender: params.createWithDeltas.sender,
            recipient: params.createWithDeltas.recipient,
            amounts: DEFAULT_CREATE_AMOUNTS,
            segments: params.createWithDeltas.segments,
            asset: params.createWithDeltas.asset,
            cancelable: params.createWithDeltas.cancelable,
            startTime: DEFAULT_START_TIME,
            stopTime: DEFAULT_STOP_TIME,
            broker: params.createWithDeltas.broker.addr
        });
        createDefaultStreamWithDeltas();
    }
}