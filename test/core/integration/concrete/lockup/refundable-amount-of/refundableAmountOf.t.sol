// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";

import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Integration_Test } from "../../../Integration.t.sol";

abstract contract RefundableAmountOf_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_RevertGiven_Null() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockup.refundableAmountOf(nullStreamId);
    }

    modifier givenNotNull() {
        defaultStreamId = createDefaultStream();
        _;
    }

    function test_GivenNonCancelableStream() external givenNotNull {
        uint256 streamId = createDefaultStreamNotCancelable();
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(streamId);
        uint128 expectedRefundableAmount = 0;
        assertEq(actualRefundableAmount, expectedRefundableAmount, "refundableAmount");
    }

    modifier givenStreamIsCancelable() {
        _;
    }

    function test_GivenCanceledStreamWithCANCELEDStatus() external givenNotNull givenStreamIsCancelable {
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() });
        lockup.cancel(defaultStreamId);
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedRefundableAmount = 0;
        assertEq(actualRefundableAmount, expectedRefundableAmount, "refundableAmount");
    }

    function test_GivenCanceledStreamWithDEPLETEDStatus() external givenNotNull givenStreamIsCancelable {
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() });
        lockup.cancel(defaultStreamId);
        lockup.withdrawMax({ streamId: defaultStreamId, to: users.recipient });
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() + 10 seconds });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedRefundableAmount = 0;
        assertEq(actualRefundableAmount, expectedRefundableAmount, "refundableAmount");
    }

    modifier givenNotCanceledStream() {
        _;
    }

    function test_GivenStatusIsPENDING() external givenNotNull givenStreamIsCancelable givenNotCanceledStream {
        vm.warp({ newTimestamp: getBlockTimestamp() - 1 seconds });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedReturnableAmount = defaults.DEPOSIT_AMOUNT();
        assertEq(actualRefundableAmount, expectedReturnableAmount, "refundableAmount");
    }

    function test_GivenStatusIsSTREAMING() external givenNotNull givenStreamIsCancelable givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedReturnableAmount = defaults.REFUND_AMOUNT();
        assertEq(actualRefundableAmount, expectedReturnableAmount, "refundableAmount");
    }

    function test_GivenStatusIsSETTLED() external givenNotNull givenStreamIsCancelable givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedReturnableAmount = 0;
        assertEq(actualRefundableAmount, expectedReturnableAmount, "refundableAmount");
    }

    function test_GivenStatusIsDEPLETED() external givenNotNull givenStreamIsCancelable givenNotCanceledStream {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: defaultStreamId, to: users.recipient });
        uint128 actualRefundableAmount = lockup.refundableAmountOf(defaultStreamId);
        uint128 expectedReturnableAmount = 0;
        assertEq(actualRefundableAmount, expectedReturnableAmount, "refundableAmount");
    }
}
