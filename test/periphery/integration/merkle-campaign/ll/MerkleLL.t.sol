// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup, LockupLinear } from "src/core/types/DataTypes.sol";
import { ISablierMerkleBase } from "src/periphery/interfaces/ISablierMerkleBase.sol";

import { Claim_Integration_Test } from "../shared/claim/claim.t.sol";
import { Clawback_Integration_Test } from "../shared/clawback/clawback.t.sol";
import { GetFirstClaimTime_Integration_Test } from "../shared/get-first-claim-time/getFirstClaimTime.t.sol";
import { HasClaimed_Integration_Test } from "../shared/has-claimed/hasClaimed.t.sol";
import { HasExpired_Integration_Test } from "../shared/has-expired/hasExpired.t.sol";
import { MerkleCampaign_Integration_Shared_Test } from "../shared/MerkleCampaign.t.sol";

/*//////////////////////////////////////////////////////////////////////////
                             NON-SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

abstract contract MerkleLL_Integration_Shared_Test is MerkleCampaign_Integration_Shared_Test {
    function setUp() public virtual override {
        MerkleCampaign_Integration_Shared_Test.setUp();

        // Cast the {MerkleLL} contract as {ISablierMerkleBase}
        merkleBase = ISablierMerkleBase(merkleLL);
    }
}

/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract Claim_MerkleLL_Integration_Test is Claim_Integration_Test, MerkleLL_Integration_Shared_Test {
    function setUp() public override(Claim_Integration_Test, MerkleLL_Integration_Shared_Test) {
        Claim_Integration_Test.setUp();
        MerkleLL_Integration_Shared_Test.setUp();
    }

    function test_Claim() external override givenCampaignNotExpired givenNotClaimed givenIncludedInMerkleTree {
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
        assertTrue(merkleLL.hasClaimed(defaults.INDEX1()), "not claimed");
    }
}

contract Clawback_MerkleLL_Integration_Test is Clawback_Integration_Test, MerkleLL_Integration_Shared_Test {
    function setUp() public override(Clawback_Integration_Test, MerkleLL_Integration_Shared_Test) {
        Clawback_Integration_Test.setUp();
        MerkleLL_Integration_Shared_Test.setUp();
    }
}

contract GetFirstClaimTime_MerkleLL_Integration_Test is
    GetFirstClaimTime_Integration_Test,
    MerkleLL_Integration_Shared_Test
{
    function setUp() public override(GetFirstClaimTime_Integration_Test, MerkleLL_Integration_Shared_Test) {
        GetFirstClaimTime_Integration_Test.setUp();
        MerkleLL_Integration_Shared_Test.setUp();
    }
}

contract HasClaimed_MerkleLL_Integration_Test is HasClaimed_Integration_Test, MerkleLL_Integration_Shared_Test {
    function setUp() public override(HasClaimed_Integration_Test, MerkleLL_Integration_Shared_Test) {
        HasClaimed_Integration_Test.setUp();
        MerkleLL_Integration_Shared_Test.setUp();
    }
}

contract HasExpired_MerkleLL_Integration_Test is HasExpired_Integration_Test, MerkleLL_Integration_Shared_Test {
    function setUp() public override(HasExpired_Integration_Test, MerkleLL_Integration_Shared_Test) {
        HasExpired_Integration_Test.setUp();
        MerkleLL_Integration_Shared_Test.setUp();
    }
}
