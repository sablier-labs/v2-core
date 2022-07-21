// solhint-disable max-line-length
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Pro } from "@sablier/v2-core/interfaces/ISablierV2Pro.sol";

import { SablierV2ProUnitTest } from "../SablierV2ProUnitTest.t.sol";

contract SablierV2Pro__CancelAll is SablierV2ProUnitTest {
    uint256[] internal defaultStreamIds;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default streams, since most tests need them.
        defaultStreamIds.push(createDefaultDaiStream());
        defaultStreamIds.push(createDefaultDaiStream());
    }

    /// @dev it should do nothing.
    function testCannotCancelAll__OnlyNonExistentStreams() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId);
        sablierV2Pro.cancelAll(streamIds);
    }

    /// @dev it should cancel and delete the non existent streams.
    function testCannotCancelAll__SomeNonExistentStreams() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(defaultStreamIds[0], nonStreamId);
        sablierV2Pro.cancelAll(streamIds);
        ISablierV2Pro.Stream memory actualStream = sablierV2Pro.getStream(defaultStreamIds[0]);
        ISablierV2Pro.Stream memory expectedStream;
        assertEq(actualStream, expectedStream);
    }

    modifier OnlyExistentStreams() {
        _;
    }

    /// @dev it should revert.
    function testCannotCancelAll__CallerUnauthorizedAllStreams() external OnlyExistentStreams {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.eve)
        );
        sablierV2Pro.cancelAll(defaultStreamIds);
    }

    /// @dev it should revert.
    function testCannotCancelAll__CallerUnauthorizedSomeStreams() external OnlyExistentStreams {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Create a stream with Eve as the sender.
        uint256 eveStreamId = sablierV2Pro.create(
            users.eve,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            daiStream.segmentMilestones,
            daiStream.cancelable
        );

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(eveStreamId, defaultStreamIds[0]);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.eve)
        );
        sablierV2Pro.cancelAll(streamIds);
    }

    /// @dev it should cancel and delete the streams.
    function testCancelAll__CallerRecipientAllStreams() external OnlyExistentStreams {
        // Make the recipient the `msg.sender` in this test case.
        changePrank(users.recipient);

        // Run the test.
        sablierV2Pro.cancelAll(defaultStreamIds);

        ISablierV2Pro.Stream memory actualStream0 = sablierV2Pro.getStream(defaultStreamIds[0]);
        ISablierV2Pro.Stream memory actualStream1 = sablierV2Pro.getStream(defaultStreamIds[1]);
        ISablierV2Pro.Stream memory expectedStream;

        assertEq(actualStream0, expectedStream);
        assertEq(actualStream1, expectedStream);
    }

    modifier CallerSenderAllStreams() {
        _;
    }

    /// @dev it should do nothing.
    function testCannotCancelAll__AllStreamsNonCancelable() external OnlyExistentStreams CallerSenderAllStreams {
        // Create the non-cancelable stream.
        uint256 nonCancelableDaiStreamId = createNonCancelableDaiStream();

        // Run the test.
        uint256[] memory nonCancelableStreamIds = createDynamicArray(nonCancelableDaiStreamId);
        sablierV2Pro.cancelAll(nonCancelableStreamIds);
    }

    /// @dev it should cancel and delete the cancelable streams.
    function testCannotCancelAll__SomeStreamsNonCancelable() external OnlyExistentStreams CallerSenderAllStreams {
        // Create the non-cancelable stream.
        uint256 nonCancelableDaiStreamId = createNonCancelableDaiStream();

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(defaultStreamIds[0], nonCancelableDaiStreamId);
        sablierV2Pro.cancelAll(streamIds);
        ISablierV2Pro.Stream memory actualStream = sablierV2Pro.getStream(defaultStreamIds[0]);
        ISablierV2Pro.Stream memory expectedStream;
        assertEq(actualStream, expectedStream);
    }

    modifier AllStreamsCancelable() {
        _;
    }

    /// @dev it should cancel and delete the streams.
    function testCancelAll__AllStreamsEnded() external OnlyExistentStreams CallerSenderAllStreams AllStreamsCancelable {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        sablierV2Pro.cancelAll(defaultStreamIds);

        ISablierV2Pro.Stream memory actualStream0 = sablierV2Pro.getStream(defaultStreamIds[0]);
        ISablierV2Pro.Stream memory actualStream1 = sablierV2Pro.getStream(defaultStreamIds[1]);
        ISablierV2Pro.Stream memory expectedStream;

        assertEq(actualStream0, expectedStream);
        assertEq(actualStream1, expectedStream);
    }

    /// @dev it should emit multiple Cancel events.
    function testCancelAll__AllStreamsEnded__Events()
        external
        OnlyExistentStreams
        CallerSenderAllStreams
        AllStreamsCancelable
    {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256 withdrawAmount = daiStream.depositAmount;
        uint256 returnAmount = 0;

        vm.expectEmit(true, true, false, true);
        emit Cancel(defaultStreamIds[0], daiStream.recipient, withdrawAmount, returnAmount);
        vm.expectEmit(true, true, false, true);
        emit Cancel(defaultStreamIds[1], daiStream.recipient, withdrawAmount, returnAmount);

        uint256[] memory streamIds = createDynamicArray(defaultStreamIds[0], defaultStreamIds[1]);
        sablierV2Pro.cancelAll(streamIds);
    }

    /// @dev it should cancel and delete the streams.
    function testCancelAll__AllStreamsOngoing()
        external
        OnlyExistentStreams
        CallerSenderAllStreams
        AllStreamsCancelable
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Pro.cancelAll(defaultStreamIds);

        ISablierV2Pro.Stream memory actualStream0 = sablierV2Pro.getStream(defaultStreamIds[0]);
        ISablierV2Pro.Stream memory actualStream1 = sablierV2Pro.getStream(defaultStreamIds[1]);
        ISablierV2Pro.Stream memory expectedStream;

        assertEq(actualStream0, expectedStream);
        assertEq(actualStream1, expectedStream);
    }

    /// @dev it should emit multiple Cancel events.
    function testCancelAll__AllStreamsOngoing__Events()
        external
        OnlyExistentStreams
        CallerSenderAllStreams
        AllStreamsCancelable
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = SEGMENT_AMOUNTS_DAI[0];
        uint256 returnAmount = daiStream.depositAmount - SEGMENT_AMOUNTS_DAI[0];

        vm.expectEmit(true, true, false, true);
        emit Cancel(defaultStreamIds[0], daiStream.recipient, withdrawAmount, returnAmount);
        vm.expectEmit(true, true, false, true);
        emit Cancel(defaultStreamIds[1], daiStream.recipient, withdrawAmount, returnAmount);

        sablierV2Pro.cancelAll(defaultStreamIds);
    }

    /// @dev it should cancel and delete the streams.
    function testCancelAll__SomeStreamsEndedSomeStreamsOngoing()
        external
        OnlyExistentStreams
        CallerSenderAllStreams
        AllStreamsCancelable
    {
        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Create the ended dai stream.
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256[] memory segmentMilestones = createDynamicArray(daiStream.startTime, earlyStopTime);
        uint256 endedDaiStreamId = sablierV2Pro.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            segmentMilestones,
            daiStream.cancelable
        );

        // Warp to the end of the first daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(ongoingStreamId, endedDaiStreamId);
        sablierV2Pro.cancelAll(streamIds);

        ISablierV2Pro.Stream memory deletedOngoingStream = sablierV2Pro.getStream(ongoingStreamId);
        ISablierV2Pro.Stream memory deletedEndedStream = sablierV2Pro.getStream(endedDaiStreamId);
        ISablierV2Pro.Stream memory expectedStream;

        assertEq(deletedOngoingStream, expectedStream);
        assertEq(deletedEndedStream, expectedStream);
    }

    /// @dev it should emit multiple Cancel events.
    function testCancelAll__SomeStreamsEndedSomeStreamsOngoing__Events()
        external
        OnlyExistentStreams
        CallerSenderAllStreams
        AllStreamsCancelable
    {
        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Create the ended dai stream.
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256[] memory segmentMilestones = createDynamicArray(daiStream.startTime, earlyStopTime);
        uint256 endedDaiStreamId = sablierV2Pro.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.segmentAmounts,
            daiStream.segmentExponents,
            segmentMilestones,
            daiStream.cancelable
        );

        // Warp to the end of the first daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256 endedWithdrawAmount = daiStream.depositAmount;
        uint256 endedReturnAmount = 0;
        uint256 ongoingWithdrawAmount = SEGMENT_AMOUNTS_DAI[0];
        uint256 ongoingReturnAmount = daiStream.depositAmount - SEGMENT_AMOUNTS_DAI[0];

        vm.expectEmit(true, true, false, true);
        emit Cancel(endedDaiStreamId, daiStream.recipient, endedWithdrawAmount, endedReturnAmount);
        vm.expectEmit(true, true, false, true);
        emit Cancel(ongoingStreamId, daiStream.recipient, ongoingWithdrawAmount, ongoingReturnAmount);

        uint256[] memory streamIds = createDynamicArray(endedDaiStreamId, ongoingStreamId);
        sablierV2Pro.cancelAll(streamIds);
    }
}
