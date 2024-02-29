// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19;

import { Adminable } from "./Adminable.sol";
import { IBlast, YieldMode, GasMode } from "../interfaces/blast/IBlast.sol";
import { IERC20Rebasing } from "../interfaces/blast/IERC20Rebasing.sol";
import { ISablierV2Blast } from "../interfaces/blast/ISablierV2Blast.sol";

/// @title SablierV2Blast
/// @notice See the documentation in {ISablierV2Blast}
abstract contract SablierV2Blast is
    Adminable, // 1 inherited component
    ISablierV2Blast // 0 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Blast
    function getClaimableRebasingAssetYield(IERC20Rebasing asset)
        external
        view
        override
        returns (uint256 claimableYield)
    {
        claimableYield = asset.getClaimableAmount(address(this));
    }

    /// @inheritdoc ISablierV2Blast
    function getRebasingAssetConfiguration(IERC20Rebasing asset) external view override returns (YieldMode yieldMode) {
        yieldMode = asset.getConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Blast
    function claimRebasingAssetYield(
        IERC20Rebasing asset,
        uint256 amount,
        address to
    )
        external
        override
        onlyAdmin
        returns (uint256 claimed)
    {
        claimed = asset.claim(to, amount);
    }

    /// @inheritdoc ISablierV2Blast
    function configureRebasingAsset(IERC20Rebasing asset, YieldMode yieldMode) external override onlyAdmin {
        asset.configure(yieldMode);
    }

    /// @inheritdoc ISablierV2Blast
    function configureYieldAndGas(
        IBlast blast,
        YieldMode yieldMode,
        GasMode gasMode,
        address governor
    )
        external
        override
        onlyAdmin
    {
        blast.configure(yieldMode, gasMode, governor);
    }
}
