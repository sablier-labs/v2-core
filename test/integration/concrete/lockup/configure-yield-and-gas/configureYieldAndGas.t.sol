// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { GasMode, IBlast, YieldMode } from "src/interfaces/blast/IBlast.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract ConfigureYieldAndGas_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_RevertWhen_CallerNotAdmin() external {
        // Make Eve the caller in this test.
        changePrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin, users.eve));
        base.configureYieldAndGas(IBlast(address(blastMock)), YieldMode.VOID, GasMode.CLAIMABLE, users.admin);
    }

    modifier whenCallerAdmin() {
        // Make the Admin the caller in the rest of this test suite.
        changePrank({ msgSender: users.admin });
        _;
    }

    function test_ConfigureYieldAndGas() external whenCallerAdmin {
        // Run the test.
        base.configureYieldAndGas(IBlast(address(blastMock)), YieldMode.VOID, GasMode.CLAIMABLE, users.admin);

        // Verify the blast configurations.
        uint8 actualYieldMode = blastMock.readYieldConfiguration(address(base));
        uint8 expectedYieldMode = uint8(YieldMode.VOID);
        assertEq(actualYieldMode, expectedYieldMode);

        (,,, GasMode actualGasMode) = blastMock.readGasParams(address(base));
        GasMode expectedGasMode = GasMode.CLAIMABLE;
        assertEq(uint8(actualGasMode), uint8(expectedGasMode));

        address actualGovernor = blastMock.governorMap(address(base));
        address expectedGovernor = users.admin;
        assertEq(actualGovernor, expectedGovernor);
    }
}
