// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { LockupLinear } from "src/types/DataTypes.sol";

import { LockupLinear_Integration_Concrete_Test } from "../LockupLinear.t.sol";
import { StreamedAmountOf_Integration_Concrete_Test } from "../../lockup/streamed-amount-of/streamedAmountOf.t.sol";

contract StreamedAmountOf_LockupLinear_Integration_Concrete_Test is
    LockupLinear_Integration_Concrete_Test,
    StreamedAmountOf_Integration_Concrete_Test
{
    function setUp()
        public
        virtual
        override(LockupLinear_Integration_Concrete_Test, StreamedAmountOf_Integration_Concrete_Test)
    {
        LockupLinear_Integration_Concrete_Test.setUp();
        StreamedAmountOf_Integration_Concrete_Test.setUp();
    }

    modifier givenStatusPending() {
        _;
    }

    function test_StreamedAmountOf_CliffTimeZero()
        external
        givenNotNull
        givenStreamHasNotBeenCanceled
        givenStatusPending
    {
        vm.warp({ newTimestamp: defaults.START_TIME() - 1 });

        LockupLinear.Timestamps memory timestamps = defaults.lockupLinearTimestamps();
        timestamps.cliff = 0;
        uint256 streamId = createDefaultStreamWithTimestamps(timestamps);

        uint128 actualStreamedAmount = lockupLinear.streamedAmountOf(streamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_StreamedAmountOf_CliffTimeInTheFuture()
        external
        view
        givenNotNull
        givenStreamHasNotBeenCanceled
        givenStatusStreaming
    {
        uint128 actualStreamedAmount = lockupLinear.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_StreamedAmountOf_CliffTimeInThePresent()
        external
        givenNotNull
        givenStreamHasNotBeenCanceled
        givenStatusStreaming
    {
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() });
        uint128 actualStreamedAmount = lockupLinear.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = defaults.CLIFF_AMOUNT();
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_StreamedAmountOf_CliffTimeInThePast()
        external
        givenNotNull
        givenStreamHasNotBeenCanceled
        givenStatusStreaming
    {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        uint128 actualStreamedAmount = lockupLinear.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 2600e18;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }
}
