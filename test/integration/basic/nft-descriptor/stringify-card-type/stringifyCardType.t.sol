// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SVGElements } from "src/libraries/SVGElements.sol";

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract StringifyCardType_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_StringifyCardType() external {
        assertEq(SVGElements.stringifyCardType(SVGElements.CardType.PROGRESS), "Progress");
        assertEq(SVGElements.stringifyCardType(SVGElements.CardType.STATUS), "Status");
        assertEq(SVGElements.stringifyCardType(SVGElements.CardType.STREAMED), "Streamed");
        assertEq(SVGElements.stringifyCardType(SVGElements.CardType.DURATION), "Duration");
    }
}
