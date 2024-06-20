// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";

import { Base_Test } from "../Base.t.sol";
import {
    RecipientMarkerFalse, RecipientMarkerMissing, RecipientReentrant, RecipientReverting
} from "../mocks/Hooks.sol";

/// @notice Common logic needed by all integration tests, both concrete and fuzz tests.

abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    RecipientMarkerFalse internal recipientMarkerFalse = new RecipientMarkerFalse();
    RecipientMarkerMissing internal recipientMarkerMissing = new RecipientMarkerMissing();
    RecipientReentrant internal recipientReentrant = new RecipientReentrant();
    RecipientReverting internal recipientReverting = new RecipientReverting();

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Label the contracts.
        labelContracts();

        // Make the Admin the default caller in this test suite.
        resetPrank({ msgSender: users.admin });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Labels the most relevant contracts.
    function labelContracts() internal {
        vm.label({ account: address(recipientMarkerFalse), newLabel: "Recipient Marker False" });
        vm.label({ account: address(recipientMarkerMissing), newLabel: "Recipient Marker Missing" });
        vm.label({ account: address(recipientReentrant), newLabel: "Recipient Reentrant" });
        vm.label({ account: address(recipientReverting), newLabel: "Recipient Reverting" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    EXPECT CALLS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Expects a delegate call error.
    function expectRevertDueToDelegateCall(bool success, bytes memory returnData) internal pure {
        assertFalse(success, "delegatecall success");
        assertEq(returnData, abi.encodeWithSelector(Errors.DelegateCall.selector), "delegatecall return data");
    }
}
