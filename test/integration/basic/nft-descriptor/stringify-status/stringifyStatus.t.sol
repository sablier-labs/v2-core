// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup } from "src/types/DataTypes.sol";

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract StringifyStatus_Integration_Basic_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_StringifyStatus() external {
        assertEq(stringifyStatus(Lockup.Status.DEPLETED), "Depleted", "depleted status mismatch");
        assertEq(stringifyStatus(Lockup.Status.CANCELED), "Canceled", "canceled status mismatch");
        assertEq(stringifyStatus(Lockup.Status.STREAMING), "Streaming", "streaming status mismatch");
        assertEq(stringifyStatus(Lockup.Status.SETTLED), "Settled", "settled status mismatch");
        assertEq(stringifyStatus(Lockup.Status.PENDING), "Pending", "pending status mismatch");
    }
}
