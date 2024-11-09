// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Integration_Test } from "./../../Integration.t.sol";
import { Cancel_Integration_Fuzz_Test } from "./../lockup-base/cancel.t.sol";
import { RefundableAmountOf_Integration_Fuzz_Test } from "./../lockup-base/refundableAmountOf.t.sol";
/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract Cancel_Lockup_Dynamic_Integration_Fuzz_Test is Cancel_Integration_Fuzz_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }
}

contract RefundableAmountOf_Lockup_Dynamic_Integration_Fuzz_Test is RefundableAmountOf_Integration_Fuzz_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }
}
