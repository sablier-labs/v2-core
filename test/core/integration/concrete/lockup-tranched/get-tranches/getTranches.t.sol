// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";
import { LockupTranched } from "src/core/types/DataTypes.sol";

import { LockupTranched_Integration_Concrete_Test } from "../LockupTranched.t.sol";

contract GetTranches_LockupTranched_Integration_Concrete_Test is LockupTranched_Integration_Concrete_Test {
    function test_RevertGiven_Null() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockupTranched.getTranches(nullStreamId);
    }

    function test_GivenNotNull() external {
        uint256 streamId = createDefaultStream();
        LockupTranched.Tranche[] memory actualTranches = lockupTranched.getTranches(streamId);
        LockupTranched.Tranche[] memory expectedTranches = defaults.tranches();
        assertEq(actualTranches, expectedTranches, "tranches");
    }
}
