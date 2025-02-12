// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Solarray } from "solarray/src/Solarray.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract Batch_Integration_Concrete_Test is Integration_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    BATCH + LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The batch call cancels a non-cancelable stream.
    function test_RevertWhen_LockupThrows() external {
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeCall(lockup.cancel, (streamIds.defaultStream));
        calls[1] = abi.encodeCall(lockup.cancel, (streamIds.notCancelableStream));

        // Expect revert on streamIds.notCancelableStream.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamNotCancelable.selector, streamIds.notCancelableStream)
        );
        lockup.batch(calls);
    }

    /// @dev The batch call includes:
    /// - Returning state changing functions
    /// - Non-returning state changing functions
    /// - View only functions
    function test_Batch_StateChangingAndViewFunctions() external {
        uint256 expectedNextStreamId = lockup.nextStreamId();
        vm.warp(defaults.WARP_26_PERCENT());

        bytes[] memory calls = new bytes[](6);
        // It should return True.
        calls[0] = abi.encodeCall(lockup.isCancelable, (streamIds.defaultStream));
        // It should return the withdrawn amount.
        calls[1] = abi.encodeCall(lockup.withdrawMax, (streamIds.notCancelableStream, users.recipient));
        // It should return refunded amount.
        calls[2] = abi.encodeCall(lockup.cancel, (streamIds.defaultStream));
        // It should return the next stream ID.
        calls[3] = abi.encodeCall(lockup.nextStreamId, ());
        // It should return the stream ID created.
        calls[4] = abi.encodeCall(
            lockup.createWithTimestampsLL,
            (defaults.createWithTimestamps(), defaults.unlockAmounts(), defaults.CLIFF_TIME())
        );
        // It should return nothing.
        calls[5] = abi.encodeCall(lockup.renounce, (streamIds.notTransferableStream));

        bytes[] memory results = lockup.batch(calls);
        assertEq(results.length, 6, "batch results length");
        assertTrue(abi.decode(results[0], (bool)), "batch results[0]");
        assertEq(abi.decode(results[1], (uint128)), defaults.WITHDRAW_AMOUNT(), "batch results[1]");
        assertEq(
            abi.decode(results[2], (uint128)),
            defaults.DEPOSIT_AMOUNT() - defaults.WITHDRAW_AMOUNT(),
            "batch results[2]"
        );
        assertEq(abi.decode(results[3], (uint256)), expectedNextStreamId, "batch results[3]");
        assertEq(abi.decode(results[4], (uint256)), expectedNextStreamId, "batch results[4]");
        assertEq(results[5], "", "batch results[5]");
    }

    /// @dev The batch call includes:
    /// - ETH value
    /// - All create stream functions that return a value
    function test_BatchPayable_CreateStreams() external {
        uint256 expectedNextStreamId = lockup.nextStreamId();
        uint256 initialEthBalance = address(lockup).balance;

        bytes[] memory calls = new bytes[](6);
        calls[0] = abi.encodeCall(
            lockup.createWithDurationsLD, (defaults.createWithDurations(), defaults.segmentsWithDurations())
        );
        calls[1] = abi.encodeCall(
            lockup.createWithDurationsLL,
            (defaults.createWithDurations(), defaults.unlockAmounts(), defaults.durations())
        );
        calls[2] = abi.encodeCall(
            lockup.createWithDurationsLT, (defaults.createWithDurations(), defaults.tranchesWithDurations())
        );
        calls[3] = abi.encodeCall(lockup.createWithTimestampsLD, (defaults.createWithTimestamps(), defaults.segments()));
        calls[4] = abi.encodeCall(
            lockup.createWithTimestampsLL,
            (defaults.createWithTimestamps(), defaults.unlockAmounts(), defaults.CLIFF_TIME())
        );
        calls[5] = abi.encodeCall(lockup.createWithTimestampsLT, (defaults.createWithTimestamps(), defaults.tranches()));

        // It should return the stream IDs created.
        bytes[] memory results = lockup.batch{ value: 1 wei }(calls);
        assertEq(results.length, 6, "batch results length");
        assertEq(abi.decode(results[0], (uint256)), expectedNextStreamId, "batch results[0]");
        assertEq(abi.decode(results[1], (uint256)), expectedNextStreamId + 1, "batch results[1]");
        assertEq(abi.decode(results[2], (uint256)), expectedNextStreamId + 2, "batch results[2]");
        assertEq(abi.decode(results[3], (uint256)), expectedNextStreamId + 3, "batch results[3]");
        assertEq(abi.decode(results[4], (uint256)), expectedNextStreamId + 4, "batch results[4]");
        assertEq(abi.decode(results[5], (uint256)), expectedNextStreamId + 5, "batch results[5]");
        assertEq(address(lockup).balance, initialEthBalance + 1 wei, "lockup contract balance");
    }

    /// @dev The batch call includes:
    /// - ETH value
    /// - All recipient related functions with both returns and non-returns
    function test_BatchPayable_RecipientFunctions() external {
        uint256 initialEthBalance = address(lockup).balance;
        vm.warp(defaults.WARP_26_PERCENT());

        bytes[] memory calls = new bytes[](4);

        // It should return the refunded amount.
        calls[0] = abi.encodeCall(lockup.cancel, (streamIds.defaultStream));

        uint256[] memory ids = new uint256[](2);
        ids[0] = streamIds.recipientGoodStream;
        ids[1] = streamIds.notTransferableStream;
        // It should return the array of refunded amounts.
        calls[1] = abi.encodeCall(lockup.cancelMultiple, (ids));

        // It should return nothing.
        calls[2] = abi.encodeCall(lockup.renounce, (streamIds.recipientReentrantStream));

        ids = new uint256[](1);
        ids[0] = streamIds.recipientRevertStream;
        // It should return nothing.
        calls[3] = abi.encodeCall(lockup.renounceMultiple, (ids));

        bytes[] memory results = lockup.batch{ value: 1 wei }(calls);

        uint128 expectedRefundedAmount = defaults.REFUND_AMOUNT();
        assertEq(results.length, 4, "batch results length");
        assertEq(abi.decode(results[0], (uint128)), expectedRefundedAmount, "batch results[0]");
        uint128[] memory refundedAmounts = abi.decode(results[1], (uint128[]));
        assertEq(refundedAmounts[0], expectedRefundedAmount, "batch results[1][0]");
        assertEq(refundedAmounts[1], expectedRefundedAmount, "batch results[1][1]");
        assertEq(results[2], "", "batch results[2]");
        assertEq(results[3], "", "batch results[3]");
        assertEq(address(lockup).balance, initialEthBalance + 1 wei, "lockup contract balance");
    }

    /// @dev The batch call includes:
    /// - ETH value
    /// - All sender related functions with both returns and non-returns
    function test_BatchPayable_SenderFunctions() external {
        uint256 initialEthBalance = address(lockup).balance;
        // Warp to the end time so that `burn` can be added to the call list.
        vm.warp(defaults.END_TIME());

        bytes[] memory calls = new bytes[](5);
        // It should return nothing.
        calls[0] = abi.encodeCall(lockup.withdraw, (streamIds.defaultStream, users.recipient, 1));
        // It should return the withdrawn amount.
        calls[1] = abi.encodeCall(lockup.withdrawMax, (streamIds.defaultStream, users.recipient));

        uint256[] memory ids = Solarray.uint256s(streamIds.notCancelableStream, streamIds.notCancelableStream);
        uint128[] memory amounts = Solarray.uint128s(1, 1);

        // It should return nothing.
        calls[2] = abi.encodeCall(lockup.withdrawMultiple, (ids, amounts));
        // It should return the withdrawn amount.
        calls[3] = abi.encodeCall(lockup.withdrawMaxAndTransfer, (streamIds.notCancelableStream, users.recipient));
        // It should return nothing.
        calls[4] = abi.encodeCall(lockup.burn, (streamIds.defaultStream));

        resetPrank({ msgSender: users.recipient });
        bytes[] memory results = lockup.batch{ value: 1 wei }(calls);

        assertEq(results.length, 5, "batch results length");
        assertEq(results[0], "", "batch results[0]");
        assertEq(abi.decode(results[1], (uint128)), defaults.DEPOSIT_AMOUNT() - 1, "batch results[1]");
        assertEq(results[2], "", "batch results[2]");
        assertEq(abi.decode(results[3], (uint128)), defaults.DEPOSIT_AMOUNT() - 2, "batch results[3]");
        assertEq(results[4], "", "batch results[4]");
        assertEq(address(lockup).balance, initialEthBalance + 1 wei, "lockup contract balance");
    }
}
