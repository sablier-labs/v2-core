// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Cliff } from "@sablier/v2-core/interfaces/ISablierV2Cliff.sol";

import { SablierV2CliffUnitTest } from "../SablierV2CliffUnitTest.t.sol";

contract SablierV2Cliff__UnitTest__CancelAll is SablierV2CliffUnitTest {
    uint256 internal streamId;
    uint256 internal streamId_2;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default stream, since most tests need it.
        streamId = createDefaultStream();
        // Create a second default stream.
        streamId_2 = createDefaultStream();
    }

    /// @dev When the streamIds array length is zero, it should revert.
    function testCannotCancelAll__StreamIdsArrayEmpty() external {
        uint256[] memory streamIds;
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamIdsArrayEmpty.selector));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only non existing streams, it should revert.
    function testCannotCancelAll__StreamNonExistent__AllStreams() external {
        uint256 nonStreamId = 1729;
        uint256 nonStreamId_2 = 1730;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, nonStreamId_2);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only a single non existing stream on the first position, it should revert.
    function testCannotCancelAll__StreamNonExistent__FirstStream() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, streamId);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only a single non existing stream on the last position, it should revert.
    function testCannotCancelAll__StreamNonExistent__LastStream() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(streamId, nonStreamId);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the caller is not authorized for none of the streams, it should revert.
    function testCannotCancel__CallerUnauthorized__AllStreams() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the caller is not authorized for the first stream, it should revert.
    function testCannotCancelAll__CallerUnauthorized__FirstStream() external {
        uint256 streamId_eve = sablierV2Cliff.create(
            stream.sender,
            users.eve,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            stream.cancelable
        );
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_eve);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the stream does not exist, it should revert.
    function testCannotCancelAll__CallerUnauthorized__LastStream() external {
        uint256 streamId_eve = sablierV2Cliff.create(
            stream.sender,
            users.eve,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            stream.cancelable
        );
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId_eve, streamId);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When caller is the recipient of all the streams, it should make the withdrawal.
    function testCannotCancelAll__CallerRecipient__AllStreams() external {
        // Make the recipient the `msg.sender` in this test case.
        changePrank(users.recipient);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only non-cancelable streams, it should revert.
    function testCannotCancelAll__StreamNonCancelable__AllStreams() external {
        // Create the non-cancelable stream.
        bool cancelable = false;
        uint256 nonCancelableStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            cancelable
        );
        uint256 nonCancelableStreamId_2 = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            cancelable
        );

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(nonCancelableStreamId, nonCancelableStreamId_2);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonCancelable.selector, nonCancelableStreamId)
        );
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has a single non-cancelable stream on the first position, it should revert.
    function testCannotCancelAll__StreamNonCancelable__FirstStream() external {
        // Create the non-cancelable stream.
        bool cancelable = false;
        uint256 nonCancelableStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            cancelable
        );

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(nonCancelableStreamId, streamId);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonCancelable.selector, nonCancelableStreamId)
        );
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has a single non-cancelable stream on the last position, it should revert.
    function testCannotCancelAll__StreamNonCancelable__LastStream() external {
        // Create the non-cancelable stream.
        bool cancelable = false;
        uint256 nonCancelableStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stream.stopTime,
            cancelable
        );

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, nonCancelableStreamId);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonCancelable.selector, nonCancelableStreamId)
        );
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only ended streams, it should cancel all the streams.
    function testCancelAll__AllStreamsEnded() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only ended streams, it should delete all the streams.
    function testCancelAll__AllStreamsEnded__DeleteStreams() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);
        ISablierV2Cliff.Stream memory expectedStream;
        ISablierV2Cliff.Stream memory expectedStream_2;
        ISablierV2Cliff.Stream memory deletedStream = sablierV2Cliff.getStream(streamId);
        ISablierV2Cliff.Stream memory deletedStream_2 = sablierV2Cliff.getStream(streamId_2);
        assertEq(deletedStream, expectedStream);
        assertEq(deletedStream_2, expectedStream_2);
    }

    /// @dev When the streamIds array has only ended streams, it should emit multiple Cancel events.
    function testCancelAll__AllStreamsEnded__Events() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256 withdrawAmount = stream.depositAmount;
        uint256 returnAmount = 0;
        vm.expectEmit(true, true, false, true);
        emit Cancel(streamId, stream.recipient, withdrawAmount, returnAmount);
        vm.expectEmit(true, true, false, true);
        emit Cancel(streamId_2, stream.recipient, withdrawAmount, returnAmount);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has only not ended streams, it should cancel all the streams.
    function testCancelAll__AllStreamsOngoing() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Cliff.cancel(streamId);
    }

    /// @dev When the streamIds array has only not ended streams, it should delete all the streams.
    function testCancelAll__AllStreamsOngoing__DeleteStreams() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);

        ISablierV2Cliff.Stream memory expectedStream;
        ISablierV2Cliff.Stream memory deletedStream = sablierV2Cliff.getStream(streamId);
        ISablierV2Cliff.Stream memory expectedStream_2;
        ISablierV2Cliff.Stream memory deletedStream_2 = sablierV2Cliff.getStream(streamId_2);
        assertEq(deletedStream, expectedStream);
        assertEq(deletedStream_2, expectedStream_2);
    }

    /// @dev When the streamIds array has only not ended streams, it should emit multiple Cancel events.
    function testCancelAll__AllStreamsOngoing__Events() external {
        // Warp to the end of the stream.
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = WITHDRAW_AMOUNT;
        uint256 returnAmount = stream.depositAmount - WITHDRAW_AMOUNT;
        vm.expectEmit(true, true, false, true);
        emit Cancel(streamId, stream.recipient, withdrawAmount, returnAmount);
        vm.expectEmit(true, true, false, true);
        emit Cancel(streamId_2, stream.recipient, withdrawAmount, returnAmount);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has ended streams and not ended streams, it should cancel all the streams.
    function testCancelAll__StreamsEnded__StreamsOngoing() external {
        // Create the ended stream.
        uint256 stopTime = stream.startTime + TIME_OFFSET;
        uint256 ongoingStreamId = streamId;
        uint256 endedStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stopTime,
            stream.cancelable
        );

        // Warp to the end of the first stream.
        vm.warp(stopTime);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        sablierV2Cliff.cancelAll(streamIds);
    }

    /// @dev When the streamIds array has ended streams and not ended streams, it should delete all the streams.
    function testCancelAll__StreamsEnded__StreamsOngoing__DeleteStreams() external {
        // Create the ended stream.
        uint256 stopTime = stream.startTime + TIME_OFFSET;
        uint256 ongoingStreamId = streamId;
        uint256 endedStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stopTime,
            stream.cancelable
        );

        // Warp to the end of the first stream.
        vm.warp(stopTime);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(endedStreamId, streamId);
        sablierV2Cliff.cancelAll(streamIds);

        ISablierV2Cliff.Stream memory expectedStream_ended;
        ISablierV2Cliff.Stream memory deletedStream_ended = sablierV2Cliff.getStream(endedStreamId);
        ISablierV2Cliff.Stream memory expectedStream_ongoing;
        ISablierV2Cliff.Stream memory deletedStream_ongoing = sablierV2Cliff.getStream(ongoingStreamId);
        assertEq(deletedStream_ended, expectedStream_ended);
        assertEq(deletedStream_ongoing, expectedStream_ongoing);
    }

    /// @dev When the streamIds array has ended streams and not ended streams, it should emit multiple Cancel events.
    function testCancelAll__StreamsEnded__StreamsOngoing__Events() external {
        // Create the ended stream.
        uint256 stopTime = stream.startTime + TIME_OFFSET;
        uint256 ongoingStreamId = streamId;
        uint256 endedStreamId = sablierV2Cliff.create(
            stream.sender,
            stream.recipient,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.cliffTime,
            stopTime,
            stream.cancelable
        );

        // Warp to the end of the first stream.
        vm.warp(stopTime);

        // Run the test.
        uint256 withdrawAmount_ongoing = WITHDRAW_AMOUNT;
        uint256 returnAmount_ongoing = stream.depositAmount - WITHDRAW_AMOUNT;
        uint256 withdrawAmount_ended = stream.depositAmount;
        uint256 returnAmount_ended = 0;
        vm.expectEmit(true, true, false, true);
        emit Cancel(endedStreamId, stream.recipient, withdrawAmount_ended, returnAmount_ended);
        vm.expectEmit(true, true, false, true);
        emit Cancel(ongoingStreamId, stream.recipient, withdrawAmount_ongoing, returnAmount_ongoing);
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        sablierV2Cliff.cancelAll(streamIds);
    }
}
