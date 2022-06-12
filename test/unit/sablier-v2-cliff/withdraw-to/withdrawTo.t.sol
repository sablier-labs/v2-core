// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Cliff } from "@sablier/v2-core/interfaces/ISablierV2Cliff.sol";

import { SablierV2CliffUnitTest } from "../SablierV2CliffUnitTest.t.sol";

contract SablierV2Cliff__WithdrawTo__UnitTest is SablierV2CliffUnitTest {
    uint256 internal streamId;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default stream, since most tests need it.
        streamId = createDefaultStream();

        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);
    }

    /// @dev When the stream does not exist, it should revert.
    function testCannotWithdrawTo__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__StreamNonExistent.selector, nonStreamId));
        address to = users.alice;
        uint256 withdrawAmount = 0;
        sablierV2Cliff.withdrawTo(nonStreamId, to, withdrawAmount);
    }

    /// @dev When the to address is zero, it should revert.
    function testCannotWithdrawTo__ZeroAddress() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawZeroAddress.selector));
        address to = address(0);
        uint256 withdrawAmount = 0;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the caller is the sender, it should revert.
    function testCannotWithdrawTo__CallerSender() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.sender);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.sender));
        address to = users.alice;
        uint256 withdrawAmount = 0;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the caller is an unauthorized third-party, it should revert.
    function testCannotWithdrawTo__CallerUnauthorized() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, streamId, users.eve));
        address to = users.alice;
        uint256 withdrawAmount = 0;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the withdraw amount is zero, it should revert.
    function testCannotWithdrawTo__WithdrawAmountZero() external {
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, streamId));
        address to = users.alice;
        uint256 withdrawAmount = 0;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the amount is greater than the withdrawable amount, it should revert.
    function testCannotWithdrawTo__WithdrawAmountGreaterThanWithdrawableAmount() external {
        uint256 withdrawAmount = type(uint256).max;
        uint256 withdrawableAmount = 0;
        address to = users.alice;
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                streamId,
                withdrawAmount,
                withdrawableAmount
            )
        );
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the to address is the recipient, it should make the withdrawal.
    function testWithdrawTo__Recipient() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        address to = stream.recipient;
        sablierV2Cliff.withdrawTo(streamId, to, WITHDRAW_AMOUNT);
    }

    /// @dev When the stream ended, it should withdraw everything.
    function testWithdrawTo__ThirdParty__StreamEnded() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        address to = users.alice;
        uint256 withdrawAmount = stream.depositAmount;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the stream ended, it should delete the stream.
    function testWithdrawTo__ThirdParty__StreamEnded__DeleteStream() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        address to = users.alice;
        uint256 withdrawAmount = stream.depositAmount;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
        ISablierV2Cliff.Stream memory deletedStream = sablierV2Cliff.getStream(streamId);
        ISablierV2Cliff.Stream memory expectedStream;
        assertEq(deletedStream, expectedStream);
    }

    /// @dev When the stream ended, it should emit a Withdraw event.
    function testWithdrawTo__ThirdParty__StreamEnded__Event() external {
        // Warp to the end of the stream.
        vm.warp(stream.stopTime);

        // Run the test.
        vm.expectEmit(true, true, false, true);
        address to = users.alice;
        uint256 withdrawAmount = stream.depositAmount;
        emit Withdraw(streamId, to, withdrawAmount);
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }

    /// @dev When the stream is ongoing, it should make the withdrawal.
    function testWithdrawTo__ThirdParty__StreamOngoing() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        address to = users.alice;
        sablierV2Cliff.withdrawTo(streamId, to, WITHDRAW_AMOUNT);
    }

    /// @dev When the stream is ongoing, it should update the withdrawn amount.
    function testWithdrawTo__ThirdParty__StreamOngoing__UpdateWithdrawnAmount() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        address to = users.alice;
        uint256 withdrawnAmount = WITHDRAW_AMOUNT;
        sablierV2Cliff.withdrawTo(streamId, to, withdrawnAmount);
        ISablierV2Cliff.Stream memory queriedStream = sablierV2Cliff.getStream(streamId);
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = stream.withdrawnAmount + withdrawnAmount;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
    }

    /// @dev When the stream is ongoing, it should emit a Withdraw event.
    function testWithdrawTo__ThirdParty__StreamOngoing__Event() external {
        // Warp to 2_600 seconds after the start time (26% of the default stream duration).
        vm.warp(stream.startTime + TIME_OFFSET);

        // Run the test.
        address to = users.alice;
        uint256 withdrawAmount = WITHDRAW_AMOUNT;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(streamId, to, withdrawAmount);
        sablierV2Cliff.withdrawTo(streamId, to, withdrawAmount);
    }
}
