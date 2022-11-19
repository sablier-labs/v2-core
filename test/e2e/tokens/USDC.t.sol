// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2MainnetForkTest } from "../SablierV2MainnetForkTest.t.sol";

contract USDC_Test is SablierV2MainnetForkTest {
    address internal holder = 0x09528d637deb5857dc059dddE6316D465a8b3b69; // random USDC holder

    function setUp() public override {
        super.setUp();

        approveAndTransfer(holder, IERC20(token()).balanceOf(holder));
    }

    function balance() internal view override returns (uint256) {
        return IERC20(token()).balanceOf(address(this));
    }

    function token() internal pure override returns (address) {
        return 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }
}
