// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract CalculateStreamedPercentage_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_CalculateStreamedPercentage_Zero() external {
        uint256 actualStreamedPercentage = calculateStreamedPercentage({ streamedAmount: 0, depositedAmount: 1337e18 });
        uint256 expectedStreamedPercentage = 0;
        assertEq(actualStreamedPercentage, expectedStreamedPercentage, "streamedPercentage");
    }

    function test_CalculateStreamedPercentage_Streaming() external {
        uint256 actualStreamedPercentage =
            calculateStreamedPercentage({ streamedAmount: 100e18, depositedAmount: 400e18 });
        uint256 expectedStreamedPercentage = 2500;
        assertEq(actualStreamedPercentage, expectedStreamedPercentage, "streamedPercentage");
    }

    function test_CalculateStreamedPercentage_Settled() external {
        uint256 actualStreamedPercentage =
            calculateStreamedPercentage({ streamedAmount: 1337e18, depositedAmount: 1337e18 });
        uint256 expectedStreamedPercentage = 10_000;
        assertEq(actualStreamedPercentage, expectedStreamedPercentage, "streamedPercentage");
    }
}
