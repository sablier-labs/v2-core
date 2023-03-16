// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupLinear } from "src/types/DataTypes.sol";

import { Linear_Unit_Test } from "../Linear.t.sol";
import { Cancel_Unit_Test } from "../../shared/cancel/cancel.t.sol";
import { Cancel_Linear_DelegateCall } from "../../../../shared/mockups/delegate-call/Cancel_Linear.t.sol";

contract Cancel_Linear_Unit_Test is Cancel_Unit_Test, Linear_Unit_Test {
    function setUp() public virtual override(Linear_Unit_Test, Cancel_Unit_Test) {
        Linear_Unit_Test.setUp();
        Cancel_Unit_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_DelegateCall() external payable streamActive streamCancelable {
        LockupLinear.Stream memory stream = linear.getStream(defaultStreamId);

        new Cancel_Linear_DelegateCall(
            users.admin,
            DEFAULT_MAX_FEE,
            comptroller,
            address(linear),
            nftDescriptor,
            linear.nextStreamId(),
            stream,
            users.recipient,
            vm
        );
    }
}
