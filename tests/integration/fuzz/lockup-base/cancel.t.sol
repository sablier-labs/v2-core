// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";

import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { ISablierLockupRecipient } from "src/interfaces/ISablierLockupRecipient.sol";
import { Lockup } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../Integration.t.sol";

abstract contract Cancel_Integration_Fuzz_Test is Integration_Test {
    function testFuzz_Cancel_StatusPending(uint256 timeJump)
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
    {
        timeJump = _bound(timeJump, 1 seconds, 100 weeks);

        // Warp to the past.
        vm.warp({ newTimestamp: getBlockTimestamp() - timeJump });

        // Cancel the stream.
        lockup.cancel(streamIds.defaultStream);

        // Assert that the stream's status is "DEPLETED".
        Lockup.Status actualStatus = lockup.statusOf(streamIds.defaultStream);
        Lockup.Status expectedStatus = Lockup.Status.DEPLETED;
        assertEq(actualStatus, expectedStatus);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamIds.defaultStream);
        assertFalse(isCancelable, "isCancelable");
    }

    /// @dev Given enough fuzz runs, all of the following scenarios will be fuzzed:
    ///
    /// - Multiple values for the block timestamp
    /// - With and without withdrawals
    function testFuzz_Cancel(
        uint256 timeJump,
        uint128 withdrawAmount
    )
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
        givenSTREAMINGStatus
        givenRecipientAllowedToHook
        whenNonRevertingRecipient
        whenRecipientReturnsValidSelector
        whenRecipientNotReentrant
    {
        timeJump = _bound(timeJump, defaults.WARP_26_PERCENT_DURATION(), defaults.TOTAL_DURATION() - 1 seconds);

        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.START_TIME() + timeJump });

        // Bound the withdraw amount.
        uint128 streamedAmount = lockup.streamedAmountOf(streamIds.recipientGoodStream);
        withdrawAmount = boundUint128(withdrawAmount, 0, streamedAmount - 1);

        // Make the withdrawal only if the amount is greater than zero.
        if (withdrawAmount > 0) {
            lockup.withdraw({
                streamId: streamIds.recipientGoodStream,
                to: address(recipientGood),
                amount: withdrawAmount
            });
        }

        // Expect the tokens to be refunded to the Sender.
        uint128 senderAmount = lockup.refundableAmountOf(streamIds.recipientGoodStream);
        expectCallToTransfer({ to: users.sender, value: senderAmount });

        // Expect the recipient to be called.
        uint128 recipientAmount = lockup.withdrawableAmountOf(streamIds.recipientGoodStream);
        vm.expectCall(
            address(recipientGood),
            abi.encodeCall(
                ISablierLockupRecipient.onSablierLockupCancel,
                (streamIds.recipientGoodStream, users.sender, senderAmount, recipientAmount)
            )
        );

        // Expect the relevant events to be emitted.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.CancelLockupStream(
            streamIds.recipientGoodStream, users.sender, address(recipientGood), dai, senderAmount, recipientAmount
        );
        vm.expectEmit({ emitter: address(lockup) });
        emit IERC4906.MetadataUpdate({ _tokenId: streamIds.recipientGoodStream });

        // Cancel the stream.
        uint128 refundedAmount = lockup.cancel(streamIds.recipientGoodStream);

        // Assert that the amount refunded matches the expected value.
        assertEq(refundedAmount, senderAmount, "refundedAmount");

        // Assert that the stream's status is "CANCELED".
        Lockup.Status actualStatus = lockup.statusOf(streamIds.recipientGoodStream);
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        assertEq(actualStatus, expectedStatus);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamIds.recipientGoodStream);
        assertFalse(isCancelable, "isCancelable");

        // Assert that the not burned NFT.
        address actualNFTOwner = lockup.ownerOf({ tokenId: streamIds.recipientGoodStream });
        address expectedNFTOwner = address(recipientGood);
        assertEq(actualNFTOwner, expectedNFTOwner, "NFT owner");
    }
}
