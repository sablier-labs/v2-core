// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2LinearMainnetFork } from "../SablierV2LinearMainnetFork.t.sol";

contract SHIBA_Test is SablierV2LinearMainnetFork {
    function setUp() public override {
        super.setUp();

        approveAndTransfer(holder(), address(this), IERC20(token()).balanceOf(holder()));
    }

    function balance() internal view override returns (uint256) {
        return IERC20(token()).balanceOf(address(this));
    }

    function holder() internal pure override returns (address) {
        return 0x73AF3bcf944a6559933396c1577B257e2054D935; // random SHIBA holder
    }

    function token() internal pure override returns (address) {
        return 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    }
}
