// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierLockupRecipient } from "src/interfaces/ISablierLockupRecipient.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Integration_Test } from "../../../Integration.t.sol";

abstract contract AllowToHook_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        defaultStreamId = createDefaultStream();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        // Make Eve the caller in this test.
        resetPrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin, users.eve));
        lockup.allowToHook(ISablierLockupRecipient(users.eve));
    }

    modifier whenCallerAdmin() {
        // Make the Admin the caller in the rest of this test suite.
        resetPrank({ msgSender: users.admin });
        _;
    }

    function test_RevertWhen_ProvidedAddressNoCode() external whenCallerAdmin {
        ISablierLockupRecipient eoa = ISablierLockupRecipient(vm.addr({ privateKey: 1 }));
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_AllowToHookZeroCodeSize.selector, eoa));
        lockup.allowToHook(eoa);
    }

    modifier whenProvidedAddressHasCode() {
        _;
    }

    function test_RevertWhen_ProvidedAddressDoesNotImplementInterfaceCorrectly()
        external
        whenCallerAdmin
        whenProvidedAddressHasCode
    {
        // Incorrect interface ID.
        ISablierLockupRecipient recipient = recipientInterfaceIDIncorrect;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2Lockup_AllowToHookIncorrectImplementation.selector, recipient)
        );
        lockup.allowToHook(recipient);

        // Missing interface ID.
        recipient = ISablierLockupRecipient(address(recipientInterfaceIDMissing));
        vm.expectRevert(bytes(""));
        lockup.allowToHook(recipient);
    }

    modifier whenProvidedAddressImplementsInterfaceCorrectly() {
        _;
    }

    function test_AllowToHook()
        external
        whenCallerAdmin
        whenProvidedAddressHasCode
        whenProvidedAddressImplementsInterfaceCorrectly
    {
        // Expect the relevant event to be emitted.
        vm.expectEmit({ emitter: address(lockup) });
        emit AllowToHook(users.admin, recipientGood);

        // Allow the provided address to hook.
        lockup.allowToHook(recipientGood);

        // Assert that the provided address has been put on the allowlist.
        bool isAllowedToHook = lockup.isAllowedToHook(recipientGood);
        assertTrue(isAllowedToHook, "address not put on the allowlist");
    }
}
