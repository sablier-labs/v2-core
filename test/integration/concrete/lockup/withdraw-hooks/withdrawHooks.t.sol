// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierV2Recipient } from "src/interfaces/ISablierV2Recipient.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Withdraw_Integration_Shared_Test } from "../../../shared/lockup/withdraw.t.sol";

abstract contract WithdrawHooks_Integration_Concrete_Test is Integration_Test, Withdraw_Integration_Shared_Test {
    uint128 internal withdrawAmount;

    function setUp() public virtual override(Integration_Test, Withdraw_Integration_Shared_Test) {
        Withdraw_Integration_Shared_Test.setUp();
        withdrawAmount = defaults.WITHDRAW_AMOUNT();
    }

    modifier givenDifferentSenderAndRecipient() {
        _;
    }

    function test_WithdrawHooks_CallerUnknown1() external givenDifferentSenderAndRecipient {
        address unknownCaller = address(0xCAFE);

        // Create the test stream.
        uint256 streamId = createDefaultStreamWithUsers({ recipient: address(goodRecipient), sender: users.sender });

        // Make the unknown address the caller in this test.
        resetPrank({ msgSender: unknownCaller });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Expect a call to the recipient hook.
        vm.expectCall({
            callee: address(goodRecipient),
            data: abi.encodeCall(
                ISablierV2Recipient.onSablierLockupWithdraw,
                (streamId, unknownCaller, address(goodRecipient), withdrawAmount)
            ),
            count: 1
        });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: address(goodRecipient), amount: withdrawAmount });
    }

    function test_WithdrawHooks_CallerApprovedOperator1() external givenDifferentSenderAndRecipient {
        // Create the test stream.
        uint256 streamId = createDefaultStreamWithUsers({ recipient: address(goodRecipient), sender: users.sender });

        // Approve the operator to handle the stream.
        resetPrank({ msgSender: address(goodRecipient) });
        lockup.approve({ to: users.operator, tokenId: streamId });

        // Make the operator the caller in this test.
        resetPrank({ msgSender: users.operator });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Expect a call to the recipient hook.
        vm.expectCall({
            callee: address(goodRecipient),
            data: abi.encodeCall(
                ISablierV2Recipient.onSablierLockupWithdraw,
                (streamId, users.operator, address(goodRecipient), withdrawAmount)
            ),
            count: 1
        });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: address(goodRecipient), amount: withdrawAmount });
    }

    function test_WithdrawHooks_CallerSender1() external givenDifferentSenderAndRecipient {
        // Create the test stream.
        uint256 streamId = createDefaultStreamWithUsers({ recipient: address(goodRecipient), sender: users.sender });

        // Make the Sender the caller in this test.
        resetPrank({ msgSender: users.sender });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Expect 1 call to the recipient hook.
        vm.expectCall({
            callee: address(goodRecipient),
            data: abi.encodeCall(
                ISablierV2Recipient.onSablierLockupWithdraw,
                (streamId, users.sender, address(goodRecipient), withdrawAmount)
            ),
            count: 1
        });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: address(goodRecipient), amount: withdrawAmount });
    }

    function test_WithdrawHooks_CallerRecipient() external givenDifferentSenderAndRecipient {
        // Create the test stream.
        uint256 streamId = createDefaultStreamWithUsers({ recipient: address(goodRecipient), sender: users.sender });

        // Make the recipient contract the caller in this test.
        resetPrank({ msgSender: address(goodRecipient) });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Expect no calls to the recipient hook.
        vm.expectCall({
            callee: address(goodRecipient),
            data: abi.encodeCall(
                ISablierV2Recipient.onSablierLockupWithdraw,
                (streamId, address(goodRecipient), address(goodRecipient), withdrawAmount)
            ),
            count: 0
        });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: address(goodRecipient), amount: withdrawAmount });
    }

    modifier givenSameSenderAndRecipient() {
        _;
    }

    function test_WithdrawHooks_CallerUnknown2() external givenSameSenderAndRecipient {
        address unknownCaller = address(0xCAFE);

        // Create a stream with identical sender and recipient.
        uint256 streamId = createDefaultStreamWithIdenticalUsers(users.sender);

        // Make unknownCaller the caller in this test.
        resetPrank({ msgSender: unknownCaller });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: users.sender, amount: withdrawAmount });
    }

    function test_WithdrawHooks_CallerApprovedOperator2() external givenSameSenderAndRecipient {
        // Create a stream with identical sender and recipient.
        uint256 streamId = createDefaultStreamWithIdenticalUsers(users.sender);

        // Approve the operator to handle the stream.
        resetPrank({ msgSender: users.sender });
        lockup.approve({ to: users.operator, tokenId: streamId });

        // Make the operator the caller in this test.
        resetPrank({ msgSender: users.operator });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: users.sender, amount: withdrawAmount });
    }

    function test_WithdrawHooks_CallerUser() external givenSameSenderAndRecipient {
        // Create a stream with identical sender and recipient.
        uint256 streamId = createDefaultStreamWithIdenticalUsers(users.sender);

        // Make the Sender the caller.
        resetPrank({ msgSender: users.sender });

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamId, to: users.sender, amount: withdrawAmount });
    }
}
