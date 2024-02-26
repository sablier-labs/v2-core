// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { YieldMode } from "src/interfaces/blast/IERC20Rebasing.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract GetRebasingAssetConfiguration_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        // Make the Admin the caller in the rest of this test suite.
        changePrank({ msgSender: users.admin });
    }

    function test_GetRebasingAssetConfigurationGiven_AutomaticYield() external {
        // Set the yield mode to automatic.
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.AUTOMATIC);

        // Get the yield mode directly from the ERC20RebasingMock contract
        YieldMode actualYieldMode = erc20RebasingMock.getConfiguration(address(base));
        YieldMode expectedYieldMode = YieldMode.AUTOMATIC;

        // Assert that the yield mode has been set.
        assertEq(uint8(actualYieldMode), uint8(expectedYieldMode));
    }

    function test_GetRebasingAssetConfigurationGiven_VoidYield() external {
        // Set the yield mode to automatic.
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.VOID);

        // Get the yield mode directly from the ERC20RebasingMock contract
        YieldMode actualYieldMode = erc20RebasingMock.getConfiguration(address(base));
        YieldMode expectedYieldMode = YieldMode.VOID;

        // Assert that the yield mode has been set.
        assertEq(uint8(actualYieldMode), uint8(expectedYieldMode));
    }

    function test_GetRebasingAssetConfigurationGiven_ClaimableYield() external {
        // Set the yield mode to claimable.
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.CLAIMABLE);

        // Get the yield mode directly from the ERC20RebasingMock contract
        YieldMode actualYieldMode = erc20RebasingMock.getConfiguration(address(base));
        YieldMode expectedYieldMode = YieldMode.CLAIMABLE;

        // Assert that the yield mode has been set.
        assertEq(uint8(actualYieldMode), uint8(expectedYieldMode));
    }
}
