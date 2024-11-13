// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Lockup } from "src/core/types/DataTypes.sol";
import { Integration_Test } from "./../../Integration.t.sol";
import { Lockup_Tranched_Integration_Shared_Test } from "./../../shared/lockup/LockupTranched.t.sol";
import { Cancel_Integration_Fuzz_Test } from "./../lockup-base/cancel.t.sol";
import { CancelMultiple_Integration_Fuzz_Test } from "./../lockup-base/cancelMultiple.t.sol";
import { GetWithdrawnAmount_Integration_Fuzz_Test } from "./../lockup-base/getWithdrawnAmount.t.sol";
import { RefundableAmountOf_Integration_Fuzz_Test } from "./../lockup-base/refundableAmountOf.t.sol";
import { WithdrawMax_Integration_Fuzz_Test } from "./../lockup-base/withdrawMax.t.sol";
import { WithdrawMaxAndTransfer_Integration_Fuzz_Test } from "./../lockup-base/withdrawMaxAndTransfer.t.sol";
import { WithdrawMultiple_Integration_Fuzz_Test } from "./../lockup-base/withdrawMultiple.t.sol";

/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract Cancel_Lockup_Tranched_Integration_Fuzz_Test is
    Lockup_Tranched_Integration_Shared_Test,
    Cancel_Integration_Fuzz_Test
{
    function setUp() public virtual override(Lockup_Tranched_Integration_Shared_Test, Integration_Test) {
        Lockup_Tranched_Integration_Shared_Test.setUp();
    }
}

contract CancelMultiple_Lockup_Tranched_Integration_Fuzz_Test is CancelMultiple_Integration_Fuzz_Test {
    modifier whenCallerAuthorizedForAllStreams() override {
        cancelMultipleStreamIds = WarpAndCreateStreamsForCancelMultipleLT({ warpTime: originalTime });
        _;
    }

    function setUp() public virtual override {
        CancelMultiple_Integration_Fuzz_Test.setUp();
        lockupModel = Lockup.Model.LOCKUP_TRANCHED;
    }
}

contract RefundableAmountOf_Lockup_Tranched_Integration_Fuzz_Test is
    Lockup_Tranched_Integration_Shared_Test,
    RefundableAmountOf_Integration_Fuzz_Test
{
    function setUp() public virtual override(Lockup_Tranched_Integration_Shared_Test, Integration_Test) {
        Lockup_Tranched_Integration_Shared_Test.setUp();
    }
}

contract GetWithdrawnAmount_Lockup_Tranched_Integration_Fuzz_Test is
    Lockup_Tranched_Integration_Shared_Test,
    GetWithdrawnAmount_Integration_Fuzz_Test
{
    function setUp() public virtual override(Lockup_Tranched_Integration_Shared_Test, Integration_Test) {
        Lockup_Tranched_Integration_Shared_Test.setUp();
    }
}

contract WithdrawMax_Lockup_Tranched_Integration_Fuzz_Test is
    Lockup_Tranched_Integration_Shared_Test,
    WithdrawMax_Integration_Fuzz_Test
{
    function setUp() public virtual override(Lockup_Tranched_Integration_Shared_Test, Integration_Test) {
        Lockup_Tranched_Integration_Shared_Test.setUp();
    }
}

contract WithdrawMaxAndTransfer_Lockup_Tranched_Integration_Fuzz_Test is
    Lockup_Tranched_Integration_Shared_Test,
    WithdrawMaxAndTransfer_Integration_Fuzz_Test
{
    function setUp() public virtual override(Lockup_Tranched_Integration_Shared_Test, Integration_Test) {
        Lockup_Tranched_Integration_Shared_Test.setUp();
    }
}

contract WithdrawMultiple_Lockup_Tranched_Integration_Fuzz_Test is WithdrawMultiple_Integration_Fuzz_Test {
    /// @dev This modifier runs the test in three different modes:
    /// - Stream's sender as caller
    /// - Stream's recipient as caller
    /// - Approved NFT operator as caller
    modifier whenCallerAuthorizedForAllStreams() override {
        caller = users.sender;
        withdrawMultipleStreamIds = WarpAndCreateStreamsWithdrawMultipleLT({ warpTime: originalTime });
        _;

        withdrawMultipleStreamIds = WarpAndCreateStreamsWithdrawMultipleLT({ warpTime: originalTime });
        caller = users.recipient;
        _;

        withdrawMultipleStreamIds = WarpAndCreateStreamsWithdrawMultipleLT({ warpTime: originalTime });
        caller = users.operator;
        _;
    }

    function setUp() public virtual override {
        WithdrawMultiple_Integration_Fuzz_Test.setUp();
        lockupModel = Lockup.Model.LOCKUP_TRANCHED;
    }
}
