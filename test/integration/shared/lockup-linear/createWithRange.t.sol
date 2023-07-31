// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear_Integration_Shared_Test } from "./LockupLinear.t.sol";

abstract contract CreateWithRange_Integration_Shared_Test is LockupLinear_Integration_Shared_Test {
    uint256 internal streamId;

    function setUp() public virtual override {
        streamId = lockupLinear.nextStreamId();
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

    modifier givenStartTimeNotGreaterThanCliffTime() {
        _;
    }

    modifier givenCliffTimeLessThanEndTime() {
        _;
    }

    modifier givenEndTimeInTheFuture() {
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
