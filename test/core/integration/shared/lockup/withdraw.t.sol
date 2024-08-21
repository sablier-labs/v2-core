// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup_Integration_Shared_Test } from "./Lockup.t.sol";

abstract contract Withdraw_Integration_Shared_Test is Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;
    address internal caller;

    function setUp() public virtual override {
        defaultStreamId = createDefaultStream();
        resetPrank({ msgSender: users.recipient });
    }

    modifier givenEndTimeInFuture() {
        // Simulate the passage of time.
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        _;
    }

    modifier givenNotNull() {
        _;
    }

    modifier givenRecipientIsAllowedToHook() {
        _;
    }

    modifier givenStatusIsNotDEPLETED() {
        vm.warp({ newTimestamp: defaults.START_TIME() });
        _;
    }

    modifier whenCallerRecipient() {
        _;
    }

    modifier whenCallerIsSender() {
        resetPrank({ msgSender: users.sender });
        _;
    }

    modifier whenWithdrawAmountDoesNotOverdraw() {
        _;
    }

    modifier whenNoDelegateCall() {
        _;
    }

    modifier whenRecipientNotReentrant() {
        _;
    }

    modifier whenRecipientDoesNotRevert() {
        _;
    }

    modifier whenRecipientHookReturnsValidSelector() {
        _;
    }

    modifier givenNotCanceledStream() {
        _;
    }

    modifier whenWithdrawalAddressIsNotZero() {
        _;
    }

    modifier whenWithdrawalAddressIsRecipient() {
        _;
    }

    modifier whenWithdrawalAddressNotRecipient() {
        _;
    }

    modifier whenWithdrawAmountIsNotZero() {
        _;
    }
}
