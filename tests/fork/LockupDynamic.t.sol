// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Solarray } from "solarray/src/Solarray.sol";
import { ISablierLockup } from "src/interfaces/ISablierLockup.sol";
import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { Broker, Lockup, LockupDynamic } from "src/types/DataTypes.sol";
import { Fork_Test } from "./Fork.t.sol";

abstract contract Lockup_Dynamic_Fork_Test is Fork_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IERC20 forkToken, address forkTokenHolder) Fork_Test(forkToken, forkTokenHolder) { }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Fork_Test.setUp();

        // Approve {SablierLockup} to transfer the holder's tokens.
        // We use a low-level call to ignore reverts because the token can have the missing return value bug.
        (bool success,) = address(FORK_TOKEN).call(abi.encodeCall(IERC20.approve, (address(lockup), MAX_UINT256)));
        success;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    struct Params {
        address sender;
        address recipient;
        uint128 withdrawAmount;
        uint40 startTime;
        uint40 warpTimestamp;
        LockupDynamic.Segment[] segments;
        Broker broker;
    }

    struct Vars {
        // Generic vars
        address actualNFTOwner;
        uint256 actualLockupBalance;
        uint256 actualRecipientBalance;
        Lockup.Status actualStatus;
        uint256[] balances;
        address expectedNFTOwner;
        uint256 expectedLockupBalance;
        uint256 expectedRecipientBalance;
        Lockup.Status expectedStatus;
        uint256 initialLockupBalance;
        uint256 initialRecipientBalance;
        bool isCancelable;
        bool isDepleted;
        bool isSettled;
        uint256 streamId;
        Lockup.Timestamps timestamps;
        // Create vars
        uint256 actualBrokerBalance;
        uint256 actualHolderBalance;
        uint256 actualNextStreamId;
        Lockup.CreateAmounts createAmounts;
        uint256 expectedBrokerBalance;
        uint256 expectedHolderBalance;
        uint256 expectedNextStreamId;
        uint256 initialBrokerBalance;
        uint128 totalAmount;
        // Withdraw vars
        uint128 actualWithdrawnAmount;
        uint128 expectedWithdrawnAmount;
        uint256 initialLockupBalanceETH;
        uint128 withdrawableAmount;
        // Cancel vars
        uint256 actualSenderBalance;
        uint256 expectedSenderBalance;
        uint256 initialSenderBalance;
        uint128 recipientAmount;
        uint128 senderAmount;
    }

    /// @dev Checklist:
    ///
    /// - It should perform all expected ERC-20 transfers
    /// - It should create the stream
    /// - It should bump the next stream ID
    /// - It should mint the NFT
    /// - It should emit a {CreateLockupDynamicStream} event
    /// - It may make a withdrawal and pay a fee
    /// - It may update the withdrawn amounts
    /// - It may emit a {WithdrawFromLockupStream} event
    /// - It may cancel the stream
    /// - It may emit a {CancelLockupStream} event
    ///
    /// Given enough fuzz runs, all of the following scenarios will be fuzzed:
    ///
    /// - Multiple values for the funder, recipient, sender, and broker
    /// - Multiple values for the total amount
    /// - Start time in the past
    /// - Start time in the present
    /// - Start time in the future
    /// - Start time equal and not equal to the first segment timestamp
    /// - Multiple values for the broker fee, including zero
    /// - Multiple values for the withdraw amount, including zero
    /// - The whole gamut of stream statuses
    function testForkFuzz_CreateWithdrawCancel(Params memory params) external {
        checkUsers(params.sender, params.recipient, params.broker.account, address(lockup));
        vm.assume(params.segments.length != 0);
        params.broker.fee = _bound(params.broker.fee, 0, MAX_BROKER_FEE);
        params.startTime = boundUint40(params.startTime, 1, defaults.START_TIME());

        // Fuzz the segment timestamps.
        fuzzSegmentTimestamps(params.segments, params.startTime);

        // Fuzz the segment amounts and calculate the total and create amounts (deposit and broker fee).
        Vars memory vars;
        (vars.totalAmount, vars.createAmounts) = fuzzDynamicStreamAmounts({
            upperBound: uint128(initialHolderBalance),
            segments: params.segments,
            brokerFee: params.broker.fee
        });

        // Make the holder the caller.
        resetPrank(FORK_TOKEN_HOLDER);

        /*//////////////////////////////////////////////////////////////////////////
                                            CREATE
        //////////////////////////////////////////////////////////////////////////*/

        // Load the pre-create token balances.
        vars.balances =
            getTokenBalances(address(FORK_TOKEN), Solarray.addresses(address(lockup), params.broker.account));
        vars.initialLockupBalance = vars.balances[0];
        vars.initialBrokerBalance = vars.balances[1];

        vars.streamId = lockup.nextStreamId();
        vars.timestamps =
            Lockup.Timestamps({ start: params.startTime, end: params.segments[params.segments.length - 1].timestamp });

        // Expect the relevant events to be emitted.
        vm.expectEmit({ emitter: address(lockup) });
        emit IERC4906.MetadataUpdate({ _tokenId: vars.streamId });
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockup.CreateLockupDynamicStream({
            streamId: vars.streamId,
            commonParams: Lockup.CreateEventCommon({
                funder: FORK_TOKEN_HOLDER,
                sender: params.sender,
                recipient: params.recipient,
                amounts: vars.createAmounts,
                token: FORK_TOKEN,
                cancelable: true,
                transferable: true,
                timestamps: vars.timestamps,
                broker: params.broker.account,
                shape: "Dynamic Shape"
            }),
            segments: params.segments
        });

        // Create the stream.
        lockup.createWithTimestampsLD(
            Lockup.CreateWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                totalAmount: vars.totalAmount,
                token: FORK_TOKEN,
                cancelable: true,
                transferable: true,
                timestamps: vars.timestamps,
                broker: params.broker,
                shape: "Dynamic Shape"
            }),
            params.segments
        );

        // Check if the stream is settled. It is possible for a Lockup Dynamic stream to settle at the time of creation
        // because some segment amounts can be zero or the last segment timestamp can be in the past.
        vars.isSettled = lockup.refundableAmountOf(vars.streamId) == 0 || vars.timestamps.end <= getBlockTimestamp();
        vars.isCancelable = vars.isSettled ? false : true;

        // Assert that the stream has been created.
        assertEq(lockup.getToken(vars.streamId), FORK_TOKEN, "token");
        assertEq(lockup.getDepositedAmount(vars.streamId), vars.createAmounts.deposit, "depositedAmount");
        assertEq(lockup.getEndTime(vars.streamId), vars.timestamps.end, "endTime");
        assertEq(lockup.isCancelable(vars.streamId), vars.isCancelable, "isCancelable");
        assertTrue(lockup.isStream(vars.streamId), "isStream");
        assertTrue(lockup.isTransferable(vars.streamId), "isTransferable");
        assertEq(lockup.getRecipient(vars.streamId), params.recipient, "recipient");
        assertEq(lockup.getSegments(vars.streamId), params.segments);
        assertEq(lockup.getSender(vars.streamId), params.sender, "sender");
        assertEq(lockup.getStartTime(vars.streamId), params.startTime, "startTime");
        assertFalse(lockup.isDepleted(vars.streamId), "isDepleted");
        assertFalse(lockup.wasCanceled(vars.streamId), "wasCanceled");

        // Assert that the stream's status is correct.
        vars.actualStatus = lockup.statusOf(vars.streamId);
        if (params.startTime > getBlockTimestamp()) {
            vars.expectedStatus = Lockup.Status.PENDING;
        } else if (vars.isSettled) {
            vars.expectedStatus = Lockup.Status.SETTLED;
        } else {
            vars.expectedStatus = Lockup.Status.STREAMING;
        }
        assertEq(vars.actualStatus, vars.expectedStatus, "post-create stream status");

        // Assert that the next stream ID has been bumped.
        vars.actualNextStreamId = lockup.nextStreamId();
        vars.expectedNextStreamId = vars.streamId + 1;
        assertEq(vars.actualNextStreamId, vars.expectedNextStreamId, "post-create nextStreamId");

        // Assert that the NFT has been minted.
        vars.actualNFTOwner = lockup.ownerOf({ tokenId: vars.streamId });
        vars.expectedNFTOwner = params.recipient;
        assertEq(vars.actualNFTOwner, vars.expectedNFTOwner, "post-create NFT owner");

        // Load the post-create token balances.
        vars.balances = getTokenBalances(
            address(FORK_TOKEN), Solarray.addresses(address(lockup), FORK_TOKEN_HOLDER, params.broker.account)
        );
        vars.actualLockupBalance = vars.balances[0];
        vars.actualHolderBalance = vars.balances[1];
        vars.actualBrokerBalance = vars.balances[2];

        // Assert that the contract's balance has been updated.
        vars.expectedLockupBalance = vars.initialLockupBalance + vars.createAmounts.deposit;
        assertEq(vars.actualLockupBalance, vars.expectedLockupBalance, "post-create Lockup contract balance");

        // Assert that the holder's balance has been updated.
        vars.expectedHolderBalance = initialHolderBalance - vars.totalAmount;
        assertEq(vars.actualHolderBalance, vars.expectedHolderBalance, "post-create Holder balance");

        // Assert that the broker's balance has been updated.
        vars.expectedBrokerBalance = vars.initialBrokerBalance + vars.createAmounts.brokerFee;
        assertEq(vars.actualBrokerBalance, vars.expectedBrokerBalance, "post-create Broker balance");

        /*//////////////////////////////////////////////////////////////////////////
                                          WITHDRAW
        //////////////////////////////////////////////////////////////////////////*/

        // Simulate the passage of time.
        params.warpTimestamp =
            boundUint40(params.warpTimestamp, vars.timestamps.start, vars.timestamps.end + 100 seconds);
        vm.warp({ newTimestamp: params.warpTimestamp });

        // Bound the withdraw amount.
        vars.withdrawableAmount = lockup.withdrawableAmountOf(vars.streamId);
        params.withdrawAmount = boundUint128(params.withdrawAmount, 0, vars.withdrawableAmount);

        // Check if the stream has settled or will get depleted. It is possible for the stream to be just settled
        // and not depleted because the withdraw amount is fuzzed.
        vars.isDepleted = params.withdrawAmount == vars.createAmounts.deposit;
        vars.isSettled = lockup.refundableAmountOf(vars.streamId) == 0;

        // Only run the withdraw tests if the withdraw amount is not zero.
        if (params.withdrawAmount > 0) {
            // Load the pre-withdraw token balances.
            vars.initialLockupBalance = vars.actualLockupBalance;
            vars.initialLockupBalanceETH = address(lockup).balance;
            vars.initialRecipientBalance = FORK_TOKEN.balanceOf(params.recipient);

            // Expect the relevant events to be emitted.
            vm.expectEmit({ emitter: address(lockup) });
            emit ISablierLockupBase.WithdrawFromLockupStream({
                streamId: vars.streamId,
                to: params.recipient,
                token: FORK_TOKEN,
                amount: params.withdrawAmount
            });
            vm.expectEmit({ emitter: address(lockup) });
            emit IERC4906.MetadataUpdate({ _tokenId: vars.streamId });

            // Make the withdrawal.
            resetPrank({ msgSender: params.recipient });
            vm.deal({ account: params.recipient, newBalance: 100 ether });
            lockup.withdraw{ value: FEE }({
                streamId: vars.streamId,
                to: params.recipient,
                amount: params.withdrawAmount
            });

            // Assert that the stream's status is correct.
            vars.actualStatus = lockup.statusOf(vars.streamId);
            if (vars.isDepleted) {
                vars.expectedStatus = Lockup.Status.DEPLETED;
            } else if (vars.isSettled) {
                vars.expectedStatus = Lockup.Status.SETTLED;
            } else {
                vars.expectedStatus = Lockup.Status.STREAMING;
            }
            assertEq(vars.actualStatus, vars.expectedStatus, "post-withdraw stream status");

            // Assert that the withdrawn amount has been updated.
            vars.actualWithdrawnAmount = lockup.getWithdrawnAmount(vars.streamId);
            vars.expectedWithdrawnAmount = params.withdrawAmount;
            assertEq(vars.actualWithdrawnAmount, vars.expectedWithdrawnAmount, "post-withdraw withdrawnAmount");

            // Load the post-withdraw token balances.
            vars.balances = getTokenBalances(address(FORK_TOKEN), Solarray.addresses(address(lockup), params.recipient));
            vars.actualLockupBalance = vars.balances[0];
            vars.actualRecipientBalance = vars.balances[1];

            // Assert that the contract's balance has been updated.
            vars.expectedLockupBalance = vars.initialLockupBalance - uint256(params.withdrawAmount);
            assertEq(vars.actualLockupBalance, vars.expectedLockupBalance, "post-withdraw Lockup contract balance");

            // Assert that the contract's ETH balance has been updated.
            assertEq(address(lockup).balance, vars.initialLockupBalanceETH + FEE, "post-withdraw Lockup balance ETH");

            // Assert that the Recipient's balance has been updated.
            vars.expectedRecipientBalance = vars.initialRecipientBalance + uint256(params.withdrawAmount);
            assertEq(vars.actualRecipientBalance, vars.expectedRecipientBalance, "post-withdraw Recipient balance");
        }

        /*//////////////////////////////////////////////////////////////////////////
                                          CANCEL
        //////////////////////////////////////////////////////////////////////////*/

        // Only run the cancel tests if the stream is neither depleted nor settled.
        if (!vars.isDepleted && !vars.isSettled) {
            // Load the pre-cancel token balances.
            vars.balances = getTokenBalances(
                address(FORK_TOKEN), Solarray.addresses(address(lockup), params.sender, params.recipient)
            );
            vars.initialLockupBalance = vars.balances[0];
            vars.initialSenderBalance = vars.balances[1];
            vars.initialRecipientBalance = vars.balances[2];

            // Expect the relevant events to be emitted.
            vm.expectEmit({ emitter: address(lockup) });
            vars.senderAmount = lockup.refundableAmountOf(vars.streamId);
            vars.recipientAmount = lockup.withdrawableAmountOf(vars.streamId);
            emit ISablierLockupBase.CancelLockupStream(
                vars.streamId, params.sender, params.recipient, FORK_TOKEN, vars.senderAmount, vars.recipientAmount
            );
            vm.expectEmit({ emitter: address(lockup) });
            emit IERC4906.MetadataUpdate({ _tokenId: vars.streamId });

            // Cancel the stream.
            resetPrank({ msgSender: params.sender });
            lockup.cancel(vars.streamId);

            // Assert that the stream's status is correct.
            vars.actualStatus = lockup.statusOf(vars.streamId);
            vars.expectedStatus = vars.recipientAmount > 0 ? Lockup.Status.CANCELED : Lockup.Status.DEPLETED;
            assertEq(vars.actualStatus, vars.expectedStatus, "post-cancel stream status");

            // Load the post-cancel token balances.
            vars.balances = getTokenBalances(
                address(FORK_TOKEN), Solarray.addresses(address(lockup), params.sender, params.recipient)
            );
            vars.actualLockupBalance = vars.balances[0];
            vars.actualSenderBalance = vars.balances[1];
            vars.actualRecipientBalance = vars.balances[2];

            // Assert that the contract's balance has been updated.
            vars.expectedLockupBalance = vars.initialLockupBalance - uint256(vars.senderAmount);
            assertEq(vars.actualLockupBalance, vars.expectedLockupBalance, "post-cancel lockup contract balance");

            // Assert that the Sender's balance has been updated.
            vars.expectedSenderBalance = vars.initialSenderBalance + uint256(vars.senderAmount);
            assertEq(vars.actualSenderBalance, vars.expectedSenderBalance, "post-cancel Sender balance");

            // Assert that the Recipient's balance has not changed.
            vars.expectedRecipientBalance = vars.initialRecipientBalance;
            assertEq(vars.actualRecipientBalance, vars.expectedRecipientBalance, "post-cancel Recipient balance");
        }

        // Assert that the not burned NFT.
        vars.actualNFTOwner = lockup.ownerOf({ tokenId: vars.streamId });
        vars.expectedNFTOwner = params.recipient;
        assertEq(vars.actualNFTOwner, vars.expectedNFTOwner, "post-cancel NFT owner");
    }
}
