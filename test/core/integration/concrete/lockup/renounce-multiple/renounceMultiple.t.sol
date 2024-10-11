// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Solarray } from "solarray/src/Solarray.sol";

import { ISablierLockup } from "src/core/interfaces/ISablierLockup.sol";
import { Errors } from "src/core/libraries/Errors.sol";
import { Integration_Test } from "../../../Integration.t.sol";
import { RenounceMultiple_Integration_Shared_Test } from "../../../shared/lockup/renounceMultiple.t.sol";
import { console2 } from "forge-std/src/console2.sol";

abstract contract RenounceMultiple_Integration_Concrete_Test is
    Integration_Test,
    RenounceMultiple_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, RenounceMultiple_Integration_Shared_Test) {
        RenounceMultiple_Integration_Shared_Test.setUp();
    }

    function test_RenounceMultiple_RevertWhen_DelegateCalled() external whenNotDelegateCalled {
        bytes memory callData = abi.encodeCall(ISablierLockup.renounceMultiple, (testStreamIds));
        (bool success, bytes memory returnData) = address(lockup).delegatecall(callData);
        expectRevertDueToDelegateCall(success, returnData);
    }

    function test_RenounceMultiple_ArrayCountZero() external whenNotDelegateCalled {
        uint256[] memory streamIds = new uint256[](0);
        lockup.renounceMultiple(streamIds);
    }

    function test_RevertGiven_OnlyNull() external whenNotDelegateCalled whenArrayCountNotZero {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(nullStreamId) });
    }

    function test_RevertGiven_SomeNull() external whenNotDelegateCalled whenArrayCountNotZero {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], nullStreamId) });
    }

    function test_RevertGiven_AllStreamsCold() external whenNotDelegateCalled whenArrayCountNotZero givenNoNull {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_StreamSettled.selector, testStreamIds[0]));
        lockup.renounceMultiple({ streamIds: testStreamIds });
    }

    function test_RevertGiven_SomeStreamsCold() external whenNotDelegateCalled whenArrayCountNotZero givenNoNull {
        uint256 earlyStreamId = createDefaultStreamWithEndTime({ endTime: defaults.CLIFF_TIME() + 1 seconds });
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() + 1 seconds });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_StreamSettled.selector, earlyStreamId));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], earlyStreamId) });
    }

    function test_RevertWhen_CallerUnauthorizedAllStreams_MaliciousThirdParty()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerUnauthorized
    {
        // Make Eve the caller in this test.
        resetPrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_Unauthorized.selector, testStreamIds[0], users.eve)
        );
        lockup.renounceMultiple(testStreamIds);
    }

    function test_RevertWhen_CallerUnauthorizedAllStreams_Recipient()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerUnauthorized
    {
        // Make the Recipient the caller in this test.
        resetPrank({ msgSender: users.recipient });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_Unauthorized.selector, testStreamIds[0], users.recipient)
        );
        lockup.renounceMultiple(testStreamIds);
    }

    function test_RevertWhen_CallerUnauthorizedSomeStreams_MaliciousThirdParty()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerUnauthorized
    {
        resetPrank({ msgSender: users.eve });

        // Create a stream with Eve as the stream's sender.
        uint256 eveStreamId = createDefaultStreamWithSender(users.eve);

        // Run the test.
        uint256[] memory streamIds = Solarray.uint256s(eveStreamId, testStreamIds[0]);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_Unauthorized.selector, testStreamIds[0], users.eve)
        );
        lockup.renounceMultiple(streamIds);
    }

    function test_RevertWhen_CallerUnauthorizedSomeStreams_Recipient()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerUnauthorized
    {
        // Make the Recipient the caller in this test.
        resetPrank({ msgSender: users.recipient });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_Unauthorized.selector, testStreamIds[0], users.recipient)
        );
        lockup.renounceMultiple(testStreamIds);
    }

    function test_RevertGiven_AllStreamsNotCancelable()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerAuthorizedAllStreams
    {
        uint256 notCancelableStreamId = createDefaultStreamNotCancelable();
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_StreamNotCancelable.selector, notCancelableStreamId)
        );
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(notCancelableStreamId) });
    }

    function test_RevertGiven_SomeStreamsNotCancelable()
        external
        whenNotDelegateCalled
        whenArrayCountNotZero
        givenNoNull
        givenAllStreamsWarm
        whenCallerAuthorizedAllStreams
    {
        uint256 notCancelableStreamId = createDefaultStreamNotCancelable();
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_StreamNotCancelable.selector, notCancelableStreamId)
        );
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], notCancelableStreamId) });
    }

    function test_RenounceMultiple()
        external
        whenNotDelegateCalled
        givenNoNull
        givenAllStreamsWarm
        whenCallerAuthorizedAllStreams
        givenAllStreamsCancelable
    {
        console2.log("===test_RenounceMultiple===");

        vm.expectEmit({ emitter: address(lockup) });
        emit RenounceLockupStream(testStreamIds[0]);
        vm.expectEmit({ emitter: address(lockup) });
        emit MetadataUpdate({ _tokenId: testStreamIds[0] });

        // Renounce the streams.
        lockup.renounceMultiple(testStreamIds);
        // Assert that the streams are not cancelable anymore.
        assertFalse(lockup.isCancelable(testStreamIds[0]), "isCancelable0");
        assertFalse(lockup.isCancelable(testStreamIds[1]), "isCancelable1");
    }
}
