// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20Rebasing } from "src/interfaces/blast/IERC20Rebasing.sol";
import { YieldMode } from "src/interfaces/blast/IYield.sol";

import { Integration_Test } from "../../../Integration.t.sol";
import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Errors } from "../../../../mocks/blast/Errors.sol";

abstract contract GetClaimableAssetYield_Integration_Concrete_Test is
    Integration_Test,
    Lockup_Integration_Shared_Test
{
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        changePrank({ msgSender: users.blastBridge });
        busd.mint(address(base), defaults.BLAST_ASSET_BALANCE());

        changePrank({ msgSender: users.admin });
    }

    function test_RevertGiven_VoidAssetYield() external {
        base.configureRebasingAsset({ asset: IERC20Rebasing(address(busd)), yieldMode: YieldMode.VOID });

        vm.expectRevert(abi.encodeWithSelector(Errors.NotClaimableAccount.selector));
        busd.getClaimableAmount(address(base));
    }

    function test_RevertGiven_AutomaticAssetYield() external {
        base.configureRebasingAsset({ asset: IERC20Rebasing(address(busd)), yieldMode: YieldMode.AUTOMATIC });

        vm.expectRevert(abi.encodeWithSelector(Errors.NotClaimableAccount.selector));
        busd.getClaimableAmount(address(base));
    }

    modifier givenClaimableAssetYield() {
        base.configureRebasingAsset({ asset: IERC20Rebasing(address(busd)), yieldMode: YieldMode.CLAIMABLE });

        distributeYield(defaults.BLAST_SHARE_PRICE());
        _;
    }

    function test_GetClaimableAssetYield() external givenClaimableAssetYield {
        uint256 actualClaimableAmount = busd.getClaimableAmount(address(base));
        uint256 expectedClaimableAmount = (defaults.BLAST_ASSET_BALANCE() * defaults.BLAST_SHARE_PRICE()) / 1e9;
        assertEq(actualClaimableAmount, expectedClaimableAmount);
    }
}
