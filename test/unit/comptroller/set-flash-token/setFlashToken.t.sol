// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { IAdminable } from "@prb/contracts/access/IAdminable.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { ComptrollerTest } from "../ComptrollerTest.t.sol";

contract SetFlashToken_ComptrollerTest is ComptrollerTest {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotAdmin(address eve) external {
        vm.assume(eve != users.admin);

        // Make Eve the caller in this test.
        changePrank(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IAdminable.Adminable_CallerNotAdmin.selector, users.admin, eve));
        comptroller.setFlashToken(dai);
    }

    modifier callerAdmin() {
        // Make the admin the caller in the rest of this test suite.
        changePrank(users.admin);
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TokenFlashLoanable() external callerAdmin {
        // Make the dai token flash loanable.
        comptroller.setFlashToken(dai);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Comptroller_TokenFlashLoanable.selector, dai));
        comptroller.setFlashToken(dai);
    }

    modifier tokenNotFlashLoanable() {
        _;
    }

    /// @dev it should set the token flash loanable.
    function test_SetFlashToken() external callerAdmin tokenNotFlashLoanable {
        comptroller.setFlashToken(dai);
        bool isFlashLoanable = comptroller.isFlashLoanable(dai);
        assertTrue(isFlashLoanable);
    }

    /// @dev it should emit a SetFlashToken event.
    function test_SetFlashToken_Event() external callerAdmin tokenNotFlashLoanable {
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.SetFlashToken(users.admin, dai);
        comptroller.setFlashToken(dai);
    }
}
