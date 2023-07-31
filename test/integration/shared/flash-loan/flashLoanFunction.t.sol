// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { FlashLoan_Integration_Shared_Test } from "./FlashLoan.t.sol";

contract FlashLoanFunction_Integration_Shared_Test is FlashLoan_Integration_Shared_Test {
    uint128 internal constant LIQUIDITY_AMOUNT = 8_755_001e18;

    function setUp() public virtual override {
        FlashLoan_Integration_Shared_Test.setUp();
    }

    modifier givenNotDelegateCalled() {
        _;
    }

    modifier givenAmountNotTooHigh() {
        _;
    }

    modifier givenAssetFlashLoanable() {
        if (!comptroller.isFlashAsset(dai)) {
            comptroller.toggleFlashAsset(dai);
        }
        _;
    }

    modifier givenCalculatedFeeNotTooHigh() {
        _;
    }

    modifier givenBorrowDoesNotFail() {
        _;
    }

    modifier whenNoReentrancy() {
        _;
    }
}
