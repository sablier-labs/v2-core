// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";

import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { ISablierLockupRecipient } from "src/interfaces/ISablierLockupRecipient.sol";
import { Errors } from "src/libraries/Errors.sol";
import { Lockup } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../../Integration.t.sol";

abstract contract Cancel_Integration_Concrete_Test is Integration_Test {
    function test_RevertWhen_DelegateCall() external {
        expectRevert_DelegateCall({ callData: abi.encodeCall(lockup.cancel, streamIds.defaultStream) });
    }

    function test_RevertGiven_Null() external whenNoDelegateCall {
        expectRevert_Null({ callData: abi.encodeCall(lockup.cancel, streamIds.nullStream) });
    }

    function test_RevertGiven_DEPLETEDStatus() external whenNoDelegateCall givenNotNull givenColdStream {
        expectRevert_DEPLETEDStatus({ callData: abi.encodeCall(lockup.cancel, streamIds.defaultStream) });
    }

    function test_RevertGiven_CANCELEDStatus() external whenNoDelegateCall givenNotNull givenColdStream {
        expectRevert_CANCELEDStatus({ callData: abi.encodeCall(lockup.cancel, streamIds.defaultStream) });
    }

    function test_RevertGiven_SETTLEDStatus() external whenNoDelegateCall givenNotNull givenColdStream {
        expectRevert_SETTLEDStatus({ callData: abi.encodeCall(lockup.cancel, streamIds.defaultStream) });
    }

    function test_RevertWhen_CallerMaliciousThirdParty()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerNotSender
    {
        expectRevert_CallerMaliciousThirdParty({ callData: abi.encodeCall(lockup.cancel, streamIds.defaultStream) });
    }

    function test_RevertWhen_CallerRecipient()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerNotSender
    {
        // Make the Recipient the caller in this test.
        resetPrank({ msgSender: users.recipient });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupBase_Unauthorized.selector, streamIds.defaultStream, users.recipient
            )
        );
        lockup.cancel(streamIds.defaultStream);
    }

    function test_RevertGiven_NonCancelableStream()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
    {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamNotCancelable.selector, streamIds.notCancelableStream)
        );
        lockup.cancel(streamIds.notCancelableStream);
    }

    function test_GivenPENDINGStatus()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
    {
        // Warp to the past.
        vm.warp({ newTimestamp: getBlockTimestamp() - 1 seconds });

        // Cancel the stream.
        lockup.cancel(streamIds.defaultStream);

        // It should mark the stream as depleted.
        Lockup.Status actualStatus = lockup.statusOf(streamIds.defaultStream);
        Lockup.Status expectedStatus = Lockup.Status.DEPLETED;
        assertEq(actualStatus, expectedStatus);

        // It should make the stream not cancelable.
        bool isCancelable = lockup.isCancelable(streamIds.defaultStream);
        assertFalse(isCancelable, "isCancelable");
    }

    function test_GivenRecipientNotAllowedToHook()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
        givenSTREAMINGStatus
    {
        // It should not make Sablier run the recipient hook.
        uint128 senderAmount = lockup.refundableAmountOf(streamIds.notAllowedtoHookStream);
        uint128 recipientAmount = lockup.withdrawableAmountOf(streamIds.notAllowedtoHookStream);
        vm.expectCall({
            callee: address(recipientGood),
            data: abi.encodeCall(
                ISablierLockupRecipient.onSablierLockupCancel,
                (streamIds.notAllowedtoHookStream, users.sender, senderAmount, recipientAmount)
            ),
            count: 0
        });

        // Cancel the stream.
        uint128 refundedAmount = lockup.cancel(streamIds.notAllowedtoHookStream);

        // It should return the correct refunded amount.
        assertEq(refundedAmount, senderAmount, "refundedAmount");

        // It should mark the stream as canceled.
        Lockup.Status actualStatus = lockup.statusOf(streamIds.notAllowedtoHookStream);
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        assertEq(actualStatus, expectedStatus);
    }

    function test_WhenRevertingRecipient()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
        givenSTREAMINGStatus
        givenRecipientAllowedToHook
    {
        // It should revert.
        vm.expectRevert("You shall not pass");

        // Cancel the stream.
        lockup.cancel(streamIds.recipientRevertStream);
    }

    function test_RevertWhen_RecipientReturnsInvalidSelector()
        external
        whenNoDelegateCall
        givenNotNull
        givenWarmStream
        whenCallerSender
        givenCancelableStream
        givenSTREAMINGStatus
        givenRecipientAllowedToHook
        whenNonRevertingRecipient
    {
        // It should revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupBase_InvalidHookSelector.selector, address(recipientInvalidSelector)
            )
        );

        // Cancel the stream.
        lockup.cancel(streamIds.recipientInvalidSelectorStream);
    }

    function test_WhenReentrancy()
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
    {
        // It should make Sablier run the recipient hook.
        uint128 senderAmount = lockup.refundableAmountOf(streamIds.recipientReentrantStream);
        uint128 recipientAmount = lockup.withdrawableAmountOf(streamIds.recipientReentrantStream);
        vm.expectCall(
            address(recipientReentrant),
            abi.encodeCall(
                ISablierLockupRecipient.onSablierLockupCancel,
                (streamIds.recipientReentrantStream, users.sender, senderAmount, recipientAmount)
            )
        );

        // It should perform a reentrancy call to the Lockup contract.
        vm.expectCall(
            address(lockup),
            abi.encodeCall(
                ISablierLockupBase.withdraw,
                (streamIds.recipientReentrantStream, address(recipientReentrant), recipientAmount)
            )
        );

        // Cancel the stream.
        uint128 refundedAmount = lockup.cancel(streamIds.recipientReentrantStream);

        // It should return the correct refunded amount.
        assertEq(refundedAmount, senderAmount, "refundedAmount");

        // It should mark the stream as depleted. The reentrant recipient withdrew all the funds.
        Lockup.Status actualStatus = lockup.statusOf(streamIds.recipientReentrantStream);
        Lockup.Status expectedStatus = Lockup.Status.DEPLETED;
        assertEq(actualStatus, expectedStatus);

        // It should make the withdrawal via the reentrancy.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamIds.recipientReentrantStream);
        assertEq(actualWithdrawnAmount, recipientAmount, "withdrawnAmount");
    }

    function test_WhenNoReentrancy()
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
    {
        // It should refund the sender.
        uint128 senderAmount = lockup.refundableAmountOf(streamIds.recipientGoodStream);
        expectCallToTransfer({ to: users.sender, value: senderAmount });

        // It should make Sablier run the recipient hook.
        uint128 recipientAmount = lockup.withdrawableAmountOf(streamIds.recipientGoodStream);
        vm.expectCall(
            address(recipientGood),
            abi.encodeCall(
                ISablierLockupRecipient.onSablierLockupCancel,
                (streamIds.recipientGoodStream, users.sender, senderAmount, recipientAmount)
            )
        );

        // It should emit {MetadataUpdate} and {CancelLockupStream} events.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.CancelLockupStream(
            streamIds.recipientGoodStream, users.sender, address(recipientGood), dai, senderAmount, recipientAmount
        );
        vm.expectEmit({ emitter: address(lockup) });
        emit IERC4906.MetadataUpdate({ _tokenId: streamIds.recipientGoodStream });

        // Cancel the stream.
        uint128 refundedAmount = lockup.cancel(streamIds.recipientGoodStream);

        // It should return the correct refunded amount.
        assertEq(refundedAmount, senderAmount, "refundedAmount");

        // It should mark the stream as canceled.
        Lockup.Status actualStatus = lockup.statusOf(streamIds.recipientGoodStream);
        Lockup.Status expectedStatus = Lockup.Status.CANCELED;
        assertEq(actualStatus, expectedStatus);

        // It should make the stream as non cancelable.
        bool isCancelable = lockup.isCancelable(streamIds.recipientGoodStream);
        assertFalse(isCancelable, "isCancelable");

        // It should update the refunded amount.
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.recipientGoodStream);
        uint128 expectedRefundedAmount = senderAmount;
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");

        // It should not burn the NFT.
        address actualNFTOwner = lockup.ownerOf({ tokenId: streamIds.recipientGoodStream });
        address expectedNFTOwner = address(recipientGood);
        assertEq(actualNFTOwner, expectedNFTOwner, "NFT owner");
    }
}
