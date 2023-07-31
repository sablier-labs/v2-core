// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic_Integration_Shared_Test } from "./LockupDynamic.t.sol";

contract CreateWithMilestones_Integration_Shared_Test is LockupDynamic_Integration_Shared_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        streamId = lockupDynamic.nextStreamId();
    }

    modifier givenNotDelegateCalled() {
        _;
    }

    modifier givenRecipientNonZeroAddress() {
        _;
    }

    modifier givenDepositAmountNotZero() {
        _;
    }

    modifier givenSegmentCountNotZero() {
        _;
    }

    modifier givenSegmentCountNotTooHigh() {
        _;
    }

    modifier givenSegmentAmountsSumDoesNotOverflow() {
        _;
    }

    modifier givenStartTimeLessThanFirstSegmentMilestone() {
        _;
    }

    modifier givenSegmentMilestonesOrdered() {
        _;
    }

    modifier givenEndTimeInTheFuture() {
        _;
    }

    modifier givenDepositAmountEqualToSegmentAmountsSum() {
        _;
    }

    modifier givenProtocolFeeNotTooHigh() {
        _;
    }

    modifier givenBrokerFeeNotTooHigh() {
        _;
    }

    modifier givenAssetContract() {
        _;
    }

    modifier givenAssetERC20() {
        _;
    }
}
