// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Solarray } from "solarray/src/Solarray.sol";

import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract RenounceMultiple_Integration_Concrete_Test is Integration_Test {
    // An array of stream IDs to be renounces.
    uint256[] internal ids;

    function setUp() public virtual override {
        Integration_Test.setUp();

        // Create test streams.
        ids.push(streamIds.defaultStream);
        ids.push(createDefaultStream());
    }

    function test_RevertWhen_DelegateCall() external {
        expectRevert_DelegateCall({ callData: abi.encodeCall(lockup.renounceMultiple, ids) });
    }

    function test_WhenZeroArrayLength() external whenNoDelegateCall {
        // It should do nothing.
        uint256[] memory nullIds = new uint256[](0);
        lockup.renounceMultiple(nullIds);
    }

    function test_RevertGiven_AtLeastOneNullStream() external whenNoDelegateCall whenNonZeroArrayLength {
        expectRevert_Null({
            callData: abi.encodeCall(lockup.renounceMultiple, Solarray.uint256s(ids[0], streamIds.nullStream))
        });
    }

    function test_RevertGiven_AtLeastOneColdStream()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
    {
        uint40 earlyEndTime = defaults.END_TIME() - 10;
        uint256 earlyEndtimeStream = createDefaultStreamWithEndTime(earlyEndTime);
        vm.warp({ newTimestamp: earlyEndTime + 1 seconds });

        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockupBase_StreamSettled.selector, earlyEndtimeStream));
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(ids[0], earlyEndtimeStream) });
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
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockupBase_Unauthorized.selector, ids[0], users.recipient));
        lockup.renounceMultiple(ids);
    }

    function test_RevertGiven_AtLeastOneNonCancelableStream()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
        givenNoColdStreams
        whenCallerAuthorizedForAllStreams
    {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamNotCancelable.selector, streamIds.notCancelableStream)
        );
        lockup.renounceMultiple({ streamIds: Solarray.uint256s(ids[0], streamIds.notCancelableStream) });
    }

    function test_GivenAllStreamsCancelable()
        external
        whenNoDelegateCall
        whenNonZeroArrayLength
        givenNoNullStreams
        givenNoColdStreams
        whenCallerAuthorizedForAllStreams
    {
        // It should emit {RenounceLockupStream} events for both streams.
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.RenounceLockupStream(ids[0]);
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.RenounceLockupStream(ids[1]);

        // Renounce the streams.
        lockup.renounceMultiple(ids);

        // It should make streams non cancelable.
        assertFalse(lockup.isCancelable(ids[0]), "isCancelable0");
        assertFalse(lockup.isCancelable(ids[1]), "isCancelable1");
    }
}
