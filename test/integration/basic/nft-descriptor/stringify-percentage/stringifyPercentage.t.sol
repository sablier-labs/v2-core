// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract StringifyPercentage_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_StringifyPercentage_NoFractionalPart() external {
        assertEq(stringifyPercentage(0), "0%", "percentage mismatch");
        assertEq(stringifyPercentage(100), "1%", "percentage mismatch");
        assertEq(stringifyPercentage(300), "3%", "percentage mismatch");
        assertEq(stringifyPercentage(1000), "10%", "percentage mismatch");
        assertEq(stringifyPercentage(4200), "42%", "percentage mismatch");
        assertEq(stringifyPercentage(10_000), "100%", "percentage mismatch");
    }

    function test_StringifyPercentage_FractionalPart() external {
        assertEq(stringifyPercentage(1), "0.01%", "percentage mismatch");
        assertEq(stringifyPercentage(42), "0.42%", "percentage mismatch");
        assertEq(stringifyPercentage(314), "3.14%", "percentage mismatch");
        assertEq(stringifyPercentage(2064), "20.64%", "percentage mismatch");
        assertEq(stringifyPercentage(6588), "65.88%", "percentage mismatch");
        assertEq(stringifyPercentage(9999), "99.99%", "percentage mismatch");
    }
}
