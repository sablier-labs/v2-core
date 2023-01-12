// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { ComptrollerTest } from "../ComptrollerTest.t.sol";
import { UD60x18, ud } from "@prb/math/UD60x18.sol";

contract FlashFee_ComptrollerTest is ComptrollerTest {
    function setUp() public override {
        ComptrollerTest.setUp();

        changePrank(users.admin);
    }

    function test_FlashFee_Zero() external {
        UD60x18 actualFlashFee = comptroller.flashFee();
        UD60x18 expectedFlashFee = ud(0);
        assertEq(actualFlashFee, expectedFlashFee);
    }

    function testFuzz_FlashFee(UD60x18 flashFee) external {
        flashFee = bound(flashFee, ud(1), DEFAULT_FLASH_FEE);
        comptroller.setFlashFee(flashFee);
        UD60x18 actualFlashFee = comptroller.flashFee();
        UD60x18 expectedFlashFee = flashFee;
        assertEq(actualFlashFee, expectedFlashFee);
    }
}
