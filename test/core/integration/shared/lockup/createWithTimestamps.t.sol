// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup_Integration_Shared_Test } from "./Lockup.t.sol";

abstract contract CreateWithTimestamps_Integration_Shared_Test is Lockup_Integration_Shared_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        streamId = lockup.nextStreamId();
    }

    modifier whenAssetIsContract() {
        _;
    }

    modifier whenAssetERC20() {
        _;
    }

    modifier whenBrokerFeeIsNotTooHigh() {
        _;
    }

    modifier whenCliffTimeIsGreaterThanZero() {
        _;
    }

    modifier whenCliffTimeIsLessThanEndTime() {
        _;
    }

    modifier whenCliffTimeIsZero() {
        _;
    }

    modifier whenDepositAmountEqualToSegmentAmountsSum() {
        _;
    }

    modifier whenTheDepositAmountEqualsTrancheAmountsSum() {
        _;
    }

    modifier whenDepositAmountIsNotZero() {
        _;
    }

    modifier whenNoDelegateCall() {
        _;
    }

    modifier whenRecipientIsNotZeroAddress() {
        _;
    }

    modifier whenSegmentAmountsSumDoesNotOverflow() {
        _;
    }

    modifier whenSegmentCountIsNotTooHigh() {
        _;
    }

    modifier whenSegmentCountIsNotZero() {
        _;
    }

    modifier whenSegmentTimestampsAreOrdered() {
        _;
    }

    modifier whenSenderIsNotZeroAddress() {
        _;
    }

    modifier whenStartTimeIsLessThanCliffTime() {
        _;
    }

    modifier whenStartTimeLessThanEndTime() {
        _;
    }

    modifier whenStartTimeIsLessThanFirstSegmentTimestamp() {
        _;
    }

    modifier whenStartTimeIsLessThanFirstTrancheTimestamp() {
        _;
    }

    modifier whenStartTimeIsNotZero() {
        _;
    }

    modifier whenTrancheAmountsSumDoesNotOverflow() {
        _;
    }

    modifier whenTrancheCountIsNotTooHigh() {
        _;
    }

    modifier whenTrancheCountIsNotZero() {
        _;
    }

    modifier whenTrancheTimestampsAreOrdered() {
        _;
    }
}
