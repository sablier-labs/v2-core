// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup, LockupLinear } from "src/core/types/DataTypes.sol";
import { MerkleLL } from "src/periphery/types/DataTypes.sol";

import { MerkleLL_Integration_Shared_Test } from "../MerkleLL.t.sol";
import { Claim_Integration_Test } from "../../shared/claim/claim.t.sol";

contract Claim_MerkleLL_Integration_Test is Claim_Integration_Test, MerkleLL_Integration_Shared_Test {
    function setUp() public override(Claim_Integration_Test, MerkleLL_Integration_Shared_Test) {
        super.setUp();
    }

    function test_Claim_TimestampsInThePast()
        external
        givenCampaignNotExpired
        givenNotClaimed
        givenIncludedInMerkleTree
    {
        MerkleLL.Schedule memory schedule = defaults.schedule();
        schedule.startTime = getBlockTimestamp();
        schedule.cliffDuration = 0;

        merkleLL = merkleFactory.createMerkleLL({
            baseParams: defaults.baseParams(users.admin, dai, defaults.EXPIRATION(), defaults.MERKLE_ROOT()),
            lockupLinear: lockupLinear,
            cancelable: defaults.CANCELABLE(),
            transferable: defaults.TRANSFERABLE(),
            schedule: schedule,
            aggregateAmount: defaults.AGGREGATE_AMOUNT(),
            recipientCount: defaults.RECIPIENT_COUNT()
        });
        deal({ token: address(dai), to: address(merkleLL), give: defaults.AGGREGATE_AMOUNT() });

        vm.warp(defaults.END_TIME() + 1);

        _test_Claim(schedule.startTime, 0);
    }

    function test_Claim() external override givenCampaignNotExpired givenNotClaimed givenIncludedInMerkleTree {
        _test_Claim(getBlockTimestamp(), getBlockTimestamp() + defaults.CLIFF_DURATION());
    }

    function _test_Claim(uint40 startTime, uint40 cliffTime) private {
        uint256 expectedStreamId = lockupLinear.nextStreamId();

        vm.expectEmit({ emitter: address(merkleLL) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        merkleLL.claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), defaults.index1Proof());

        LockupLinear.StreamLL memory actualStream = lockupLinear.getStream(expectedStreamId);
        LockupLinear.StreamLL memory expectedStream = LockupLinear.StreamLL({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: dai,
            cliffTime: cliffTime,
            endTime: startTime + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            recipient: users.recipient1,
            sender: users.admin,
            startTime: startTime,
            wasCanceled: false
        });

        assertEq(actualStream, expectedStream);
        assertTrue(merkleLL.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}
