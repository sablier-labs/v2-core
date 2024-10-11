// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Solarray } from "solarray/src/Solarray.sol";

import { ISablierLockup } from "src/core/interfaces/ISablierLockup.sol";
import { Errors } from "src/core/libraries/Errors.sol";
import { Integration_Test } from "../../../Integration.t.sol";
import { RenounceMultiple_Integration_Shared_Test } from "../../../shared/lockup/renounceMultiple.t.sol";

abstract contract RenounceMultiple_Integration_Concrete_Test is
    Integration_Test,
    RenounceMultiple_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, RenounceMultiple_Integration_Shared_Test) {
        RenounceMultiple_Integration_Shared_Test.setUp();
    }

    function test_RevertWhen_DelegateCall() external {
        bytes memory callData = abi.encodeCall(ISablierLockup.renounceMultiple, (testStreamIds));
        (bool success, bytes memory returnData) = address(lockup).delegatecall(callData);
        expectRevertDueToDelegateCall(success, returnData);
    }

    modifier whenNoDelegateCall() {
        _;
    }

    function test_WhenZeroArrayLength() external whenNoDelegateCall {
        // It should do nothing.
        uint256[] memory streamIds = new uint256[](0);
        lockup.renounceMultiple(streamIds);
    }

    modifier whenNonZeroArrayLength() {
        _;
    }

    function test_RevertGiven_AtleastOneNullStream() external whenNoDelegateCall whenNonZeroArrayLength {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], nullStreamId) });
    }

    modifier givenNoNullStreams() {
        _;
    }

    function test_RevertGiven_AtleastOneColdStream()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
    {
        uint256 earlyStreamId = createDefaultStreamWithEndTime({ endTime: defaults.CLIFF_TIME() + 1 seconds });
        vm.warp({ newTimestamp: defaults.CLIFF_TIME() + 1 seconds });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_StreamSettled.selector, earlyStreamId));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], earlyStreamId) });
    }

    modifier givenNoColdStreams() {
        _;
    }

    function test_RevertWhen_CallerUnauthorizedForAny()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
        givenNoColdStreams
    {
        // Make the Recipient the caller in this test.
        resetPrank({ msgSender: users.recipient });

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_Unauthorized.selector, testStreamIds[0], users.recipient)
        );
        lockup.renounceMultiple(testStreamIds);
    }

    modifier whenCallerAuthorizedForAll() {
        _;
    }

    function test_RevertGiven_AtleastOneNonCancelableStream()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
        givenNoColdStreams
        whenCallerAuthorizedForAll
    {
        uint256 notCancelableStreamId = createDefaultStreamNotCancelable();
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_StreamNotCancelable.selector, notCancelableStreamId)
        );
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(testStreamIds[0], notCancelableStreamId) });
    }

    function test_GivenCancelableStreams()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
        givenNoColdStreams
        whenCallerAuthorizedForAll
    {
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
