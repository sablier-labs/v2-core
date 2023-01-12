// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IAdminable } from "@prb/contracts/access/IAdminable.sol";
import { UD60x18, ud } from "@prb/math/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { ComptrollerTest } from "../ComptrollerTest.t.sol";

contract SetFlashFee_ComptrollerTest is ComptrollerTest {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotAdmin(address eve) external {
        vm.assume(eve != users.admin);

        // Make Eve the caller in this test.
        changePrank(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IAdminable.Adminable_CallerNotAdmin.selector, users.admin, eve));
        comptroller.setFlashFee(DEFAULT_MAX_FEE);
    }

    modifier callerAdmin() {
        // Make the admin the caller in the rest of this test suite.
        changePrank(users.admin);
        _;
    }

    /// @dev it should re-set the flash fee.
    function test_SetFlashFee_SameFee() external callerAdmin {
        UD60x18 newFlashFee = ud(0);
        comptroller.setFlashFee(newFlashFee);

        UD60x18 actualFlashFee = comptroller.flashFee();
        UD60x18 expectedFlashFee = newFlashFee;
        assertEq(actualFlashFee, expectedFlashFee);
    }

    /// @dev it should set the new flash fee
    function testFuzz_SetFlashFee_DifferentFee(UD60x18 newFlashFee) external callerAdmin {
        newFlashFee = bound(newFlashFee, 1, DEFAULT_MAX_FEE);
        comptroller.setFlashFee(newFlashFee);

        UD60x18 actualFlashFee = comptroller.flashFee();
        UD60x18 expectedFlashFee = newFlashFee;
        assertEq(actualFlashFee, expectedFlashFee);
    }

    /// @dev it should emit a SetFlashFee event
    function testFuzz_SetFlashFee_Event(UD60x18 newFlashFee) external callerAdmin {
        UD60x18 oldFlashfee = comptroller.flashFee();
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.SetFlashFee(users.admin, oldFlashfee, newFlashFee);
        comptroller.setFlashFee(newFlashFee);
    }
}
