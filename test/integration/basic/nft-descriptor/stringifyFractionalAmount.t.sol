// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "./NFTDescriptor.t.sol";

contract StringifyFractionalAmount_Integration_Basic_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_FractionalAmount_Zero() external {
        assertEq(stringifyFractionalAmount(0), "", "fractional part mismatch");
    }

    function test_FractionalAmount_LeadingZero() external {
        assertEq(stringifyFractionalAmount(1), ".01", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(5), ".05", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(9), ".09", "fractional part mismatch");
    }

    function test_FractionalAmount_NoLeadingZero() external {
        assertEq(stringifyFractionalAmount(10), ".10", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(12), ".12", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(33), ".33", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(42), ".42", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(70), ".70", "fractional part mismatch");
        assertEq(stringifyFractionalAmount(99), ".99", "fractional part mismatch");
    }
}
