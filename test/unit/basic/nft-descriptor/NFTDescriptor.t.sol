// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { SablierV2NFTDescriptor } from "src/SablierV2NFTDescriptor.sol";

import { Base_Test } from "../../../Base.t.sol";

contract NFTDescriptor_Unit_Basic_Test is Base_Test, SablierV2NFTDescriptor {
    function setUp() public virtual override {
        Base_Test.setUp();
    }
}
