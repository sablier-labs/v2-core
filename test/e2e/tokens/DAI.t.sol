// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2MainnetForkTest } from "../SablierV2MainnetForkTest.t.sol";

contract DAI_Test is SablierV2MainnetForkTest {
    function setUp() public override {
        super.setUp();

        approveSablier();
    }

    function holder() internal pure override returns (address) {
        return 0x66F62574ab04989737228D18C3624f7FC1edAe14;
    }

    function token() internal pure override returns (address) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }
}
