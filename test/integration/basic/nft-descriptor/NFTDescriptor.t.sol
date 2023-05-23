// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2NFTDescriptor } from "src/SablierV2NFTDescriptor.sol";

import { Integration_Test } from "../../Integration.t.sol";

contract NFTDescriptor_Integration_Basic_Test is Integration_Test, SablierV2NFTDescriptor {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }
}
