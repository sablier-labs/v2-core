// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-line-length,quotes
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract GenerateAttributes_Integration_Basic_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_GenerateAttributes_Empty() external {
        string memory actualAttributes = generateAttributes("", "", "");
        string memory expectedAttributes =
            '[{"trait_type":"Asset","value":""},{"trait_type":"Sender","value":""},{"trait_type":"Status","value":""}]';
        assertEq(actualAttributes, expectedAttributes, "metadata attributes");
    }

    function test_GenerateAttributes() external {
        string memory actualAttributes =
            generateAttributes("DAI", "0x50725493D337CdC4e381f658e10d29d128BD6927", "Streaming");
        string memory expectedAttributes =
            '[{"trait_type":"Asset","value":"DAI"},{"trait_type":"Sender","value":"0x50725493D337CdC4e381f658e10d29d128BD6927"},{"trait_type":"Status","value":"Streaming"}]';
        assertEq(actualAttributes, expectedAttributes, "metadata attributes");
    }
}
