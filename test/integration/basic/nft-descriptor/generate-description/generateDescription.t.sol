// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-line-length,quotes
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract GenerateDescription_Integration_Basic_Test is NFTDescriptor_Integration_Basic_Test {
    string internal constant DISCLAIMER =
        unicode"⚠️ DISCLAIMER: Due diligence is critical when assessing this NFT. Make sure the asset addresses match the genuine ERC-20 contracts, as symbols may be imitated.";

    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_GenerateDescription_Empty() external {
        string memory actualDescription = generateDescription("", "", "", "", "");
        string memory expectedAttributes = string.concat(
            "This NFT represents a payment stream in a Sablier V2 ",
            " contract. The owner of this NFT can withdraw the streamed assets, which are denominated in ",
            ".\\n\\n",
            "- Stream ID: ",
            "\\n- ",
            " Address: ",
            "\\n- ",
            " Address: ",
            "\\n\\n",
            DISCLAIMER
        );
        assertEq(actualDescription, expectedAttributes, "metadata description");
    }

    function test_GenerateDescription() external {
        string memory actualDescription = generateDescription(
            "Lockup Linear",
            dai.symbol(),
            "42",
            "0x78B190C1E493752f85E02b00a0C98851A5638A30",
            "0xFEbD67A34821d1607a57DD31aae5f246D7dE2ca2"
        );
        string memory expectedAttributes = string.concat(
            "This NFT represents a payment stream in a Sablier V2 ",
            "Lockup Linear",
            " contract. The owner of this NFT can withdraw the streamed assets, which are denominated in ",
            dai.symbol(),
            ".\\n\\n",
            "- Stream ID: ",
            "42",
            "\\n- ",
            "Lockup Linear",
            " Address: ",
            "0x78B190C1E493752f85E02b00a0C98851A5638A30",
            "\\n- ",
            "DAI",
            " Address: ",
            "0xFEbD67A34821d1607a57DD31aae5f246D7dE2ca2",
            "\\n\\n",
            DISCLAIMER
        );
        assertEq(actualDescription, expectedAttributes, "metadata description");
    }
}
