// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Linear } from "@sablier/v2-core/interfaces/ISablierV2Linear.sol";

import { SablierV2LinearUnitTest } from "../SablierV2LinearUnitTest.t.sol";

contract SablierV2Linear__WithdrawAllTo__UnitTest is SablierV2LinearUnitTest {
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

        to = users.eve;
    }

    /// @dev When the to address is zero, it should revert.
    function testCannotWithdrawAllTo__WithdrawZeroAddress() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawZeroAddress.selector));
        address zero = address(0);
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        sablierV2Linear.withdrawAllTo(streamIds, zero, amounts);
    }

    /// @dev When the streamIds array is empty, it should revert.
    function testCannotWithdrawAllTo__StreamIdsArrayEmpty() external {
        uint256[] memory streamIds;
        uint256[] memory amounts;
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamIdsArrayEmpty.selector));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
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
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds has only non existing streams, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__AllStreams() external {
        uint256 nonStreamId = 1729;
        uint256 nonStreamId_2 = 1730;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, nonStreamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has only a single non existing stream at the first position, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__SingleStream__FirstPosition() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, streamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the streamIds array has only a single non existing stream at the last position, it should revert.
    function testCannotWithdrawAllTo__StreamNonExistent__SingleStream__LastPosition() external {
        uint256 nonStreamId = 1729;
        vm.warp(stream.startTime + TIME_OFFSET);
        uint256[] memory streamIds = createDynamicArray(streamId, nonStreamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for none of the streams, it should revert.
    function testCannotWithdrawAllTos__Unauthorized__AllStreams() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for the first stream, it should revert.
    function testCannotWithdrawAllTo__Unauthorized__SingleStream__FirtStream() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);
        // Give allowance for the tokens to be spent by the contract.
        usd.approve(address(sablierV2Linear), type(uint256).max);
        // Create eve's stream.
        uint256 streamId_eve = sablierV2Linear.create(
            stream.sender,
            users.eve,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.stopTime,
            stream.cancelable
        );

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_eve);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev When the caller is not authorized for the last stream, it should revert.
    function testCannotWithdrawAllTo__Unauthorized__SingleStream__LastStream() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);
        // Give allowance for the tokens to be spent by the contract.
        usd.approve(address(sablierV2Linear), type(uint256).max);
        // Create eve's stream.
        uint256 streamId_eve = sablierV2Linear.create(
            stream.sender,
            users.eve,
            stream.depositAmount,
            stream.token,
            stream.startTime,
            stream.stopTime,
            stream.cancelable
        );

        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId_eve, streamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);
    }

    /// @dev

    /// @dev When the caller of all the stream is the recipient, it should make multiple withdrawals.
    function testWithdrawAllTo() external {
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(streamId, streamId_2);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT, WITHDRAW_AMOUNT);
        sablierV2Linear.withdrawAllTo(streamIds, to, amounts);

        ISablierV2Linear.Stream memory queriedStream = sablierV2Linear.getStream(streamId);
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = stream.withdrawnAmount + WITHDRAW_AMOUNT;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);

        ISablierV2Linear.Stream memory queriedStream_2 = sablierV2Linear.getStream(streamId_2);
        uint256 actualWithdrawnAmount_2 = queriedStream_2.withdrawnAmount;
        uint256 expectedWithdrawnAmount_2 = stream.withdrawnAmount + WITHDRAW_AMOUNT;
        assertEq(actualWithdrawnAmount_2, expectedWithdrawnAmount_2);
    }
}
