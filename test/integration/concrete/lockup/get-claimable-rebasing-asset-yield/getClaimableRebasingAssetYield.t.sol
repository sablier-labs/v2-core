// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { YieldMode } from "src/interfaces/blast/IERC20Rebasing.sol";

import { ERC20RebasingMock } from "../../../../mocks/blast/ERC20RebasingMock.sol";
import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract GetClaimableRebasingAssetYield_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        // Set the claimable amount to 100.
        ERC20RebasingMock(address(erc20RebasingMock)).setClaimableAmount(address(base), 100);
    }

    function test_RevertGiven_NotClaimableYield() external {
        // Run the test.
        vm.expectRevert();
        base.getClaimableRebasingAssetYield(erc20RebasingMock);
    }

    modifier givenClaimableYield() {
        // Set the yield mode to claimable.
        changePrank({ msgSender: users.admin });
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.CLAIMABLE);
        _;
    }

    function test_GetClaimableRebasingAssetYield() external givenClaimableYield {
        // Run the test.
        uint256 actualClaimableAmount = base.getClaimableRebasingAssetYield(erc20RebasingMock);
        uint256 expectedClaimableAmount = 100;

        assertEq(actualClaimableAmount, expectedClaimableAmount);
    }
}
