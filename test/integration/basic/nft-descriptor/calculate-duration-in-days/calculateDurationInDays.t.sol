// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SVGElements } from "src/libraries/SVGElements.sol";

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract CalculateDurationInDays_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_CalculateDurationInDays_ZeroDays() external {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1 days - 1 seconds;
        string memory actualDurationInDays = calculateDurationInDays(startTime, endTime);
        string memory expectedDurationInDays = string.concat(SVGElements.SIGN_LT, " 1 Day");
        assertEq(actualDurationInDays, expectedDurationInDays, "durationInDays");
    }

    function test_CalculateDurationInDays_OneDay() external {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1 days;
        string memory actualDurationInDays = calculateDurationInDays(startTime, endTime);
        string memory expectedDurationInDays = "1 Day";
        assertEq(actualDurationInDays, expectedDurationInDays, "durationInDays");
    }

    function test_CalculateDurationInDays_LeetDays() external {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1337 days;
        string memory actualDurationInDays = calculateDurationInDays(startTime, endTime);
        string memory expectedDurationInDays = "1337 Days";
        assertEq(actualDurationInDays, expectedDurationInDays, "durationInDays");
    }

    function test_CalculateDurationInDays_TenThousandDays() external {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 10_000 days;
        string memory actualDurationInDays = calculateDurationInDays(startTime, endTime);
        string memory expectedDurationInDays = string.concat(SVGElements.SIGN_GT, " 9999 Days");
        assertEq(actualDurationInDays, expectedDurationInDays, "durationInDays");
    }

    function test_CalculateDurationInDays_Overflow() external {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime - 1 seconds;
        string memory actualDurationInDays = calculateDurationInDays(startTime, endTime);
        string memory expectedDurationInDays = string.concat(SVGElements.SIGN_GT, " 9999 Days");
        assertEq(actualDurationInDays, expectedDurationInDays, "durationInDays");
    }
}
