// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ud } from "@prb/math/src/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";

import { FlashLoan_Integration_Shared_Test } from "../../../shared/flash-loan/FlashLoan.t.sol";

contract FlashFee_Integration_Concrete_Test is FlashLoan_Integration_Shared_Test {
    function test_RevertGiven_AssetNotFlashLoanable() external {
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2FlashLoan_AssetNotFlashLoanable.selector, dai));
        flashLoan.flashFee({ asset: address(dai), amount: 0 });
    }

    modifier givenAssetFlashLoanable() {
        comptroller.toggleFlashAsset(dai);
        _;
    }

    function test_FlashFee() external givenAssetFlashLoanable {
        uint256 amount = 782.23e18;
        uint256 actualFlashFee = flashLoan.flashFee({ asset: address(dai), amount: amount });
        uint256 expectedFlashFee = ud(amount).mul(defaults.FLASH_FEE()).intoUint256();
        assertEq(actualFlashFee, expectedFlashFee, "flashFee");
    }
}
