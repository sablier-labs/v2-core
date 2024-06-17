// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { NFTDescriptor_Integration_Concrete_Test } from "../NFTDescriptor.t.sol";

contract IsAlphanumeric_Integration_Concrete_Test is NFTDescriptor_Integration_Concrete_Test {
    function test_IsAlphanumeric_EmptyString() external view {
        string memory symbol = "";
        bool result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");
    }

    modifier whenNotEmptyString() {
        _;
    }

    function test_IsAlphanumeric_ContainsNonAlphanumericCharacters() external view whenNotEmptyString {
        string memory symbol = "<foo/>";
        bool result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo/";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo\\";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo%";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo&";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo(";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo)";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo\"";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo'";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo`";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo;";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");

        symbol = "foo%20"; // URL-encoded empty space
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertFalse(result, "isAlphanumeric");
    }

    modifier whenOnlyAlphanumericCharacters() {
        _;
    }

    function test_IsAlphanumeric_ContainsOnlyAlphanumericCharacters()
        external
        view
        whenNotEmptyString
        whenOnlyAlphanumericCharacters
    {
        string memory symbol = "foo";
        bool result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "Foo";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "Foo ";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "Foo Bar";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "  ";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "foo01234";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");

        symbol = "123456789";
        result = nftDescriptorMock.isAlphanumeric_(symbol);
        assertTrue(result, "isAlphanumeric");
    }
}
