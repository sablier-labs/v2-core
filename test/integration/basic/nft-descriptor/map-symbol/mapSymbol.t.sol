// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

import { Errors } from "src/libraries/Errors.sol";

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract MapSymbolToStreamingModel_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_RevertWhen_UnknownNFT() external {
        ERC721 nft = new ERC721("Foo NFT", "FOO");
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2NFTDescriptor_UnknownNFT.selector, nft, "FOO"));
        nftDescriptor.mapSymbol_(nft);
    }

    modifier whenKnownNFT() {
        _;
    }

    function test_MapSymbol_LockupDynamic() external {
        string memory actualStreamingModel = mapSymbol(dynamic);
        string memory expectedStreamingModel = "Lockup Dynamic";
        assertEq(actualStreamingModel, expectedStreamingModel, "streamingModel");
    }

    function test_MapSymbol_LockupLinear() external {
        string memory actualStreamingModel = mapSymbol(linear);
        string memory expectedStreamingModel = "Lockup Linear";
        assertEq(actualStreamingModel, expectedStreamingModel, "streamingModel");
    }
}
