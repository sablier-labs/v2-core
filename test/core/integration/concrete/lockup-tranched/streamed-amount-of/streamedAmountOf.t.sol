pragma solidity >=0.8.22 <0.9.0;

import { StreamedAmountOf_Integration_Concrete_Test } from "./../../lockup/streamed-amount-of/streamedAmountOf.t.sol";
import { LockupTranched_Integration_Concrete_Test } from "./../LockupTranched.t.sol";

contract StreamedAmountOf_LockupTranched_Integration_Concrete_Test is
    LockupTranched_Integration_Concrete_Test,
    StreamedAmountOf_Integration_Concrete_Test
{
    function setUp()
        public
        virtual
        override(LockupTranched_Integration_Concrete_Test, StreamedAmountOf_Integration_Concrete_Test)
    {
        LockupTranched_Integration_Concrete_Test.setUp();
        StreamedAmountOf_Integration_Concrete_Test.setUp();
    }

    function test_GivenStartTimeInPresent() external givenSTREAMINGStatus {
        vm.warp({ newTimestamp: defaults.START_TIME() });
        uint128 actualStreamedAmount = lockupTranched.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_GivenEndTimeNotInFuture() external givenSTREAMINGStatus givenStartTimeInPast {
        vm.warp({ newTimestamp: defaults.END_TIME() + 1 seconds });

        // It should return the deposited amount.
        uint128 actualStreamedAmount = lockupTranched.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = defaults.DEPOSIT_AMOUNT();
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_GivenFirstTrancheTimestampInFuture()
        external
        givenSTREAMINGStatus
        givenStartTimeInPast
        givenEndTimeInFuture
    {
        vm.warp({ newTimestamp: defaults.START_TIME() + 1 seconds });

        // It should return 0.
        uint128 actualStreamedAmount = lockupTranched.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_GivenFirstTrancheTimestampNotInFuture()
        external
        givenSTREAMINGStatus
        givenStartTimeInPast
        givenEndTimeInFuture
    {
        vm.warp({ newTimestamp: defaults.END_TIME() - 1 seconds });

        // It should return the correct streamed amount.
        uint128 actualStreamedAmount = lockupTranched.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = defaults.tranches()[0].amount + defaults.tranches()[1].amount;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }
}
