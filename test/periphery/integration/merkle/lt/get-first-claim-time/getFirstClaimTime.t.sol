// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Merkle_Integration_Test } from "../../Merkle.t.sol";

contract GetFirstClaimTime_Integration_Test is Merkle_Integration_Test {
    function test_GetFirstClaimTime_BeforeFirstClaim() external view {
        uint256 firstClaimTime = merkleLT.getFirstClaimTime();
        assertEq(firstClaimTime, 0);
    }

    modifier afterFirstClaim() {
        // Make the first claim to set `_firstClaimTime`.
        claimLT();
        _;
    }

    function test_GetFirstClaimTime() external afterFirstClaim {
        uint256 firstClaimTime = merkleLT.getFirstClaimTime();
        assertEq(firstClaimTime, getBlockTimestamp());
    }
}
