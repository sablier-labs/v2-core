// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IBlast } from "src/interfaces/blast/IBlast.sol";
import { GasMode } from "src/interfaces/blast/IGas.sol";
import { YieldMode } from "src/interfaces/blast/IYield.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract Configure_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_Configure_DefaultModes() external {
        // Get Gas configuration directly from the Blast contract
        (,,, GasMode actualGasMode) = blast.readGasParams(address(base));

        // Get Governor address directly from the Blast contract
        address actualGovernor = blast.governorMap(address(base));

        // Get Yield configuration directly from the Blast contract
        YieldMode actualYieldMode = YieldMode(blast.readYieldConfiguration(address(base)));

        GasMode expectedGasMode = GasMode.VOID;
        address expectedGovernor = address(0);
        YieldMode expectedYieldMode = YieldMode.VOID;

        assertEq(actualGasMode, expectedGasMode);
        assertEq(actualGovernor, expectedGovernor, "governorAddress");
        assertEq(actualYieldMode, expectedYieldMode);
    }

    modifier givenBlastConfigured() {
        // Make admin the caller in this test.
        changePrank({ msgSender: users.admin });

        base.configureVoidYieldAndClaimableGas({ blastEth: IBlast(address(blast)), governor: users.admin });
        _;
    }

    function test_Configure() external givenBlastConfigured {
        // Get Gas configuration directly from the Blast contract
        (,,, GasMode actualGasMode) = blast.readGasParams(address(base));

        // Get Governor address directly from the Blast contract
        address actualGovernor = blast.governorMap(address(base));

        // Get Yield configuration directly from the Blast contract
        YieldMode actualYieldMode = YieldMode(blast.readYieldConfiguration(address(base)));

        GasMode expectedGasMode = GasMode.CLAIMABLE;
        address expectedGovernor = users.admin;
        YieldMode expectedYieldMode = YieldMode.VOID;

        assertEq(actualGasMode, expectedGasMode);
        assertEq(actualGovernor, expectedGovernor, "governorAddress");
        assertEq(actualYieldMode, expectedYieldMode);
    }
}
