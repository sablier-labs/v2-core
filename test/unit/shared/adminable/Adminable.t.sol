// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Base_Test } from "../../../Base.t.sol";
import { AdminableMock } from "../../../mocks/AdminableMock.sol";

/// @title Adminable_Unit_Shared_Test
/// @notice Common testing logic needed across {Adminable} unit tests.
abstract contract Adminable_Unit_Shared_Test is Base_Test {
    AdminableMock internal adminable;

    function setUp() public virtual override {
        Base_Test.setUp();
        adminable = new AdminableMock(users.admin);
        vm.startPrank({ msgSender: users.admin });
    }
}
