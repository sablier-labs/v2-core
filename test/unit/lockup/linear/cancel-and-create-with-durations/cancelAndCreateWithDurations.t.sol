// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Events } from "src/libraries/Events.sol";
import { Lockup, LockupLinear } from "src/types/DataTypes.sol";

import { Linear_Unit_Test } from "../Linear.t.sol";

contract CancelAndCreateWithDurations_Test is Linear_Unit_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        Linear_Unit_Test.setUp();

        // Create the default stream.
        defaultStreamId = createDefaultStream();
    }

    struct Vars {
        uint256 actualNextStreamId;
        address actualNFTOwner;
        Lockup.Status actualStatus;
        uint256 actualWithdrawnAmount;
        uint256 expectedNextStreamId;
        address expectedNFTOwner;
        Lockup.Status expectedStatus;
        uint256 expectedWithdrawnAmount;
        address funder;
        uint256 newStreamId;
        uint128 recipientAmount;
        uint128 senderAmount;
    }

    /// @dev it should cancel the stream and create a new one.
    function test_CancelAndCreateWithDurations() external {
        // Make the sender the funder of the stream.
        Vars memory vars;
        vars.funder = users.sender;

        /*//////////////////////////////////////////////////////////////////////////
                                        ERC-20 CALLS
        //////////////////////////////////////////////////////////////////////////*/

        // Expect the ERC-20 assets to be returned to the sender.
        vars.senderAmount = linear.returnableAmountOf(defaultStreamId);
        vm.expectCall(address(DEFAULT_ASSET), abi.encodeCall(IERC20.transfer, (users.sender, vars.senderAmount)));

        // No ERC-20 assets are withdrawn to the recipient because the streaming has not started yet.
        vars.recipientAmount = 0;

        // Expect the ERC-20 assets to be transferred from the funder to the {SablierV2LockupLinear} contract.
        vm.expectCall(
            address(DEFAULT_ASSET),
            abi.encodeCall(
                IERC20.transferFrom,
                (vars.funder, address(linear), DEFAULT_DEPOSIT_AMOUNT + DEFAULT_PROTOCOL_FEE_AMOUNT)
            )
        );

        // Expect the broker fee to be paid to the broker.
        vm.expectCall(
            address(DEFAULT_ASSET),
            abi.encodeCall(IERC20.transferFrom, (vars.funder, users.broker, DEFAULT_BROKER_FEE_AMOUNT))
        );

        /*//////////////////////////////////////////////////////////////////////////
                                          EVENTS
        //////////////////////////////////////////////////////////////////////////*/

        // Expect a {CancelLockupStream} event to be emitted.
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.CancelLockupStream(
            defaultStreamId,
            users.sender,
            users.recipient,
            vars.senderAmount,
            vars.recipientAmount
        );

        // Expect a {CreateLockupLinearStream} event to be emitted.
        vars.newStreamId = linear.nextStreamId();
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.CreateLockupLinearStream({
            streamId: vars.newStreamId,
            funder: vars.funder,
            sender: users.sender,
            recipient: users.recipient,
            amounts: Lockup.CreateAmounts({
                deposit: DEFAULT_DEPOSIT_AMOUNT,
                protocolFee: DEFAULT_PROTOCOL_FEE_AMOUNT,
                brokerFee: DEFAULT_BROKER_FEE_AMOUNT
            }),
            asset: DEFAULT_ASSET,
            cancelable: true,
            range: DEFAULT_LINEAR_RANGE,
            broker: users.broker
        });

        /*//////////////////////////////////////////////////////////////////////////
                                          ACTION
        //////////////////////////////////////////////////////////////////////////*/

        // Cancel the default stream and create a new one.
        linear.cancelAndCreateWithDurations(defaultStreamId, defaultParams.createWithDurations);

        /*//////////////////////////////////////////////////////////////////////////
                                DEFAULT STREAM ASSERTIONS
        //////////////////////////////////////////////////////////////////////////*/

        // Assert that the default stream has been canceled.
        vars.actualStatus = linear.getStatus(defaultStreamId);
        vars.expectedStatus = Lockup.Status.CANCELED;
        assertEq(vars.actualStatus, vars.expectedStatus);

        // Assert that the withdrawn amount has been updated for the default stream.
        vars.actualWithdrawnAmount = linear.getWithdrawnAmount(defaultStreamId);
        vars.expectedWithdrawnAmount = vars.recipientAmount;
        assertEq(vars.actualWithdrawnAmount, vars.expectedWithdrawnAmount, "withdrawnAmount");

        // Assert that the NFT has not been burned for the default stream.
        vars.actualNFTOwner = linear.ownerOf({ tokenId: defaultStreamId });
        vars.expectedNFTOwner = users.recipient;
        assertEq(vars.actualNFTOwner, vars.expectedNFTOwner, "NFT owner");

        /*//////////////////////////////////////////////////////////////////////////
                                  NEW STREAM ASSERTIONS
        //////////////////////////////////////////////////////////////////////////*/

        // Assert that the new stream has been created.
        LockupLinear.Stream memory actualStream = linear.getStream(vars.newStreamId);
        assertEq(actualStream.amounts, defaultStream.amounts);
        assertEq(actualStream.asset, DEFAULT_ASSET, "asset");
        assertEq(actualStream.cliffTime, defaultStream.cliffTime, "cliffTime");
        assertEq(actualStream.endTime, defaultStream.endTime, "endTime");
        assertEq(actualStream.isCancelable, defaultStream.isCancelable, "isCancelable");
        assertEq(actualStream.sender, defaultStream.sender, "sender");
        assertEq(actualStream.startTime, defaultStream.startTime, "startTime");
        assertEq(actualStream.status, defaultStream.status);

        // Assert that the next stream id has been bumped.
        vars.actualNextStreamId = linear.nextStreamId();
        vars.expectedNextStreamId = vars.newStreamId + 1;
        assertEq(vars.actualNextStreamId, vars.expectedNextStreamId, "nextStreamId");

        // Assert that the NFT has been minted for the new stream.
        vars.actualNFTOwner = linear.ownerOf({ tokenId: vars.newStreamId });
        vars.expectedNFTOwner = users.recipient;
        assertEq(vars.actualNFTOwner, vars.expectedNFTOwner, "NFT owner");
    }
}
