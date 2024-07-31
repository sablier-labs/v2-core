// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { SablierNFTDescriptor } from "src/core/SablierNFTDescriptor.sol";

import { NFTDescriptorMock } from "test/mocks/NFTDescriptorMock.sol";
import { Base_Test } from "test/Base.t.sol";

contract NFTDescriptor_Unit_Concrete_Test is Base_Test, SablierNFTDescriptor {
    NFTDescriptorMock internal nftDescriptorMock;

    function setUp() public virtual override {
        Base_Test.setUp();
        deployConditionally();
    }

    /// @dev Conditionally deploys {NFTDescriptorMock} normally or from a source precompiled with `--via-ir`.
    function deployConditionally() internal {
        if (!isTestOptimizedProfile()) {
            nftDescriptorMock = new NFTDescriptorMock();
        } else {
            nftDescriptorMock =
                NFTDescriptorMock(deployCode("out-optimized/NFTDescriptorMock.sol/NFTDescriptorMock.json"));
        }
        vm.label({ account: address(nftDescriptorMock), newLabel: "NFTDescriptorMock" });
    }
}