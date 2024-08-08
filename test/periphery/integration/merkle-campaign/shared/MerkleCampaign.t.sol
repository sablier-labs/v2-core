// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { MerkleCampaign_Integration_Test } from "../MerkleCampaign.t.sol";

abstract contract MerkleCampaign_Integration_Shared_Test is MerkleCampaign_Integration_Test {
    function setUp() public virtual override {
        MerkleCampaign_Integration_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier afterFirstClaim() {
        // Make the first claim to set `_firstClaimTime`.
        claim();
        _;
    }

    modifier createMerkleCampaignWithZeroExpiry() virtual {
        _;
    }

    modifier givenCampaignExpired() {
        vm.warp({ newTimestamp: defaults.EXPIRATION() + 1 seconds });
        _;
    }

    modifier givenExpirationNotZero() {
        _;
    }

    modifier givenRecipientHasClaimed() {
        // Make the first claim to set `_firstClaimTime`.
        claim();
        _;
    }

    modifier postGracePeriod() {
        vm.warp({ newTimestamp: getBlockTimestamp() + 8 days });
        _;
    }

    modifier whenCallerAdmin() {
        resetPrank({ msgSender: users.admin });
        _;
    }

    modifier whenIndexInTree() {
        _;
    }
}
