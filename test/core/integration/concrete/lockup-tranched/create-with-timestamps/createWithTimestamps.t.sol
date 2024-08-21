// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { IERC721Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import { stdError } from "forge-std/src/StdError.sol";

import { ISablierLockupTranched } from "src/core/interfaces/ISablierLockupTranched.sol";
import { Errors } from "src/core/libraries/Errors.sol";
import { Broker, Lockup, LockupTranched } from "src/core/types/DataTypes.sol";

import { CreateWithTimestamps_Integration_Shared_Test } from "../../../shared/lockup/createWithTimestamps.t.sol";
import { LockupTranched_Integration_Concrete_Test } from "../LockupTranched.t.sol";

contract CreateWithTimestamps_LockupTranched_Integration_Concrete_Test is
    LockupTranched_Integration_Concrete_Test,
    CreateWithTimestamps_Integration_Shared_Test
{
    function setUp()
        public
        virtual
        override(LockupTranched_Integration_Concrete_Test, CreateWithTimestamps_Integration_Shared_Test)
    {
        LockupTranched_Integration_Concrete_Test.setUp();
        CreateWithTimestamps_Integration_Shared_Test.setUp();
    }

    function test_RevertWhen_DelegateCall() external {
        bytes memory callData =
            abi.encodeCall(ISablierLockupTranched.createWithTimestamps, defaults.createWithTimestampsLT());
        (bool success, bytes memory returnData) = address(lockupTranched).delegatecall(callData);
        expectRevertDueToDelegateCall(success, returnData);
    }

    function test_RevertWhen_SenderIsZeroAddress() external whenNoDelegateCall {
        vm.expectRevert(Errors.SablierLockup_SenderZeroAddress.selector);
        createDefaultStreamWithSender(address(0));
    }

    function test_RevertWhen_RecipientIsZeroAddress() external whenNoDelegateCall whenSenderIsNotZeroAddress {
        address recipient = address(0);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, recipient));
        createDefaultStreamWithRecipient(recipient);
    }

    function test_RevertWhen_DepositAmountIsZero()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
    {
        // It is not possible to obtain a zero deposit amount from a non-zero total amount, because the `MAX_BROKER_FEE`
        // is hard coded to 10%.
        vm.expectRevert(Errors.SablierLockup_DepositAmountZero.selector);
        uint128 totalAmount = 0;
        createDefaultStreamWithTotalAmount(totalAmount);
    }

    function test_RevertWhen_StartTimeIsZero()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
    {
        vm.expectRevert(Errors.SablierLockup_StartTimeZero.selector);
        createDefaultStreamWithStartTime(0);
    }

    function test_RevertWhen_TrancheCountIsZero()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
    {
        LockupTranched.Tranche[] memory tranches;
        vm.expectRevert(Errors.SablierLockupTranched_TrancheCountZero.selector);
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_TrancheCountIsTooHigh()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
    {
        uint256 trancheCount = defaults.MAX_TRANCHE_COUNT() + 1;
        LockupTranched.Tranche[] memory tranches = new LockupTranched.Tranche[](trancheCount);
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockupTranched_TrancheCountTooHigh.selector, trancheCount));
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_TrancheAmountsSumOverflows()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
    {
        LockupTranched.Tranche[] memory tranches = defaults.tranches();
        tranches[0].amount = MAX_UINT128;
        tranches[1].amount = 1;
        vm.expectRevert(stdError.arithmeticError);
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_StartTimeIsGreaterThanFirstTrancheTimestamp()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
    {
        // Change the timestamp of the first tranche.
        LockupTranched.Tranche[] memory tranches = defaults.tranches();
        tranches[0].timestamp = defaults.START_TIME() - 1 seconds;

        // Expect the relevant error to be thrown.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupTranched_StartTimeNotLessThanFirstTrancheTimestamp.selector,
                defaults.START_TIME(),
                tranches[0].timestamp
            )
        );

        // Create the stream.
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_StartTimeIsEqualToFirstTrancheTimestamp()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
    {
        // Change the timestamp of the first tranche.
        LockupTranched.Tranche[] memory tranches = defaults.tranches();
        tranches[0].timestamp = defaults.START_TIME();

        // Expect the relevant error to be thrown.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupTranched_StartTimeNotLessThanFirstTrancheTimestamp.selector,
                defaults.START_TIME(),
                tranches[0].timestamp
            )
        );

        // Create the stream.
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_TrancheTimestampsAreNotOrdered()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
    {
        // Swap the tranche timestamps.
        LockupTranched.Tranche[] memory tranches = defaults.tranches();
        (tranches[0].timestamp, tranches[1].timestamp) = (tranches[1].timestamp, tranches[0].timestamp);

        // Expect the relevant error to be thrown.
        uint256 index = 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupTranched_TrancheTimestampsNotOrdered.selector,
                index,
                tranches[0].timestamp,
                tranches[1].timestamp
            )
        );

        // Create the stream.
        createDefaultStreamWithTranches(tranches);
    }

    function test_RevertWhen_DepositAmountNotEqualTrancheAmountsSum()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
        whenTrancheTimestampsAreOrdered
    {
        resetPrank({ msgSender: users.sender });

        // Adjust the default deposit amount.
        uint128 defaultDepositAmount = defaults.DEPOSIT_AMOUNT();
        uint128 depositAmount = defaultDepositAmount + 100;

        // Prepare the params.
        LockupTranched.CreateWithTimestamps memory params = defaults.createWithTimestampsBrokerNullLT();
        params.totalAmount = depositAmount;

        // Expect the relevant error to be thrown.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierLockupTranched_DepositAmountNotEqualToTrancheAmountsSum.selector,
                depositAmount,
                defaultDepositAmount
            )
        );

        // Create the stream.
        lockupTranched.createWithTimestamps(params);
    }

    function test_RevertWhen_BrokerFeeIsTooHigh()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
        whenTrancheTimestampsAreOrdered
        whenTheDepositAmountEqualsTrancheAmountsSum
    {
        UD60x18 brokerFee = MAX_BROKER_FEE + ud(1);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierLockup_BrokerFeeTooHigh.selector, brokerFee, MAX_BROKER_FEE)
        );
        createDefaultStreamWithBroker(Broker({ account: users.broker, fee: brokerFee }));
    }

    function test_RevertWhen_AssetIsNotContract()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
        whenTrancheTimestampsAreOrdered
        whenTheDepositAmountEqualsTrancheAmountsSum
        whenBrokerFeeIsNotTooHigh
    {
        address nonContract = address(8128);

        resetPrank({ msgSender: users.sender });

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Address.AddressEmptyCode.selector, nonContract));
        createDefaultStreamWithAsset(IERC20(nonContract));
    }

    function test_WhenAssetMissesERC20ReturnValue()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
        whenTrancheTimestampsAreOrdered
        whenTheDepositAmountEqualsTrancheAmountsSum
        whenBrokerFeeIsNotTooHigh
        whenAssetIsContract
    {
        testCreateWithTimestamps(address(usdt));
    }

    function test_WhenAssetDoesNotMissERC20ReturnValue()
        external
        whenNoDelegateCall
        whenSenderIsNotZeroAddress
        whenRecipientIsNotZeroAddress
        whenDepositAmountIsNotZero
        whenStartTimeIsNotZero
        whenTrancheCountIsNotZero
        whenTrancheCountIsNotTooHigh
        whenTrancheAmountsSumDoesNotOverflow
        whenStartTimeIsLessThanFirstTrancheTimestamp
        whenTrancheTimestampsAreOrdered
        whenTheDepositAmountEqualsTrancheAmountsSum
        whenBrokerFeeIsNotTooHigh
        whenAssetIsContract
    {
        testCreateWithTimestamps(address(dai));
    }

    /// @dev Shared logic between {test_CreateWithTimestamps_AssetMissingReturnValue} and {test_CreateWithTimestamps}.
    function testCreateWithTimestamps(address asset) internal {
        // Make the Sender the stream's funder.
        address funder = users.sender;

        // It should perform the ERC-20 transfers.
        expectCallToTransferFrom({
            asset: IERC20(asset),
            from: funder,
            to: address(lockupTranched),
            value: defaults.DEPOSIT_AMOUNT()
        });

        // Expect the broker fee to be paid to the broker.
        expectCallToTransferFrom({
            asset: IERC20(asset),
            from: funder,
            to: users.broker,
            value: defaults.BROKER_FEE_AMOUNT()
        });

        // It should emit {CreateLockupTranchedStream} and {MetadataUpdate} events.
        vm.expectEmit({ emitter: address(lockupTranched) });
        emit MetadataUpdate({ _tokenId: streamId });
        vm.expectEmit({ emitter: address(lockupTranched) });
        emit CreateLockupTranchedStream({
            streamId: streamId,
            funder: funder,
            sender: users.sender,
            recipient: users.recipient,
            amounts: defaults.lockupCreateAmounts(),
            tranches: defaults.tranches(),
            asset: IERC20(asset),
            cancelable: true,
            transferable: true,
            timestamps: defaults.lockupTranchedTimestamps(),
            broker: users.broker
        });

        // It should create the stream.
        streamId = createDefaultStreamWithAsset(IERC20(asset));

        // Assert that the stream has been created.
        LockupTranched.StreamLT memory actualStream = lockupTranched.getStream(streamId);
        LockupTranched.StreamLT memory expectedStream = defaults.lockupTranchedStream();
        expectedStream.asset = IERC20(asset);
        assertEq(actualStream, expectedStream);

        // Assert that the stream's status is "PENDING".
        Lockup.Status actualStatus = lockupTranched.statusOf(streamId);
        Lockup.Status expectedStatus = Lockup.Status.PENDING;
        assertEq(actualStatus, expectedStatus);

        // It should bump the next stream ID.
        uint256 actualNextStreamId = lockupTranched.nextStreamId();
        uint256 expectedNextStreamId = streamId + 1;
        assertEq(actualNextStreamId, expectedNextStreamId, "nextStreamId");

        // It should mint the NFT.
        address actualNFTOwner = lockupTranched.ownerOf({ tokenId: streamId });
        address expectedNFTOwner = users.recipient;
        assertEq(actualNFTOwner, expectedNFTOwner, "NFT owner");
    }
}
