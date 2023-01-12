// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { ISablierV2 } from "src/interfaces/ISablierV2.sol";

import { FlashLoan_Test } from "test/unit/sablier-v2/shared/flash-loan/flashLoan.t.sol";
import { ProTest } from "test/unit/sablier-v2/pro/ProTest.t.sol";

contract FlashLoan_ProTest is ProTest, FlashLoan_Test {
    function setUp() public virtual override(ProTest, FlashLoan_Test) {
        FlashLoan_Test.setUp();
        deal({ token: address(dai), to: address(pro), give: 1_000e18 });
        sablierV2 = ISablierV2(pro);
    }
}
