// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "src/types/DataTypes.sol";

import { Linear_Unit_Test } from "../Linear.t.sol";
import { Withdraw_Unit_Test } from "../../shared/withdraw/withdraw.t.sol";
import { Withdraw_Linear_DelegateCall } from "../../../../shared/mockups/delegate-call/Withdraw_Linear.t.sol";

contract Withdraw_Linear_Unit_Test is Linear_Unit_Test, Withdraw_Unit_Test {
    function setUp() public virtual override(Linear_Unit_Test, Withdraw_Unit_Test) {
        Linear_Unit_Test.setUp();
        Withdraw_Unit_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_DelegateCall() external payable streamActive callerAuthorized toNonZeroAddress {
        LockupLinear.Stream memory stream = linear.getStream(defaultStreamId);

        vm.warp(uint256(DEFAULT_END_TIME));
        new Withdraw_Linear_DelegateCall(
            users.admin,
            DEFAULT_MAX_FEE,
            comptroller,
            address(linear),
            nftDescriptor,
            linear.nextStreamId(),
            stream,
            users.recipient,
            DEFAULT_WITHDRAW_AMOUNT,
            vm
        );
    }
}
