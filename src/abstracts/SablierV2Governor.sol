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
    function getClaimableAmount(IERC20Rebasing token) external view override returns (uint256 claimableYield) {
        return token.getClaimableAmount(address(this));
    }

    /// @inheritdoc ISablierV2Governor
    function getConfiguration(IERC20Rebasing token) external view override returns (YieldMode) {
        return token.getConfiguration(address(this));
    }

    /// @inheritdoc ISablierV2Governor
    function readClaimableYield(IBlast blastEth) external view override returns (uint256) {
        return blastEth.readClaimableYield(address(this));
    }

    /// @inheritdoc ISablierV2Governor
    function readGasParams(IBlast blastEth)
        external
        view
        override
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode gasMode)
    {
        return blastEth.readGasParams(address(this));
    }

    /// @inheritdoc ISablierV2Governor
    function readYieldConfiguration(IBlast blastEth) external view override returns (uint8) {
        return blastEth.readYieldConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Governor
    function claim(
        uint256 amount,
        address recipientOfYield,
        IERC20Rebasing token
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.claim(recipientOfYield, amount);
    }

    /// @inheritdoc ISablierV2Governor
    function claimAllGas(IBlast blastEth, address recipientOfGas) external override onlyAdmin returns (uint256) {
        return blastEth.claimAllGas(address(this), recipientOfGas);
    }

    /// @inheritdoc ISablierV2Governor
    function claimAllYield(IBlast blastEth, address recipientOfYield) external override onlyAdmin returns (uint256) {
        return blastEth.claimAllYield(address(this), recipientOfYield);
    }

    /// @inheritdoc ISablierV2Governor
    function configureYieldForToken(
        IERC20Rebasing token,
        YieldMode yieldMode
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.configure(yieldMode);
    }

    /// @inheritdoc ISablierV2Governor
    function configureVoidYieldAndClaimableGas(IBlast blastEth, address governor) external override onlyAdmin {
        blastEth.configure(YieldMode.VOID, GasMode.CLAIMABLE, governor);
    }
}
