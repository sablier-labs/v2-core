// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Batch } from "src/core/abstracts/Batch.sol";
import { Errors } from "src/core/libraries/Errors.sol";

import { Integration_Test } from "./../../../Integration.t.sol";

abstract contract Batch_Integration_Concrete_Test is Integration_Test {
    function test_RevertWhen_CallFunctionNotExist() external {
        bytes[] memory calls = new bytes[](1);
        calls[0] = abi.encodeCall(dai.balanceOf, (users.recipient));

        Batch(address(lockup)).batch(calls);
    }

    function test_RevertWhen_DataInvalid() external whenCallFunctionExists {
        uint256 nonExistentStreamId = 1337;

        bytes[] memory calls = new bytes[](1);
        calls[0] = abi.encodeCall(lockup.getDepositedAmount, (nonExistentStreamId));

        bytes memory expectedRevertData = abi.encodeWithSelector(
            Errors.BatchError.selector, abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nonExistentStreamId)
        );

        vm.expectRevert(expectedRevertData);

        Batch(address(lockup)).batch(calls);
    }

    function test_WhenDataValid() external whenCallFunctionExists {
        resetPrank({ msgSender: users.sender });

        bytes[] memory calls = new bytes[](1);
        calls[0] = abi.encodeCall(lockup.cancel, (defaultStreamId));

        Batch(address(lockup)).batch(calls);
        assertTrue(lockup.wasCanceled(defaultStreamId));
    }
}
