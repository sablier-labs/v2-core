// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierMerkleBase } from "src/periphery/interfaces/ISablierMerkleBase.sol";

import { Claim_Integration_Test } from "../../shared/claim/claim.t.sol";

contract Claim_MerkleInstant_Integration_Test is Claim_Integration_Test {
    function setUp() public override {
        super.setUp();
        merkleBase = ISablierMerkleBase(merkleInstant);
    }

    function test_ClaimInstant() external givenCampaignNotExpired givenNotClaimed givenIncludedInMerkleTree {
        vm.expectEmit({ emitter: address(merkleBase) });
        emit Claim(defaults.INDEX1(), users.recipient1, defaults.CLAIM_AMOUNT());

        expectCallToTransfer({ to: users.recipient1, value: defaults.CLAIM_AMOUNT() });
        claim();

        assertTrue(merkleBase.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}
