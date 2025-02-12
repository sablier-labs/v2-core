// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC721Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract Getters_Integration_Concrete_Test is Integration_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                GET-DEPOSITED-AMOUNT
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetDepositedAmountRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getDepositedAmount, streamIds.nullStream) });
    }

    function test_GetDepositedAmountGivenNotNull() external view {
        uint128 actualDepositedAmount = lockup.getDepositedAmount(streamIds.defaultStream);
        uint128 expectedDepositedAmount = defaults.DEPOSIT_AMOUNT();
        assertEq(actualDepositedAmount, expectedDepositedAmount, "depositedAmount");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    GET-END-TIME
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetEndTimeRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getEndTime, streamIds.nullStream) });
    }

    function test_GetEndTimeGivenNotNull() external view {
        uint40 actualEndTime = lockup.getEndTime(streamIds.defaultStream);
        uint40 expectedEndTime = defaults.END_TIME();
        assertEq(actualEndTime, expectedEndTime, "endTime");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   GET-RECIPIENT
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetRecipientRevertGiven_Null() external {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, streamIds.nullStream));
        lockup.getRecipient(streamIds.nullStream);
    }

    function test_GetRecipientRevertGiven_BurnedNFT() external givenNotNull {
        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.END_TIME() });

        // Make the Recipient the caller.
        resetPrank({ msgSender: users.recipient });

        // Deplete the stream.
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });

        // Burn the NFT.
        lockup.burn(streamIds.defaultStream);

        // Expect the relevant error when retrieving the recipient.
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, streamIds.defaultStream));
        lockup.getRecipient(streamIds.defaultStream);
    }

    function test_GetRecipientGivenNotBurnedNFT() external view givenNotNull {
        address actualRecipient = lockup.getRecipient(streamIds.defaultStream);
        address expectedRecipient = users.recipient;
        assertEq(actualRecipient, expectedRecipient, "recipient");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                GET-REFUNDED-AMOUNT
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetRefundedAmountRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getRefundedAmount, streamIds.nullStream) });
    }

    function test_GetRefundedAmountGivenCanceledStreamAndCANCELEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        // Cancel the stream.
        lockup.cancel(streamIds.defaultStream);

        // It should return the correct refunded amount.
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = defaults.REFUND_AMOUNT();
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    function test_GetRefundedAmountGivenCanceledStreamAndDEPLETEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        // Cancel the stream.
        lockup.cancel(streamIds.defaultStream);

        // Withdraw the maximum amount to deplete the stream.
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });

        // It should return the correct refunded amount.
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = defaults.REFUND_AMOUNT();
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    function test_GetRefundedAmountGivenPENDINGStatus() external givenNotNull givenNotCanceledStream {
        vm.warp({ newTimestamp: getBlockTimestamp() - 1 seconds });
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = 0;
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    function test_GetRefundedAmountGivenSETTLEDStatus() external givenNotNull givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = 0;
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    function test_GetRefundedAmountGivenDEPLETEDStatus() external givenNotNull givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = 0;
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    function test_GetRefundedAmountGivenSTREAMINGStatus() external givenNotNull givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        uint128 actualRefundedAmount = lockup.getRefundedAmount(streamIds.defaultStream);
        uint128 expectedRefundedAmount = 0;
        assertEq(actualRefundedAmount, expectedRefundedAmount, "refundedAmount");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     GET-SENDER
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetSenderRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getSender, streamIds.nullStream) });
    }

    function test_GetSenderGivenNotNull() external view {
        address actualSender = lockup.getSender(streamIds.defaultStream);
        address expectedSender = users.sender;
        assertEq(actualSender, expectedSender, "sender");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   GET-START-TIME
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetStartTimeRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getStartTime, streamIds.nullStream) });
    }

    function test_GetStartTimeGivenNotNull() external view {
        uint40 actualStartTime = lockup.getStartTime(streamIds.defaultStream);
        uint40 expectedStartTime = defaults.START_TIME();
        assertEq(actualStartTime, expectedStartTime, "startTime");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                GET-UNDERLYING-TOKEN
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetUnderlyingTokenRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getUnderlyingToken, streamIds.nullStream) });
    }

    function test_GetUnderlyingTokenGivenNotNull() external view {
        IERC20 actualUnderlyingToken = lockup.getUnderlyingToken(streamIds.defaultStream);
        IERC20 expectedUnderlyingToken = dai;
        assertEq(actualUnderlyingToken, expectedUnderlyingToken, "underlyingToken");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                GET-WITHDRAWN-AMOUNT
    //////////////////////////////////////////////////////////////////////////*/

    function test_GetWithdrawnAmountRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.getWithdrawnAmount, streamIds.nullStream) });
    }

    function test_GetWithdrawnAmountGivenNoPreviousWithdrawals() external givenNotNull {
        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // It should return zero.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamIds.defaultStream);
        uint128 expectedWithdrawnAmount = 0;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount, "withdrawnAmount");
    }

    function test_GetWithdrawnAmountGivenPreviousWithdrawal() external givenNotNull {
        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Set the withdraw amount to the streamed amount.
        uint128 withdrawAmount = lockup.streamedAmountOf(streamIds.defaultStream);

        // Make the withdrawal.
        lockup.withdraw({ streamId: streamIds.defaultStream, to: users.recipient, amount: withdrawAmount });

        // It should return the correct withdrawn amount.
        uint128 actualWithdrawnAmount = lockup.getWithdrawnAmount(streamIds.defaultStream);
        uint128 expectedWithdrawnAmount = withdrawAmount;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount, "withdrawnAmount");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 IS-ALLOWED-TO-HOOK
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsAllowedToHookGivenProvidedAddressNotAllowedToHook() external view {
        bool result = lockup.isAllowedToHook(address(recipientInterfaceIDIncorrect));
        assertFalse(result, "isAllowedToHook");
    }

    function test_IsAllowedToHookGivenProvidedAddressAllowedToHook() external view {
        bool result = lockup.isAllowedToHook(address(recipientGood));
        assertTrue(result, "isAllowedToHook");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   IS-CANCELABLE
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsCancelableRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.isCancelable, streamIds.nullStream) });
    }

    function test_IsCancelableGivenColdStream() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() }); // settled status
        assertFalse(lockup.isCancelable(streamIds.defaultStream), "isCancelable");
    }

    function test_IsCancelableGivenCancelableStream() external view givenNotNull givenWarmStream {
        assertTrue(lockup.isCancelable(streamIds.defaultStream), "isCancelable");
    }

    function test_IsCancelableGivenNonCancelableStream() external view givenNotNull givenWarmStream {
        assertFalse(lockup.isCancelable(streamIds.notCancelableStream), "isCancelable");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      IS-COLD
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsColdRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.isCold, streamIds.nullStream) });
    }

    function test_IsColdGivenPENDINGStatus() external givenNotNull {
        vm.warp({ newTimestamp: getBlockTimestamp() - 1 seconds });
        assertFalse(lockup.isCold(streamIds.defaultStream), "isCold");
    }

    function test_IsColdGivenSTREAMINGStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        assertFalse(lockup.isCold(streamIds.defaultStream), "isCold");
    }

    function test_IsColdGivenSETTLEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        assertTrue(lockup.isCold(streamIds.defaultStream), "isCold");
    }

    function test_IsColdGivenCANCELEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        lockup.cancel(streamIds.defaultStream);
        assertTrue(lockup.isCold(streamIds.defaultStream), "isCold");
    }

    function test_IsColdGivenDEPLETEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });
        assertTrue(lockup.isCold(streamIds.defaultStream), "isCold");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    IS-DEPLETED
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsDepletedRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.isDepleted, streamIds.nullStream) });
    }

    function test_IsDepletedGivenNotDepletedStream() external view givenNotNull {
        assertFalse(lockup.isDepleted(streamIds.defaultStream), "isDepleted");
    }

    function test_IsDepletedGivenDepletedStream() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });
        assertTrue(lockup.isDepleted(streamIds.defaultStream), "isDepleted");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     IS-STREAM
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsStreamGivenNull() external view {
        assertFalse(lockup.isStream(streamIds.nullStream), "isStream");
    }

    function test_IsStreamGivenNotNull() external view {
        assertTrue(lockup.isStream(streamIds.defaultStream), "isStream");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  IS-TRANSFERABLE
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsTransferableRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.isTransferable, streamIds.nullStream) });
    }

    function test_IsTransferableGivenNonTransferableStream() external view givenNotNull {
        assertFalse(lockup.isTransferable(streamIds.notTransferableStream), "isTransferable");
    }

    function test_IsTransferableGivenTransferableStream() external view givenNotNull {
        assertTrue(lockup.isTransferable(streamIds.defaultStream), "isTransferable");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      IS-WARM
    //////////////////////////////////////////////////////////////////////////*/

    function test_IsWarmRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.isWarm, streamIds.nullStream) });
    }

    function test_IsWarmGivenPENDINGStatus() external givenNotNull {
        vm.warp({ newTimestamp: getBlockTimestamp() - 1 seconds });
        assertTrue(lockup.isWarm(streamIds.defaultStream), "isWarm");
    }

    function test_IsWarmGivenSTREAMINGStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        assertTrue(lockup.isWarm(streamIds.defaultStream), "isWarm");
    }

    function test_IsWarmGivenSETTLEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        assertFalse(lockup.isWarm(streamIds.defaultStream), "isWarm");
    }

    function test_IsWarmGivenCANCELEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        lockup.cancel(streamIds.defaultStream);
        assertFalse(lockup.isWarm(streamIds.defaultStream), "isWarm");
    }

    function test_IsWarmGivenDEPLETEDStatus() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: streamIds.defaultStream, to: users.recipient });
        assertFalse(lockup.isWarm(streamIds.defaultStream), "isWarm");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    WAS-CANCELED
    //////////////////////////////////////////////////////////////////////////*/

    function test_WasCanceledRevertGiven_Null() external {
        expectRevert_Null({ callData: abi.encodeCall(lockup.wasCanceled, streamIds.nullStream) });
    }

    function test_WasCanceledGivenCanceledStream() external view givenNotNull {
        assertFalse(lockup.wasCanceled(streamIds.defaultStream), "wasCanceled");
    }

    function test_WasCanceledGivenNotCanceledStream() external givenNotNull {
        lockup.cancel(streamIds.defaultStream);
        assertTrue(lockup.wasCanceled(streamIds.defaultStream), "wasCanceled");
    }
}
