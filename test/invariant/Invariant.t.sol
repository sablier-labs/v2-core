// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { InvariantTest as ForgeInvariantTest } from "forge-std/InvariantTest.sol";

import { SablierV2Comptroller } from "src/SablierV2Comptroller.sol";

import { GoodFlashLoanReceiver } from "../shared/mockups/flash-loan/GoodFlashLoanReceiver.t.sol";
import { Base_Test } from "../Base.t.sol";
import { ComptrollerHandler } from "./handlers/ComptrollerHandler.t.sol";

/// @title Invariant_Test
/// @notice Base test contract with common logic needed by all invariant test contracts.
abstract contract Invariant_Test is Base_Test, ForgeInvariantTest {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ComptrollerHandler internal comptrollerHandler;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy the comptroller and its handler.
        comptroller = new SablierV2Comptroller({ initialAdmin: users.admin });
        comptrollerHandler = new ComptrollerHandler(comptroller);
        vm.prank({ msgSender: users.admin });
        comptroller.transferAdmin(address(comptrollerHandler));

        // Target only the comptroller handler for invariant testing (to avoid getting reverts).
        targetContract(address(comptrollerHandler));

        // Label the base contracts.
        vm.label({ account: address(comptroller), newLabel: "Comptroller" });
        vm.label({ account: address(comptrollerHandler), newLabel: "ComptrollerHandler" });
    }
}