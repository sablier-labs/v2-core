// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierMerkleBase } from "src/periphery/interfaces/ISablierMerkleBase.sol";

import { Clawback_Integration_Test } from "../shared/clawback/clawback.t.sol";
import { GetFirstClaimTime_Integration_Test } from "../shared/get-first-claim-time/getFirstClaimTime.t.sol";
import { HasClaimed_Integration_Test } from "../shared/has-claimed/hasClaimed.t.sol";
import { HasExpired_Integration_Test } from "../shared/has-expired/hasExpired.t.sol";

/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract Clawback_MerkleLInstant_Integration_Test is Clawback_Integration_Test {
    function setUp() public virtual override {
        super.setUp();
        merkleBase = ISablierMerkleBase(merkleInstant);
    }

    modifier afterFirstClaim() override {
        // Make the first claim to set `_firstClaimTime`.
        claimInstant();
        _;
    }
}

contract GetFirstClaimTime_MerkleLInstant_Integration_Test is GetFirstClaimTime_Integration_Test {
    function setUp() public virtual override {
        super.setUp();
        merkleBase = ISablierMerkleBase(merkleInstant);
    }

    modifier afterFirstClaim() override {
        // Make the first claim to set `_firstClaimTime`.
        claimInstant();
        _;
    }
}

contract HasClaimed_MerkleLInstant_Integration_Test is HasClaimed_Integration_Test {
    function setUp() public virtual override {
        super.setUp();
        merkleBase = ISablierMerkleBase(merkleInstant);
    }

    modifier givenRecipientHasClaimed() override {
        // Make the first claim to set `_firstClaimTime`.
        claimInstant();
        _;
    }
}

contract HasExpired_MerkleLInstant_Integration_Test is HasExpired_Integration_Test {
    function setUp() public virtual override {
        super.setUp();
        merkleBase = ISablierMerkleBase(merkleInstant);
    }

    modifier createMerkleCampaignWithZeroExpiry() override {
        campaignWithZeroExpiry = ISablierMerkleBase(createMerkleInstant({ expiration: 0 }));
        _;
    }
}
