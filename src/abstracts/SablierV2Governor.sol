// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19;

import { Adminable } from "./Adminable.sol";
import { IBlast } from "../interfaces/blast/IBlast.sol";
import { IERC20Rebasing } from "../interfaces/blast/IERC20Rebasing.sol";
import { GasMode } from "../interfaces/blast/IGas.sol";
import { YieldMode } from "../interfaces/blast/IYield.sol";
import { ISablierV2Governor } from "../interfaces/ISablierV2Governor.sol";

/// @title SablierV2Governor
/// @notice This contract implements logic to interact with the Blast contracts.
/// @dev Deploys with default Disabled yield for ETH and Automatic yield for USDB and WETH (https://docs.blast.io)
///     - Blast ETH: 0x4300000000000000000000000000000000000002
///     - Blast USDB: 0x4200000000000000000000000000000000000022
///     - Blast WETH: 0x4200000000000000000000000000000000000023
abstract contract SablierV2Governor is
    Adminable, // 1 inherited component
    ISablierV2Governor // 0 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Governor
    function getClaimableAssetYield(IERC20Rebasing asset) external view override returns (uint256 claimableYield) {
        return asset.getClaimableAmount(address(this));
    }

    /// @inheritdoc ISablierV2Governor
    function getAssetConfiguration(IERC20Rebasing asset) external view override returns (YieldMode) {
        return asset.getConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Governor
    function claimRebasingAssetYield(
        uint256 amount,
        address recipientOfYield,
        IERC20Rebasing asset
    )
        public
        override
        onlyAdmin
        returns (uint256)
    {
        return asset.claim(recipientOfYield, amount);
    }

    /// @inheritdoc ISablierV2Governor
    function configureRebasingAsset(
        IERC20Rebasing asset,
        YieldMode yieldMode
    )
        public
        override
        onlyAdmin
        returns (uint256)
    {
        return asset.configure(yieldMode);
    }

    /// @inheritdoc ISablierV2Governor
    function configureYieldAndGas(IBlast blastEth, address governor) public override onlyAdmin {
        blastEth.configure(YieldMode.VOID, GasMode.CLAIMABLE, governor);
    }
}
