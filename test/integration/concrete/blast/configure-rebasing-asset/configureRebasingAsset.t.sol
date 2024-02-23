// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20Rebasing } from "src/interfaces/blast/IERC20Rebasing.sol";
import { YieldMode } from "src/interfaces/blast/IYield.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract ConfigureRebasingAsset_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_Configure_DefaultMode() external {
        // Get Yield configuration directly from the mocked BUSD contract
        YieldMode actualYieldMode = busd.getConfiguration(address(base));

        YieldMode expectedYieldMode = YieldMode.AUTOMATIC;

        assertEq(actualYieldMode, expectedYieldMode);
    }

    modifier givenBlastConfigured() {
        // Make admin the caller in this test.
        changePrank({ msgSender: users.admin });

        base.configureRebasingAsset({ asset: IERC20Rebasing(address(busd)), yieldMode: YieldMode.CLAIMABLE });
        _;
    }

    function test_Configure() external givenBlastConfigured {
        // Get Yield configuration directly from the mocked BUSD contract
        YieldMode actualYieldMode = busd.getConfiguration(address(base));

        YieldMode expectedYieldMode = YieldMode.CLAIMABLE;

        assertEq(actualYieldMode, expectedYieldMode);
    }
}
