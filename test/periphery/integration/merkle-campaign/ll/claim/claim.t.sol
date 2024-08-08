// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup, LockupLinear } from "src/core/types/DataTypes.sol";

import { MerkleCampaign_Integration_Shared_Test } from "../../shared/MerkleCampaign.t.sol";

contract Claim_MerkleLL_Integration_Test is MerkleCampaign_Integration_Shared_Test {
    function setUp() public override {
        super.setUp();
        merkleBase = merkleLL;
    }

    function test_Claim() external givenCampaignNotExpired givenNotClaimed givenIncludedInMerkleTree {
        uint256 expectedStreamId = lockupLinear.nextStreamId();

        vm.expectEmit({ emitter: address(merkleLL) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT(), expectedStreamId);
        claim();

        LockupLinear.StreamLL memory actualStream = lockupLinear.getStream(expectedStreamId);
        LockupLinear.StreamLL memory expectedStream = LockupLinear.StreamLL({
            amounts: Lockup.Amounts({ deposited: defaults.CLAIM_AMOUNT(), refunded: 0, withdrawn: 0 }),
            asset: dai,
            cliffTime: getBlockTimestamp() + defaults.CLIFF_DURATION(),
            endTime: getBlockTimestamp() + defaults.TOTAL_DURATION(),
            isCancelable: defaults.CANCELABLE(),
            isDepleted: false,
            isStream: true,
            isTransferable: defaults.TRANSFERABLE(),
            recipient: users.recipient1,
            sender: users.admin,
            startTime: getBlockTimestamp(),
            wasCanceled: false
        });

        assertEq(actualStream, expectedStream);
    }
}
