// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";
import { Lockup, LockupDynamic, LockupLinear, LockupTranched } from "src/core/types/DataTypes.sol";

import { Base_Test } from "../../Base.t.sol";
import {
    RecipientInterfaceIDIncorrect,
    RecipientInterfaceIDMissing,
    RecipientInvalidSelector,
    RecipientReentrant,
    RecipientReverting
} from "../../mocks/Hooks.sol";

/// @notice Common logic needed by all integration tests, both concrete and fuzz tests.
abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Lockup.Model internal lockupModel;

    // Common stream IDs to be used across the tests.
    // Default stream ID.
    uint256 internal defaultStreamId;
    // A non-cancelable stream ID.
    uint256 internal notCancelableStreamId;
    // A non-transferable stream ID.
    uint256 internal notTransferableStreamId;
    // A stream ID that does not exist.
    uint256 internal nullStreamId = 1729;
    // A stream with a recipient contract that implements {ISablierLockupRecipient}.
    uint256 internal recipientGoodStreamId;
    // A stream with a recipient contract that returns invalid selector bytes on the hook call.
    uint256 internal recipientInvalidSelectorStreamId;
    // A stream with a reentrant contract as the recipient.
    uint256 internal recipientReentrantStreamId;
    // Astream with a reverting contract as the stream's recipient.
    uint256 internal recipientRevertStreamId;

    struct CreateParams {
        Lockup.CreateWithTimestamps createWithTimestamps;
        Lockup.CreateWithDurations createWithDurations;
        uint40 cliffTime;
        LockupLinear.UnlockAmounts unlockAmounts;
        LockupLinear.Durations durations;
        LockupDynamic.Segment[] segments;
        LockupDynamic.SegmentWithDuration[] segmentsWithDurations;
        LockupTranched.Tranche[] tranches;
        LockupTranched.TrancheWithDuration[] tranchesWithDurations;
    }

    CreateParams internal _defaultParams;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    RecipientInterfaceIDIncorrect internal recipientInterfaceIDIncorrect;
    RecipientInterfaceIDMissing internal recipientInterfaceIDMissing;
    RecipientInvalidSelector internal recipientInvalidSelector;
    RecipientReentrant internal recipientReentrant;
    RecipientReverting internal recipientReverting;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        recipientInterfaceIDIncorrect = new RecipientInterfaceIDIncorrect();
        recipientInterfaceIDMissing = new RecipientInterfaceIDMissing();
        recipientInvalidSelector = new RecipientInvalidSelector();
        recipientReentrant = new RecipientReentrant();
        // We need to fund with ETH the reentrant contract as the withdraw function is payable.
        vm.deal({ account: address(recipientReentrant), newBalance: 100 ether });
        recipientReverting = new RecipientReverting();
        vm.label({ account: address(recipientInterfaceIDIncorrect), newLabel: "Recipient Interface ID Incorrect" });
        vm.label({ account: address(recipientInterfaceIDMissing), newLabel: "Recipient Interface ID Missing" });
        vm.label({ account: address(recipientInvalidSelector), newLabel: "Recipient Invalid Selector" });
        vm.label({ account: address(recipientReentrant), newLabel: "Recipient Reentrant" });
        vm.label({ account: address(recipientReverting), newLabel: "Recipient Reverting" });

        _defaultParams.createWithTimestamps = defaults.createWithTimestamps();
        _defaultParams.createWithDurations = defaults.createWithDurations();
        _defaultParams.cliffTime = defaults.CLIFF_TIME();
        _defaultParams.durations = defaults.durations();
        _defaultParams.unlockAmounts = defaults.unlockAmounts();

        // See https://github.com/ethereum/solidity/issues/12783
        LockupDynamic.SegmentWithDuration[] memory segmentsWithDurations = defaults.segmentsWithDurations();
        LockupDynamic.Segment[] memory segments = defaults.segments();
        for (uint256 i; i < defaults.SEGMENT_COUNT(); ++i) {
            _defaultParams.segments.push(segments[i]);
            _defaultParams.segmentsWithDurations.push(segmentsWithDurations[i]);
        }
        LockupTranched.TrancheWithDuration[] memory tranchesWithDurations = defaults.tranchesWithDurations();
        LockupTranched.Tranche[] memory tranches = defaults.tranches();
        for (uint256 i; i < defaults.TRANCHE_COUNT(); ++i) {
            _defaultParams.tranches.push(tranches[i]);
            _defaultParams.tranchesWithDurations.push(tranchesWithDurations[i]);
        }

        // Set the default Lockup model as Dynamic, we will override the default stream IDs where necessary.
        lockupModel = Lockup.Model.LOCKUP_DYNAMIC;

        // Initialize default streams IDs.
        initializeDefaultStreamIds();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE-DEFAULT
    //////////////////////////////////////////////////////////////////////////*/

    function createDefaultStream(Lockup.CreateWithTimestamps memory params) internal returns (uint256 streamId) {
        if (lockupModel == Lockup.Model.LOCKUP_DYNAMIC) {
            streamId = createWithTimestampsLD(params, _defaultParams.segments);
        } else if (lockupModel == Lockup.Model.LOCKUP_LINEAR) {
            streamId = createWithTimestampsLL(params, _defaultParams.unlockAmounts, _defaultParams.cliffTime);
        } else if (lockupModel == Lockup.Model.LOCKUP_TRANCHED) {
            streamId = createWithTimestampsLT(params, _defaultParams.tranches);
        }
    }

    function createDefaultStream() internal returns (uint256 streamId) {
        streamId = createDefaultStream(_defaultParams.createWithTimestamps);
    }

    function createDefaultStreamNonCancelable() internal returns (uint256 streamId) {
        Lockup.CreateWithTimestamps memory params = _defaultParams.createWithTimestamps;
        params.cancelable = false;
        streamId = createDefaultStream(params);
    }

    function createDefaultStreamNonTransferable() internal returns (uint256 streamId) {
        Lockup.CreateWithTimestamps memory params = _defaultParams.createWithTimestamps;
        params.transferable = false;
        streamId = createDefaultStream(params);
    }

    function createDefaultStreamWithDurations() internal returns (uint256 streamId) {
        if (lockupModel == Lockup.Model.LOCKUP_DYNAMIC) {
            streamId = createWithDurationsLD(_defaultParams.createWithDurations, _defaultParams.segmentsWithDurations);
        } else if (lockupModel == Lockup.Model.LOCKUP_LINEAR) {
            streamId = createWithDurationsLL(
                _defaultParams.createWithDurations, _defaultParams.unlockAmounts, _defaultParams.durations
            );
        } else if (lockupModel == Lockup.Model.LOCKUP_TRANCHED) {
            streamId = createWithDurationsLT(_defaultParams.createWithDurations, _defaultParams.tranchesWithDurations);
        }
    }

    function createDefaultStreamWithEndTime(uint40 endTime) internal returns (uint256 streamId) {
        Lockup.CreateWithTimestamps memory params = _defaultParams.createWithTimestamps;
        params.timestamps.end = endTime;
        if (lockupModel == Lockup.Model.LOCKUP_DYNAMIC) {
            LockupDynamic.Segment[] memory segments = _defaultParams.segments;
            segments[1].timestamp = endTime;
            streamId = createWithTimestampsLD(params, segments);
        } else if (lockupModel == Lockup.Model.LOCKUP_LINEAR) {
            streamId = createWithTimestampsLL(params, _defaultParams.unlockAmounts, defaults.CLIFF_TIME());
        } else if (lockupModel == Lockup.Model.LOCKUP_TRANCHED) {
            LockupTranched.Tranche[] memory tranches = _defaultParams.tranches;
            tranches[1].timestamp = endTime;
            streamId = createWithTimestampsLT(params, tranches);
        }
    }

    function createDefaultStreamWithRecipient(address recipient) internal returns (uint256 streamId) {
        streamId = createDefaultStreamWithUsers(recipient, users.sender);
    }

    function createDefaultStreamWithUsers(address recipient, address sender) internal returns (uint256 streamId) {
        Lockup.CreateWithTimestamps memory params = _defaultParams.createWithTimestamps;
        params.recipient = recipient;
        params.sender = sender;
        streamId = createDefaultStream(params);
    }

    function initializeDefaultStreamIds() internal {
        defaultStreamId = createDefaultStream();
        notCancelableStreamId = createDefaultStreamNonCancelable();
        notTransferableStreamId = createDefaultStreamNonTransferable();
        recipientGoodStreamId = createDefaultStreamWithRecipient(address(recipientGood));
        recipientInvalidSelectorStreamId = createDefaultStreamWithRecipient(address(recipientInvalidSelector));
        recipientReentrantStreamId = createDefaultStreamWithRecipient(address(recipientReentrant));
        recipientRevertStreamId = createDefaultStreamWithRecipient(address(recipientReverting));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                COMMON-REVERT-TESTS
    //////////////////////////////////////////////////////////////////////////*/

    function expectRevert_CallerMaliciousThirdParty(bytes memory callData) internal {
        resetPrank({ msgSender: users.eve });
        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "malicious call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.SablierLockupBase_Unauthorized.selector, defaultStreamId, users.eve),
            "malicious call return data"
        );
    }

    function expectRevert_CallerNotAdmin(bytes memory callData) internal {
        resetPrank({ msgSender: users.eve });
        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "caller not admin call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin, users.eve),
            "caller not admin call return data"
        );
    }

    function expectRevert_CANCELEDStatus(bytes memory callData) internal {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        lockup.cancel(defaultStreamId);

        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "canceled status call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamCanceled.selector, defaultStreamId),
            "canceled status call return data"
        );
    }

    function expectRevert_DelegateCall(bytes memory callData) internal {
        (bool success, bytes memory returnData) = address(lockup).delegatecall(callData);
        assertFalse(success, "delegatecall success");
        assertEq(returnData, abi.encodeWithSelector(Errors.DelegateCall.selector), "delegatecall return data");
    }

    function expectRevert_DEPLETEDStatus(bytes memory callData) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() });
        lockup.withdrawMax{ value: SABLIER_FEE }({ streamId: defaultStreamId, to: users.recipient });

        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "depleted status call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamDepleted.selector, defaultStreamId),
            "depleted status call return data"
        );
    }

    function expectRevert_Null(bytes memory callData) internal {
        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "null call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.SablierLockupBase_Null.selector, nullStreamId),
            "null call return data"
        );
    }

    function expectRevert_SETTLEDStatus(bytes memory callData) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() });

        (bool success, bytes memory returnData) = address(lockup).call(callData);
        assertFalse(success, "settled status call success");
        assertEq(
            returnData,
            abi.encodeWithSelector(Errors.SablierLockupBase_StreamSettled.selector, defaultStreamId),
            "settled status call return data"
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  MIRROR-FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function burn(uint256 streamId) internal {
        lockup.burn{ value: 0 }(streamId);
    }

    function cancel(uint256 streamId) internal {
        lockup.cancel{ value: 0 }(streamId);
    }

    function cancelMultiple(uint256[] memory streamIds) internal {
        lockup.cancelMultiple{ value: 0 }(streamIds);
    }

    function createWithDurationsLD(
        Lockup.CreateWithDurations memory params,
        LockupDynamic.SegmentWithDuration[] memory segmentsWithDuration
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithDurationsLD{ value: 0 }(params, segmentsWithDuration);
    }

    function createWithDurationsLL(
        Lockup.CreateWithDurations memory params,
        LockupLinear.UnlockAmounts memory unlockAmounts,
        LockupLinear.Durations memory durations
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithDurationsLL{ value: 0 }(params, unlockAmounts, durations);
    }

    function createWithDurationsLT(
        Lockup.CreateWithDurations memory params,
        LockupTranched.TrancheWithDuration[] memory tranchesWithDuration
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithDurationsLT{ value: 0 }(params, tranchesWithDuration);
    }

    function createWithTimestampsLD(
        Lockup.CreateWithTimestamps memory params,
        LockupDynamic.Segment[] memory segments
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithTimestampsLD{ value: 0 }(params, segments);
    }

    function createWithTimestampsLL(
        Lockup.CreateWithTimestamps memory params,
        LockupLinear.UnlockAmounts memory unlockAmounts,
        uint40 cliffTime
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithTimestampsLL{ value: 0 }(params, unlockAmounts, cliffTime);
    }

    function createWithTimestampsLT(
        Lockup.CreateWithTimestamps memory params,
        LockupTranched.Tranche[] memory tranches
    )
        internal
        returns (uint256 streamId)
    {
        streamId = lockup.createWithTimestampsLT{ value: 0 }(params, tranches);
    }

    function renounce(uint256 streamId) internal {
        lockup.renounce{ value: 0 }(streamId);
    }

    modifier balanceTest() {
        uint256 balanceBefore = address(lockup).balance;
        _;
        assertEq(address(lockup).balance, balanceBefore + SABLIER_FEE, "balance after function call");
    }

    function withdraw(uint256 streamId, address to, uint128 amount) internal {
        lockup.withdraw{ value: SABLIER_FEE }(streamId, to, amount);
    }

    function withdrawWithBalTest(uint256 streamId, address to, uint128 amount) internal balanceTest {
        withdraw(streamId, to, amount);
    }

    function withdrawMax(uint256 streamId, address to) internal returns (uint128) {
        return lockup.withdrawMax{ value: SABLIER_FEE }(streamId, to);
    }

    function withdrawMaxWithBalTest(uint256 streamId, address to) internal balanceTest returns (uint128) {
        uint128 withdrawn = withdrawMax(streamId, to);
        return withdrawn;
    }

    function withdrawMaxAndTransfer(uint256 streamId, address newRecipient) internal returns (uint128) {
        return lockup.withdrawMaxAndTransfer{ value: SABLIER_FEE }(streamId, newRecipient);
    }

    function withdrawMaxAndTransferWithBalTest(
        uint256 streamId,
        address newRecipient
    )
        internal
        balanceTest
        returns (uint128)
    {
        uint128 withdrawn = withdrawMaxAndTransfer(streamId, newRecipient);
        return withdrawn;
    }

    function withdrawMultiple(uint256[] memory streamIds, uint128[] memory amounts) internal {
        lockup.withdrawMultiple{ value: SABLIER_FEE }(streamIds, amounts);
    }

    function withdrawMultipleWithBalTest(uint256[] memory streamIds, uint128[] memory amounts) internal balanceTest {
        withdrawMultiple(streamIds, amounts);
    }
}
