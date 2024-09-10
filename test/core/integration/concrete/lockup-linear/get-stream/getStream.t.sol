// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";
import { LockupLinear } from "src/core/types/DataTypes.sol";

import { LockupLinear_Integration_Shared_Test } from "../LockupLinear.t.sol";

contract GetStream_LockupLinear_Integration_Concrete_Test is LockupLinear_Integration_Shared_Test {
    function setUp() public virtual override {
        LockupLinear_Integration_Shared_Test.setUp();
    }

    function test_RevertGiven_Null() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockupLinear.getStream(nullStreamId);
    }

    function test_GivenSettledStream() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });

        // It should return the stream struct.
        LockupLinear.StreamLL memory actualStream = lockupLinear.getStream(defaultStreamId);
        LockupLinear.StreamLL memory expectedStream = defaults.lockupLinearStream();
        // It should always return stream as non-cancelable.
        expectedStream.isCancelable = false;
        assertEq(actualStream, expectedStream);
    }

    function test_GivenNotSettledStream() external givenNotNull {
        // It should return the stream struct.
        LockupLinear.StreamLL memory actualStream = lockupLinear.getStream(defaultStreamId);
        LockupLinear.StreamLL memory expectedStream = defaults.lockupLinearStream();
        assertEq(actualStream, expectedStream);
    }
}
