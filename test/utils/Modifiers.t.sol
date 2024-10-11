// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierLockup } from "src/core/interfaces/ISablierLockup.sol";

import { Utils } from "./Utils.sol";

abstract contract Modifiers is Utils {
    /*//////////////////////////////////////////////////////////////////////////
                                       COMMON
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenCallerRecipient(address recipient) {
        resetPrank({ msgSender: recipient });
        _;
    }

    modifier givenCliffTimeNotInFuture(uint256 timestamp) {
        vm.warp({ newTimestamp: timestamp });
        _;
    }

    modifier givenEndTimeInFuture(uint256 timestamp) {
        // Simulate the passage of time.
        vm.warp({ newTimestamp: timestamp });
        _;
    }

    modifier givenNFTExists() {
        _;
    }

    modifier givenNotCanceledStream() {
        _;
    }

    modifier givenNotNull() {
        _;
    }

    modifier givenPreviousWithdrawal() {
        _;
    }

    modifier givenRecipientAllowedToHook() {
        _;
    }

    modifier givenStartTimeInPast() {
        _;
    }

    /// @dev In LockupLinear, the streaming starts after the cliff time, whereas in LockupDynamic, the streaming starts
    /// after the start time.
    modifier givenSTREAMINGStatus(uint256 timestamp) {
        // Warp to the future, after the stream's start time but before the stream's end time.
        vm.warp({ newTimestamp: timestamp });
        _;
    }

    modifier givenWarmStream() {
        _;
    }

    modifier whenAssetContract() {
        _;
    }

    modifier whenAssetERC20() {
        _;
    }

    modifier whenAuthorizedCaller() {
        _;
    }

    modifier whenCallerAdmin(address admin) {
        // Make the Admin the caller in the rest of this test suite.
        resetPrank({ msgSender: admin });
        _;
    }

    modifier whenCallerSender(address sender) {
        resetPrank({ msgSender: sender });
        _;
    }

    modifier whenNoDelegateCall() {
        _;
    }

    modifier whenNonRevertingRecipient() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   ALLOW-TO-HOOK
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenProvidedAddressContract() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        BURN
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenCallerNotRecipient() {
        _;
    }

    modifier givenNotDepletedStream() {
        _;
    }

    modifier givenDepletedStream(ISablierLockup lockup, uint256 streamId) {
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) });
        lockup.withdrawMax({ streamId: streamId, to: lockup.getRecipient(streamId) });
        _;
    }

    modifier givenTransferableNFT() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       CANCEL
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenCancelableStream() {
        _;
    }

    modifier givenColdStream() {
        _;
    }

    modifier whenRecipientNotReentrant() {
        _;
    }

    modifier whenRecipientReturnsValidSelector() {
        _;
    }

    modifier whenUnauthorizedCaller() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CANCEL-MULTIPLE
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenAllStreamsCancelable() {
        _;
    }

    modifier givenNoColdStreams() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   CREATE-COMMON
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenBrokerFeeNotExceedMaxValue() {
        _;
    }

    modifier whenSegmentCountNotExceedMaxValue() {
        _;
    }

    modifier whenTrancheCountNotExceedMaxValue() {
        _;
    }

    modifier whenCliffTimeNotZero() {
        _;
    }

    modifier whenCliffTimeZero() {
        _;
    }

    modifier whenCliffTimeLessThanEndTime() {
        _;
    }

    modifier whenDepositAmountNotZero() {
        _;
    }

    modifier whenDepositAmountNotEqualSegmentAmountsSum() {
        _;
    }

    modifier whenDepositAmountNotEqualTrancheAmountsSum() {
        _;
    }

    modifier whenRecipientNotZeroAddress() {
        _;
    }

    modifier whenSegmentAmountsSumNotOverflow() {
        _;
    }

    modifier whenSegmentCountNotZero() {
        _;
    }

    modifier whenSenderNotZeroAddress() {
        _;
    }

    modifier whenStartTimeNotZero() {
        _;
    }

    modifier whenStartTimeLessThanCliffTime() {
        _;
    }

    modifier whenStartTimeLessThanEndTime() {
        _;
    }

    modifier whenStartTimeLessThanFirstTimestamp() {
        _;
    }

    modifier whenTimestampsStrictlyIncreasing() {
        _;
    }

    modifier whenTrancheAmountsSumNotOverflow() {
        _;
    }

    modifier whenTrancheCountNotZero() {
        _;
    }

    modifier whenTrancheTimestampsAreOrdered() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CREATE-WITH-DURATION
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenCliffDurationNotZero() {
        _;
    }

    modifier whenCliffDurationZero() {
        _;
    }

    modifier WhenCliffTimeCalculationNotOverflow() {
        _;
    }

    modifier whenEndTimeCalculationNotOverflow() {
        _;
    }

    modifier whenFirstIndexHasNonZeroDuration() {
        _;
    }

    modifier whenStartTimeNotExceedsFirstTimestamp() {
        _;
    }

    modifier whenTimestampsCalculationNotOverflow() {
        _;
    }

    modifier whenTimestampsCalculationOverflows() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SAFE-ASSET-SYMBOL
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenSymbolImplemented() {
        _;
    }

    modifier givenSymbolAsString() {
        _;
    }

    modifier givenSymbolNotLongerThan30Chars() {
        _;
    }

    modifier whenNotEmptyString() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MAP-SYMBOL
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenKnownNFTContract() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     STATUS-OF
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenAssetsNotFullyWithdrawn() {
        _;
    }

    modifier givenStartTimeNotInFuture() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 STREAMED-AMOUNT-OF
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenCliffTimeInPast() {
        _;
    }

    modifier givenPENDINGStatus() {
        _;
    }

    modifier givenMultipleSegments() {
        _;
    }

    modifier whenCurrentTimestampNot1st() {
        _;
    }

    modifier givenMultipleTranches() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TRANSFER-ADMIN
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenNewAdminNotSameAsCurrentAdmin() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      WITHDRAW
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenNotDEPLETEDStatus(uint256 timestampt) {
        vm.warp({ newTimestamp: timestampt });
        _;
    }

    modifier whenHookReturnsValidSelector() {
        _;
    }

    modifier whenNonZeroWithdrawAmount() {
        _;
    }

    modifier whenWithdrawalAddressNotZero() {
        _;
    }

    modifier whenWithdrawalAddressRecipient() {
        _;
    }

    modifier whenWithdrawAmountNotOverdraw() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   WITHDRAW-HOOKS
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenRecipientNotSameAsSender() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 WITHDRAW-MULTIPLE
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenArraysEqual() {
        _;
    }

    modifier givenNoDEPLETEDStreams(uint256 timestampt) {
        vm.warp({ newTimestamp: timestampt });
        _;
    }

    modifier givenNoNullStreams() {
        _;
    }

    modifier whenEqualArraysLength() {
        _;
    }

    modifier whenNonZeroArrayLength() {
        _;
    }

    modifier whenNoAmountOverdraws() {
        _;
    }

    modifier whenNoZeroAmounts() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                             WITHDRAW-MAX-AND-TRANSFER
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenNonZeroWithdrawableAmount() {
        _;
    }

    modifier givenNotBurnedNFT() {
        _;
    }

    modifier givenTransferableStream() {
        _;
    }

    modifier whenCallerCurrentRecipient() {
        _;
    }
}
