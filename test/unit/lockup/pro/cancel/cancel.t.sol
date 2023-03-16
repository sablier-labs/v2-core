// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupPro } from "src/types/DataTypes.sol";

import { Pro_Unit_Test } from "../Pro.t.sol";
import { Cancel_Unit_Test } from "../../shared/cancel/cancel.t.sol";
import { Cancel_Pro_DelegateCall } from "../../../../shared/mockups/delegate-call/Cancel_Pro.t.sol";

contract Cancel_Pro_Unit_Test is Cancel_Unit_Test, Pro_Unit_Test {
    function setUp() public virtual override(Pro_Unit_Test, Cancel_Unit_Test) {
        Pro_Unit_Test.setUp();
        Cancel_Unit_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_DelegateCall() external payable streamActive streamCancelable {
        LockupPro.Stream memory stream = pro.getStream(defaultStreamId);

        new Cancel_Pro_DelegateCall(
            users.admin,
            DEFAULT_MAX_FEE,
            comptroller,
            address(pro),
            nftDescriptor,
            pro.nextStreamId(),
            DEFAULT_MAX_SEGMENT_COUNT,
            stream,
            users.recipient,
            vm
        );
    }
}
