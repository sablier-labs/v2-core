// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract GenerateAccentColor_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_GenerateAccentColor() external {
        // Passing a dummy contract instead of a real Sablier contract to make this test easy to maintain.
        string memory actualColor = generateAccentColor({ nft: address(noop), streamId: 1337 });
        string memory expectedColor = "hsl(32,74%,26%)";
        assertEq(actualColor, expectedColor, "accentColor");
    }
}
