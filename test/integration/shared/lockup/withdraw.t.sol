// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup_Integration_Shared_Test } from "./Lockup.t.sol";

abstract contract Withdraw_Integration_Shared_Test is Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        defaultStreamId = createDefaultStream();
        changePrank({ msgSender: users.recipient });
    }

    modifier givenNotDelegateCalled() {
        _;
    }

    modifier givenNotNull() {
        _;
    }

    modifier givenStreamNotDepleted() {
        vm.warp({ timestamp: defaults.START_TIME() });
        _;
    }

    modifier givenCallerUnauthorized() {
        _;
    }

    modifier givenCallerAuthorized() {
        _;
    }

    modifier givenToNonZeroAddress() {
        _;
    }

    modifier givenWithdrawAmountNotZero() {
        _;
    }

    modifier givenWithdrawAmountNotGreaterThanWithdrawableAmount() {
        _;
    }

    modifier givenCallerRecipient() {
        _;
    }

    modifier givenStreamHasNotBeenCanceled() {
        _;
    }
}
