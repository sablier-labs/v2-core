// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2MainnetForkTest } from "../SablierV2MainnetForkTest.t.sol";

contract USDC_Test is SablierV2MainnetForkTest {
    function setUp() public override {
        super.setUp();

        approveSablier();
    }

    function holder() internal pure override returns (address) {
        return 0x09528d637deb5857dc059dddE6316D465a8b3b69; // random USDC holder
    }

    function token() internal pure override returns (IERC20) {
        return IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }
}
