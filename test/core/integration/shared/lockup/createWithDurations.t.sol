// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup_Integration_Shared_Test } from "./Lockup.t.sol";

abstract contract CreateWithDurations_Integration_Shared_Test is Lockup_Integration_Shared_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        streamId = lockup.nextStreamId();
    }

    modifier whenCliffDurationCalculationDoesNotOverflow() {
        _;
    }

    modifier whenDurationsNotZero() {
        _;
    }

    modifier whenIndexOneOrHigherNotContainZeroDuration() {
        _;
    }

    modifier whenNoDelegateCall() {
        _;
    }

    modifier whenSegmentCountIsNotTooHigh() {
        _;
    }

    modifier whenSegmentTimestampCalculationsOverflow() {
        _;
    }

    modifier whenTimestampsCalculationsDoNotOverflow() {
        _;
    }

    modifier whenTotalDurationCalculationDoesNotOverflow() {
        _;
    }

    modifier whenTrancheCountIsNotTooHigh() {
        _;
    }

    modifier whenTrancheTimestampCalculationsOverflow() {
        _;
    }
}
