// solhint-disable max-line-length
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Pro } from "@sablier/v2-core/interfaces/ISablierV2Pro.sol";

import { SablierV2ProUnitTest } from "../SablierV2ProUnitTest.t.sol";

contract SablierV2Pro__Unit__Withdraw is SablierV2ProUnitTest {
    uint256 internal daiStreamId;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default stream, since most tests need it.
        daiStreamId = createDefaultDaiStream();

        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);
    }

    /// @dev it should revert.
    function testCannotWithdraw__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        uint256 withdrawAmount = 0;
        sablierV2Pro.withdraw(nonStreamId, withdrawAmount);
    }

    modifier StreamExistent() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdraw__CallerUnauthorized() external StreamExistent {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, daiStreamId, users.eve));
        uint256 withdrawAmount = 0;
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
    }

    modifier CallerSender() {
        _;
    }

    /// @dev it should make the withdrawal.
    function testWithdraw() external StreamExistent CallerSender {
        // Make the sender the `msg.sender` in this test case.
        changePrank(users.sender);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);
        uint256 withdrawAmount = SEGMENT_AMOUNTS_DAI[0];

        // Run the test.
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
    }

    modifier CallerRecipient() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdraw__WithdrawAmountZero() external StreamExistent CallerRecipient {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, daiStreamId));
        uint256 withdrawAmount = 0;
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
    }

    modifier WithdrawAmountNotZero() {
        _;
    }

    /// @dev it should revert.
    function testCannotWithdraw__WithdrawAmountGreaterThanWithdrawableAmount() external {
        uint256 withdrawAmountMaxUint256 = UINT256_MAX;
        uint256 withdrawableAmount = 0;
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                daiStreamId,
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        sablierV2Pro.withdraw(daiStreamId, withdrawAmountMaxUint256);
    }

    modifier WithdrawAmountLessThanOrEqualToWithdrawableAmount() {
        _;
    }

    /// @dev it should cancel and delete the stream.
    function testWithdraw__StreamEnded()
        external
        StreamExistent
        CallerRecipient
        WithdrawAmountNotZero
        WithdrawAmountLessThanOrEqualToWithdrawableAmount
    {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256 withdrawAmount = daiStream.depositAmount;
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
        ISablierV2Pro.Stream memory deletedStream = sablierV2Pro.getStream(daiStreamId);
        ISablierV2Pro.Stream memory expectedStream;
        assertEq(deletedStream, expectedStream);
    }

    /// @dev it should emit a Withdraw event.
    function testWithdraw__StreamEnded__Event()
        external
        StreamExistent
        CallerRecipient
        WithdrawAmountNotZero
        WithdrawAmountLessThanOrEqualToWithdrawableAmount
    {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        vm.expectEmit(true, true, false, true);
        uint256 withdrawAmount = daiStream.depositAmount;
        emit Withdraw(daiStreamId, daiStream.recipient, withdrawAmount);
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
    }

    /// @dev it should make the withdrawal and update the withdrawn amount.
    function testWithdraw__StreamOngoing()
        external
        StreamExistent
        CallerRecipient
        WithdrawAmountNotZero
        WithdrawAmountLessThanOrEqualToWithdrawableAmount
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Pro.withdraw(daiStreamId, SEGMENT_AMOUNTS_DAI[0]);
        ISablierV2Pro.Stream memory actualStream = sablierV2Pro.getStream(daiStreamId);
        uint256 actualWithdrawnAmount = actualStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = SEGMENT_AMOUNTS_DAI[0];
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
    }

    /// @dev it should emit a Withdraw event.
    function testWithdraw__StreamOngoing__Event()
        external
        StreamExistent
        CallerRecipient
        WithdrawAmountNotZero
        WithdrawAmountLessThanOrEqualToWithdrawableAmount
    {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = SEGMENT_AMOUNTS_DAI[0];
        vm.expectEmit(true, true, false, true);
        emit Withdraw(daiStreamId, daiStream.recipient, withdrawAmount);
        sablierV2Pro.withdraw(daiStreamId, withdrawAmount);
    }
}
