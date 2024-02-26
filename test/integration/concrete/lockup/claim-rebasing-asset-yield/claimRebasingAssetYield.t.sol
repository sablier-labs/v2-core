// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { YieldMode } from "src/interfaces/blast/IERC20Rebasing.sol";
import { Errors } from "src/libraries/Errors.sol";

import { ERC20RebasingMock } from "../../../../mocks/blast/ERC20RebasingMock.sol";
import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";

abstract contract ClaimRebasingAssetYield_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        // Set the claimable amount to 100.
        ERC20RebasingMock(address(erc20RebasingMock)).setClaimableAmount(address(base), 100e18);
    }

    function test_RevertWhen_CallerNotAdmin() external {
        // Make Eve the caller in this test.
        changePrank({ msgSender: users.eve });

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, users.admin, users.eve));
        base.claimRebasingAssetYield({ asset: erc20RebasingMock, amount: 100, to: users.admin });
    }

    modifier whenCallerAdmin() {
        // Make the Admin the caller in the rest of this test suite.
        changePrank({ msgSender: users.admin });
        _;
    }

    function test_RevertGiven_NotClaimableYield() external whenCallerAdmin {
        // Run the test.
        vm.expectRevert();
        base.claimRebasingAssetYield({ asset: erc20RebasingMock, amount: 100, to: users.admin });
    }

    modifier givenClaimableYield() {
        // Set the yield mode to claimable.
        base.configureRebasingAsset(erc20RebasingMock, YieldMode.CLAIMABLE);
        _;
    }

    function test_RevertWhen_AmountGreaterThanClaimable() external whenCallerAdmin givenClaimableYield {
        // Run the test.
        vm.expectRevert();
        base.claimRebasingAssetYield({ asset: erc20RebasingMock, amount: 101e18, to: users.admin });
    }

    modifier whenAmountNotGreaterThanClaimable() {
        _;
    }

    function test_ClaimRebasingAssetYield()
        external
        whenCallerAdmin
        givenClaimableYield
        whenAmountNotGreaterThanClaimable
    {
        // Store the admin's balance before the claim.
        uint256 adminBalanceBefore = ERC20RebasingMock(address(erc20RebasingMock)).balanceOf(users.admin);

        // Declare the claim amount.
        uint256 claimAmount = 100e18;

        // Claim the rebasing asset yield.
        uint256 actualClaimedAmount =
            base.claimRebasingAssetYield({ asset: erc20RebasingMock, amount: claimAmount, to: users.admin });

        // Store the recipient's balance after the claim.
        uint256 adminBalanceAfter = ERC20RebasingMock(address(erc20RebasingMock)).balanceOf(users.admin);

        // Assert that recipient's balance is increased by the claimed amount.
        assertEq(adminBalanceBefore + claimAmount, adminBalanceAfter);

        // Assert the claimable amount is now 0.
        assertEq(erc20RebasingMock.getClaimableAmount(address(base)), 0);

        // Assert the the return value equals the claimed amount.
        assertEq(actualClaimedAmount, claimAmount);
    }
}
