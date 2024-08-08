// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { MerkleCampaign_Integration_Shared_Test } from "../../shared/MerkleCampaign.t.sol";

contract Claim_MerkleInstant_Integration_Test is MerkleCampaign_Integration_Shared_Test {
    function setUp() public override {
        super.setUp();
        merkleBase = merkleInstant;
    }

    function test_Claim() external givenCampaignNotExpired givenNotClaimed givenIncludedInMerkleTree {
        vm.expectEmit({ emitter: address(merkleBase) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT());
        expectCallToTransfer({ to: users.recipient1, value: defaults.CLAIM_AMOUNT() });
        claim();
    }
}
