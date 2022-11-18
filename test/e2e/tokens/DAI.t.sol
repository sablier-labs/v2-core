// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2LinearMainnetFork } from "../SablierV2LinearMainnetFork.t.sol";

contract DAI_Test is SablierV2LinearMainnetFork {
    function setUp() public override {
        super.setUp();

        approveAndTransfer(holder(), address(this), IERC20(token()).balanceOf(holder()));
    }

    function balance() internal view override returns (uint256) {
        return IERC20(token()).balanceOf(address(this));
    }

    function holder() internal pure override returns (address) {
        return 0x66F62574ab04989737228D18C3624f7FC1edAe14; // random DAI holder
    }

    function token() internal pure override returns (address) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }
}
