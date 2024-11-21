// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Solarray } from "solarray/src/Solarray.sol";
import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { Errors } from "src/libraries/Errors.sol";
import { Lockup } from "src/types/DataTypes.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract WithdrawFees_Integration_Concrete_Test is Integration_Test {
    function test_WhenAdminIsNotContract() external {
        _test_WithdrawFees(users.admin);
    }

    function test_RevertWhen_AdminDoesNotImplementReceiveFunction() external whenAdminIsContract {
        // Transfer the admin to a contract that does not implement the receive function.
        resetPrank({ msgSender: users.admin });
        lockup.transferAdmin(address(contractWithoutReceive));

        // Make the contract the caller.
        resetPrank({ msgSender: address(contractWithoutReceive) });

        // Expect a revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupBase_FeeTransferFail.selector,
                address(contractWithoutReceive),
                address(lockup).balance
            )
        );

        // Withdraw the fees.
        lockup.withdrawFees();
    }

    function test_WhenAdminImplementsReceiveFunction() external whenAdminIsContract {
        // Transfer the admin to a contract that implements the receive function.
        resetPrank({ msgSender: users.admin });
        lockup.transferAdmin(address(contractWithReceive));

        // Make the contract the caller.
        resetPrank({ msgSender: address(contractWithReceive) });

        // Run the tests.
        _test_WithdrawFees(address(contractWithReceive));
    }

    function _test_WithdrawFees(address admin) private {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        // Load the initial ETH balance of the admin.
        uint256 initialAdminBalance = admin.balance;

        // Make Alice the caller.
        resetPrank({ msgSender: users.alice });

        // Make a withdrawal and pay the fee.
        lockup.withdrawMax{ value: FEE }({ streamId: defaultStreamId, to: users.recipient });

        // It should emit {WithdrawFees} event.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.WithdrawFees({ admin: admin, feeAmount: FEE });

        lockup.withdrawFees();

        // It should transfer the fee.
        assertEq(admin.balance, initialAdminBalance + FEE, "admin ETH balance");

        // It should decrease contract balance to zero.
        assertEq(address(lockup).balance, 0, "lockup ETH balance");
    }
}
