// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19;

import { Adminable } from "./Adminable.sol";
import { IBlast, YieldMode, GasMode } from "../interfaces/blast/IBlast.sol";
import { IERC20Rebasing } from "../interfaces/blast/IERC20Rebasing.sol";
import { ISablierV2BlastGovernor } from "../interfaces/blast/ISablierV2BlastGovernor.sol";

/// @title SablierV2BlastGovernor
/// @notice See the documentation in {ISablierV2BlastGovernor}
abstract contract SablierV2BlastGovernor is
    Adminable, // 1 inherited component
    ISablierV2BlastGovernor // 0 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2BlastGovernor
    function getClaimableAssetYield(IERC20Rebasing asset) external view override returns (uint256 claimableYield) {
        claimableYield = asset.getClaimableAmount(address(this));
    }

    /// @inheritdoc ISablierV2BlastGovernor
    function getAssetConfiguration(IERC20Rebasing asset) external view override returns (YieldMode yieldMode) {
        yieldMode = asset.getConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2BlastGovernor
    function claimRebasingAssetYield(
        uint256 amount,
        address recipientOfYield,
        IERC20Rebasing asset
    )
        public
        override
        onlyAdmin
    {
        asset.claim(recipientOfYield, amount);
    }

    /// @inheritdoc ISablierV2BlastGovernor
    function configureRebasingAsset(
        IERC20Rebasing asset,
        YieldMode yieldMode
    )
        public
        override
        onlyAdmin
        returns (uint256 balance)
    {
        balance = asset.configure(yieldMode);
    }

    /// @inheritdoc ISablierV2BlastGovernor
    function configureYieldAndGas(
        IBlast blast,
        YieldMode yieldMode,
        GasMode gasMode,
        address governor
    )
        public
        override
        onlyAdmin
    {
        blast.configure(yieldMode, gasMode, governor);
    }
}
