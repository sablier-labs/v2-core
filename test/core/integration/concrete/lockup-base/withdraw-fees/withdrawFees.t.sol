// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierLockupBase } from "src/core/interfaces/ISablierLockupBase.sol";
import { Errors } from "src/core/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract WithdrawFees_Integration_Concrete_Test is Integration_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        expectRevert_CallerNotAdmin({ callData: abi.encodeCall(lockup.withdrawFees, (users.admin)) });
    }

    function test_RevertWhen_WithdrawalAddressZero() external whenCallerAdmin {
        address payable toZero = payable(address(0));
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockupBase_WithdrawFeesToZero.selector));
        lockup.withdrawFees(toZero);
    }

    function test_WhenProvidedAddressNotContract() external whenCallerAdmin whenWithdrawalAddressNotZero {
        address payable to = payable(makeAddr({ name: "to" }));
        _test_WithdrawFees(to);
    }

    function test_RevertWhen_ProvidedAddressNotImplementReceiveEth()
        external
        whenCallerAdmin
        whenWithdrawalAddressNotZero
        whenProvidedAddressContract
    {
        address payable noReceiveEth = payable(address(contractWithoutReceiveEth));
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupBase_FeeWithdrawFailed.selector, noReceiveEth, address(lockup).balance
            )
        );
        lockup.withdrawFees(noReceiveEth);
    }

    function test_GivenNoFeesCollected()
        external
        whenCallerAdmin
        whenWithdrawalAddressNotZero
        whenProvidedAddressContract
        whenProvidedAddressImplementReceiveEth
    {
        assertEq(address(lockup).balance, 0, "lockup eth balance");
        uint256 prevBalance = users.admin.balance;

        // It should emit {WithdrawSablierFees} event.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.WithdrawSablierFees({ admin: users.admin, feeAmount: 0, to: users.admin });

        lockup.withdrawFees(users.admin);
        assertEq(address(lockup).balance, 0, "lockup eth balance");
        assertEq(users.admin.balance, prevBalance, "eth balance");
    }

    function test_GivenFeesCollected()
        external
        whenCallerAdmin
        whenWithdrawalAddressNotZero
        whenProvidedAddressContract
        whenProvidedAddressImplementReceiveEth
    {
        address payable receiveEth = payable(address(contractWithReceiveEth));
        _test_WithdrawFees(receiveEth);
    }

    function _test_WithdrawFees(address payable to) private {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Make a withdrawal from a stream to collect some fees.
        withdrawMax({ streamId: defaultStreamId, to: users.recipient });

        // It should emit {WithdrawSablierFees} event.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.WithdrawSablierFees({ admin: users.admin, feeAmount: SABLIER_FEE, to: to });

        lockup.withdrawFees(to);

        // It should set the ETH balance to 0.
        assertEq(address(lockup).balance, 0, "lockup eth balance");

        // It should transfer fee collected in ETH to the provided address.
        assertEq(to.balance, SABLIER_FEE, "eth balance");
    }
}
