// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupPro } from "src/types/DataTypes.sol";

import { Pro_Unit_Test } from "../Pro.t.sol";
import { Withdraw_Unit_Test } from "../../shared/withdraw/withdraw.t.sol";
import { Withdraw_Pro_DelegateCall } from "../../../../shared/mockups/delegate-call/Withdraw_Pro.t.sol";

contract Withdraw_Pro_Unit_Test is Pro_Unit_Test, Withdraw_Unit_Test {
    function setUp() public virtual override(Pro_Unit_Test, Withdraw_Unit_Test) {
        Pro_Unit_Test.setUp();
        Withdraw_Unit_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_DelegateCall() external payable streamActive callerAuthorized toNonZeroAddress {
        LockupPro.Stream memory stream = pro.getStream(defaultStreamId);

        new Withdraw_Pro_DelegateCall(
            users.admin,
            DEFAULT_MAX_FEE,
            comptroller,
            address(pro),
            nftDescriptor,
            pro.nextStreamId(),
            DEFAULT_MAX_SEGMENT_COUNT,
            stream,
            users.recipient,
            DEFAULT_WITHDRAW_AMOUNT,
            vm
        );
    }
}
