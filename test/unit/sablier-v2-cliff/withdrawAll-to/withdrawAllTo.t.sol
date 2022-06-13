// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Cliff } from "@sablier/v2-core/interfaces/ISablierV2Cliff.sol";

import { SablierV2CliffUnitTest } from "../SablierV2CliffUnitTest.t.sol";

contract SablierV2Cliff__UnitTest__WithdrawAllTo is SablierV2CliffUnitTest {
    uint256 internal streamId;
    uint256 internal streamId_2;
    address internal to;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default stream, since most tests need it.
        streamId = createDefaultStream();
        // Create the second default stream.
        streamId_2 = createDefaultStream();
        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);
        // Setting `eve` the address that will receive the withdrawn tokens.
        to = users.eve;
    }

    /// @dev When the to address is zero, it should revert.
    function testCannotWithdrawAllTo__WithdrawZeroAddress() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawZeroAddress.selector));
        address zero = address(0);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        sablierV2Cliff.withdrawAllTo(streamIds, zero, amounts);
    }

    /// @dev When the streamIds array is empty, it should revert.
    function testCannotWithdrawAllTo__StreamIdsArrayEmpty() external {
        uint256[] memory streamIds;
        uint256[] memory amounts;
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamIdsArrayEmpty.selector));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the arrays counts are not equal, it should revert.
    function testCannotWithdrawAllTo__WithdrawAllArraysNotEqual() external {
        uint256[] memory streamIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAllArraysNotEqual.selector,
                streamIds.length,
                amounts.length
            )
        );
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only non existing streams, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__AllStreams() external {
        uint256 nonStreamId = 1729;
        uint256 nonStreamId_2 = 1730;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, nonStreamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has only a single non existing stream at the first position, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__FirstStream() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, streamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has only a single non existing stream at the last position, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__LastStream() external {
        uint256 nonStreamId = 1729;
        vm.warp(stream.startTime + TIME_OFFSET);
        uint256[] memory streamIds = createDynamicArray(streamId, nonStreamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for none of the streams, it should revert.
    function testCannotWithdrawAllTo__Unauthorized__AllStreams() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for the first stream, it should revert.
    function testCannotWithdrawAllTo__Unauthorized__FirstStream() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);
        // Approve the SablierV2Cliff contract to spend $USD from the `eve` account.
        usd.approve(address(sablierV2Cliff), type(uint256).max);
        // Create eve's stream.
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

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_eve);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for the last stream, it should revert.
    function testCannotWithdrawAllTo__Unauthorized__LastStream() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);
        // Approve the SablierV2Linear contract to spend $USD from the `eve` account.
        usd.approve(address(sablierV2Cliff), type(uint256).max);
        // Create eve's stream.
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

        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId_eve, streamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has only zero values, it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountZero__AllStreams() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, streamId));
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(0, 0);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has only a single zero value on the first position, it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountZero__FirstStream() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, streamId));
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(0, WITHDRAW_AMOUNT);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has only a single zero value on the last position, it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountZero__LastStream() external {
        vm.warp(stream.startTime + TIME_OFFSET);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, streamId_2));
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, 0);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has only greater than the withdrawable amount values, it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountGreaterThanWithdrawableAmount__AllStreams() external {
        uint256 withdrawAmountMaxUint256 = type(uint256).max;
        uint256 withdrawableAmount = WITHDRAW_AMOUNT;
        vm.warp(stream.startTime + TIME_OFFSET);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                streamId,
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmountMaxUint256, withdrawAmountMaxUint256);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has a single greater than the withdrawable amount value on the first position,
    /// it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountGreaterThanWithdrawableAmount__FirstStream() external {
        uint256 withdrawAmountMaxUint256 = type(uint256).max;
        uint256 withdrawableAmount = WITHDRAW_AMOUNT;
        vm.warp(stream.startTime + TIME_OFFSET);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                streamId,
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmountMaxUint256, WITHDRAW_AMOUNT);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the amounts array has a single greater than the withdrawable amount value on the last position,
    /// it should revert.
    function testCannotWithdrawAllTo__WithdrawAmountGreaterThanWithdrawableAmount__LastStream() external {
        uint256 withdrawAmountMaxUint256 = type(uint256).max;
        uint256 withdrawableAmount = WITHDRAW_AMOUNT;
        vm.warp(stream.startTime + TIME_OFFSET);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                streamId_2,
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, withdrawAmountMaxUint256);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only ended streams, it should withdraw everything from all the streams.
    function testWithdrawAllTo__AllStreamsEnded() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256 withdrawAmount = stream.depositAmount;
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only ended streams, it should delete all the streams.
    function testWithdrawAllTo__AllStreamsEnded__DeleteStreams() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256 withdrawAmount = stream.depositAmount;
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
        ISablierV2Cliff.Stream memory deletedStream = sablierV2Cliff.getStream(streamId);
        ISablierV2Cliff.Stream memory expectedStream;
        ISablierV2Cliff.Stream memory deletedStream_2 = sablierV2Cliff.getStream(streamId_2);
        ISablierV2Cliff.Stream memory expectedStream_2;
        assertEq(deletedStream, expectedStream);
        assertEq(deletedStream_2, expectedStream_2);
    }

    /// @dev When the streamIds has only ended streams, it should emit multiple Withdraw events.
    function testWithdrawAllTo__AllStreamsEnded__Events() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        uint256 withdrawAmount = stream.depositAmount;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(streamId, to, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(streamId_2, to, withdrawAmount);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only ongoing streams, it should make withdrawals from all the streams.
    function testWithdrawAllTo__AllStreamsOngoing() external {
        // Warp to 100 seconds after the start time (1% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = WITHDRAW_AMOUNT;
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only ongoing streams, it should update the withdrawn amount to all the streams.
    function testWithdrawAllTo__AllStreamsOngoing__UpdateWithdrawnAmounts() external {
        // Warp to 100 seconds after the start time (1% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
        ISablierV2Cliff.Stream memory queriedStream = sablierV2Cliff.getStream(streamId);
        ISablierV2Cliff.Stream memory queriedStream_2 = sablierV2Cliff.getStream(streamId_2);
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 actualWithdrawnAmount_2 = queriedStream_2.withdrawnAmount;
        uint256 expectedWithdrawnAmount = stream.withdrawnAmount + WITHDRAW_AMOUNT;
        uint256 expectedWithdrawnAmount_2 = stream.withdrawnAmount + WITHDRAW_AMOUNT;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
        assertEq(actualWithdrawnAmount_2, expectedWithdrawnAmount_2);
    }

    /// @dev When the stream is ongoing, it should emit multiple Withdraw events.
    function testWithdrawAllTo__AllStreamsOngoing__Events() external {
        // Warp to 100 seconds after the start time (1% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = WITHDRAW_AMOUNT;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(streamId, to, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(streamId_2, to, withdrawAmount);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has ended streams and not ended streams,
    /// it should withdraw everything from the ended streams,
    /// it should make withdrawals from the not ended streams.
    function testWithdrawAllTo__StreamsEnded__StreamsOngoing() external {
        // Approve the SablierV2Cliff contract to spend $USD from the `recipient` account.
        usd.approve(address(sablierV2Cliff), type(uint256).max);
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
        uint256 withdrawAmount_ended = stream.depositAmount;
        uint256 withdrawAmount_ongoing = WITHDRAW_AMOUNT;
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(withdrawAmount_ended, withdrawAmount_ongoing);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has ended streams and not ended streams,
    /// it should delete all the ended streams,
    /// it should update the withdrawn amount to the not ended streams.
    function testWithdrawAllTo__StreamsEnded__StreamsOngoing__DeleteStreams() external {
        // Approve the SablierV2Cliff contract to spend $USD from the `recipient` account.
        usd.approve(address(sablierV2Cliff), type(uint256).max);
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
        uint256 withdrawAmount_ended = stream.depositAmount;
        uint256 withdrawAmount_ongoing = WITHDRAW_AMOUNT;
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(withdrawAmount_ended, withdrawAmount_ongoing);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
        ISablierV2Cliff.Stream memory deletedStream = sablierV2Cliff.getStream(endedStreamId);
        ISablierV2Cliff.Stream memory queriedStream = sablierV2Cliff.getStream(ongoingStreamId);
        ISablierV2Cliff.Stream memory expectedStream;
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = stream.withdrawnAmount + WITHDRAW_AMOUNT;
        assertEq(deletedStream, expectedStream);
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
    }

    /// @dev When the streamIds array has ended streams and not ended streams, it should emit Withdraw events.
    function testWithdrawAllTo__StreamsEnded__StreamsOngoing__Events() external {
        // Approve the SablierV2Cliff contract to spend $USD from the `recipient` account.
        usd.approve(address(sablierV2Cliff), type(uint256).max);
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
        uint256 withdrawAmount_ended = stream.depositAmount;
        uint256 withdrawAmount_ongoing = WITHDRAW_AMOUNT;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(endedStreamId, to, withdrawAmount_ended);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(ongoingStreamId, to, withdrawAmount_ongoing);
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(withdrawAmount_ended, withdrawAmount_ongoing);
        sablierV2Cliff.withdrawAllTo(streamIds, to, amounts);
    }
}
