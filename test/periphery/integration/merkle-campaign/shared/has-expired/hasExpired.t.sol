// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ISablierMerkleBase } from "src/periphery/interfaces/ISablierMerkleBase.sol";

import { MerkleCampaign_Integration_Test } from "../../MerkleCampaign.t.sol";

abstract contract HasExpired_Integration_Test is MerkleCampaign_Integration_Test {
    ISablierMerkleBase internal campaignWithZeroExpiry;

    modifier createMerkleCampaignWithZeroExpiry() virtual {
        _;
    }

    function test_HasExpired_ExpirationZero() external view createMerkleCampaignWithZeroExpiry {
        assertFalse(campaignWithZeroExpiry.hasExpired(), "campaign expired");
    }

    modifier givenExpirationNotZero() {
        _;
    }

    function test_HasExpired_ExpirationLessThanBlockTimestamp() external view givenExpirationNotZero {
        assertFalse(merkleBase.hasExpired(), "campaign expired");
    }

    function test_HasExpired_ExpirationEqualToBlockTimestamp() external givenExpirationNotZero {
        vm.warp({ newTimestamp: defaults.EXPIRATION() });
        assertTrue(merkleBase.hasExpired(), "campaign not expired");
    }

    function test_HasExpired_ExpirationGreaterThanBlockTimestamp() external givenExpirationNotZero {
        vm.warp({ newTimestamp: defaults.EXPIRATION() + 1 seconds });
        assertTrue(merkleBase.hasExpired(), "campaign not expired");
    }
}
