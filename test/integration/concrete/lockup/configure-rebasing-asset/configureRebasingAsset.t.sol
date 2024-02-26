// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { YieldMode } from "src/interfaces/blast/IERC20Rebasing.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract ConfigureRebasingAsset_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_RevertWhen_CallerNotAdmin() external {
        // Make Eve the caller in this test.
        changePrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin, users.eve));
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.CLAIMABLE);
    }

    modifier whenCallerAdmin() {
        // Make the Admin the caller in the rest of this test suite.
        changePrank({ msgSender: users.admin });
        _;
    }

    function test_ConfigureRebasingAsset() external whenCallerAdmin {
        // Set the yield mode
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.CLAIMABLE);

        // Get the yield mode directly from the ERC20RebasingMock contract
        YieldMode actualYieldMode = erc20RebasingMock.getConfiguration(address(base));
        YieldMode expectedYieldMode = YieldMode.CLAIMABLE;

        // Assert that the yield mode has been set.
        assertEq(uint8(actualYieldMode), uint8(expectedYieldMode));
    }
}
