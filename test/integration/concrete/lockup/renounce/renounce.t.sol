// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupRecipient } from "src/interfaces/hooks/ISablierV2LockupRecipient.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Integration_Test } from "../../../Integration.t.sol";

abstract contract Renounce_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        defaultStreamId = createDefaultStream();
    }

    function test_RevertWhen_DelegateCalled() external givenStreamWarm {
        bytes memory callData = abi.encodeCall(ISablierV2Lockup.renounce, defaultStreamId);
        (bool success, bytes memory returnData) = address(lockup).delegatecall(callData);
        expectRevertDueToDelegateCall(success, returnData);
    }

    modifier givenNotDelegateCalled() {
        _;
    }

    function test_RevertWhen_Null() external givenNotDelegateCalled {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_Null.selector, nullStreamId));
        lockup.renounce(nullStreamId);
    }

    modifier givenNotNull() {
        _;
    }

    modifier givenStreamCold() {
        _;
    }

    function test_RevertWhen_StreamCold_StatusDepleted() external givenNotDelegateCalled givenStreamCold {
        vm.warp({ timestamp: defaults.END_TIME() });
        lockup.withdrawMax({ streamId: defaultStreamId, to: users.recipient });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamDepleted.selector, defaultStreamId));
        lockup.renounce(defaultStreamId);
    }

    function test_RevertWhen_StreamCold_StatusCanceled() external givenNotDelegateCalled givenStreamCold {
        vm.warp({ timestamp: defaults.CLIFF_TIME() });
        lockup.cancel(defaultStreamId);
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamCanceled.selector, defaultStreamId));
        lockup.renounce(defaultStreamId);
    }

    function test_RevertWhen_StreamCold_StatusSettled() external givenNotDelegateCalled givenStreamCold {
        vm.warp({ timestamp: defaults.END_TIME() });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamSettled.selector, defaultStreamId));
        lockup.renounce(defaultStreamId);
    }

    /// @dev This modifier runs the test twice: once with a "PENDING" status, and once with a "STREAMING" status.
    modifier givenStreamWarm() {
        vm.warp({ timestamp: getBlockTimestamp() - 1 seconds });
        _;
        vm.warp({ timestamp: defaults.START_TIME() });
        defaultStreamId = createDefaultStream();
        _;
    }

    function test_RevertWhen_CallerNotSender() external givenNotDelegateCalled givenStreamWarm {
        // Make Eve the caller in this test.
        changePrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2Lockup_Unauthorized.selector, defaultStreamId, users.eve)
        );
        lockup.renounce(defaultStreamId);
    }

    modifier givenCallerSender() {
        _;
    }

    function test_RevertWhen_StreamNotCancelable() external givenNotDelegateCalled givenStreamWarm givenCallerSender {
        // Create the not cancelable stream.
        uint256 notCancelableStreamId = createDefaultStreamNotCancelable();

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2Lockup_StreamNotCancelable.selector, notCancelableStreamId)
        );
        lockup.renounce(notCancelableStreamId);
    }

    modifier givenStreamCancelable() {
        _;
    }

    function test_Renounce_RecipientNotContract()
        external
        givenNotDelegateCalled
        givenStreamWarm
        givenCallerSender
        givenStreamCancelable
    {
        lockup.renounce(defaultStreamId);
        bool isCancelable = lockup.isCancelable(defaultStreamId);
        assertFalse(isCancelable, "isCancelable");
    }

    modifier givenRecipientContract() {
        _;
    }

    function test_Renounce_RecipientDoesNotImplementHook()
        external
        givenNotDelegateCalled
        givenStreamWarm
        givenCallerSender
        givenStreamCancelable
        givenRecipientContract
    {
        // Create the stream with a no-op contract as the stream's recipient.
        uint256 streamId = createDefaultStreamWithRecipient(address(noop));

        // Expect a call to the hook.
        vm.expectCall(address(noop), abi.encodeCall(ISablierV2LockupRecipient.onStreamRenounced, (streamId)));

        // Renounce the stream.
        lockup.renounce(streamId);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamId);
        assertFalse(isCancelable, "isCancelable");
    }

    modifier givenRecipientImplementsHook() {
        _;
    }

    function test_Renounce_RecipientReverts()
        external
        givenNotDelegateCalled
        givenStreamWarm
        givenCallerSender
        givenStreamCancelable
        givenRecipientContract
        givenRecipientImplementsHook
    {
        // Create the stream with a reverting contract as the stream's recipient.
        uint256 streamId = createDefaultStreamWithRecipient(address(revertingRecipient));

        // Expect a call to the hook.
        vm.expectCall(
            address(revertingRecipient), abi.encodeCall(ISablierV2LockupRecipient.onStreamRenounced, (streamId))
        );

        // Renounce the stream.
        lockup.renounce(streamId);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamId);
        assertFalse(isCancelable, "isCancelable");
    }

    modifier givenRecipientDoesNotRevert() {
        _;
    }

    function test_Renounce_RecipientReentrancy()
        external
        givenNotDelegateCalled
        givenStreamWarm
        givenCallerSender
        givenStreamCancelable
        givenRecipientContract
        givenRecipientImplementsHook
        givenRecipientDoesNotRevert
    {
        // Create the stream with a reentrant contract as the stream's recipient.
        uint256 streamId = createDefaultStreamWithRecipient(address(reentrantRecipient));

        // Expect a call to the hook.
        vm.expectCall(
            address(reentrantRecipient), abi.encodeCall(ISablierV2LockupRecipient.onStreamRenounced, (streamId))
        );

        // Renounce the stream.
        lockup.renounce(streamId);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamId);
        assertFalse(isCancelable, "isCancelable");
    }

    modifier givenNoRecipientReentrancy() {
        _;
    }

    function test_Renounce()
        external
        givenNotDelegateCalled
        givenStreamWarm
        givenCallerSender
        givenStreamCancelable
        givenRecipientContract
        givenRecipientImplementsHook
        givenRecipientDoesNotRevert
        givenNoRecipientReentrancy
    {
        // Create the stream with a contract as the stream's recipient.
        uint256 streamId = createDefaultStreamWithRecipient(address(goodRecipient));

        // Expect a call to the hook.
        vm.expectCall(address(goodRecipient), abi.encodeCall(ISablierV2LockupRecipient.onStreamRenounced, (streamId)));

        // Expect the relevant events to be emitted.
        vm.expectEmit({ emitter: address(lockup) });
        emit RenounceLockupStream(streamId);
        vm.expectEmit({ emitter: address(lockup) });
        emit MetadataUpdate({ _tokenId: streamId });

        // Renounce the stream.
        lockup.renounce(streamId);

        // Assert that the stream is not cancelable anymore.
        bool isCancelable = lockup.isCancelable(streamId);
        assertFalse(isCancelable, "isCancelable");
    }
}
