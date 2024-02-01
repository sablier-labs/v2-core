// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { Adminable } from "./Adminable.sol";
import { IBlast } from "../interfaces/IBlast.sol";
import { IBlastGovernor } from "../interfaces/IBlastGovernor.sol";

/// @title BlastGovernor
/// @notice This contract implements logic to interact with the Blast contracts.
/// @dev https://docs.blast.io/
abstract contract BlastGovernor is
    Adminable, // 1 inherited component
    IBlastGovernor // 0 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    IBlast public constant BLAST_ETH = IBlast(0x4300000000000000000000000000000000000002);

    /// @inheritdoc IBlastGovernor
    IBlast public constant BLAST_USDB = IBlast(0x4200000000000000000000000000000000000022);

    /// @inheritdoc IBlastGovernor
    IBlast public constant BLAST_WETH = IBlast(0x4200000000000000000000000000000000000023);

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        // configure the gas mode for ETH on Blast network.
        BLAST_ETH.configure({
            yieldMode: IBlast.YieldMode.VOID,
            gasMode: IBlast.GasMode.CLAIMABLE,
            governor: address(this)
        });

        // configure the yield mode for USDB on Blast network.
        BLAST_USDB.configure({ yieldMode: IBlast.YieldMode.CLAIMABLE });

        // configure the yield mode for WETH on Blast network.
        BLAST_WETH.configure({ yieldMode: IBlast.YieldMode.CLAIMABLE });
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function getClaimableAmount(IBlast token) external view override returns (uint256 claimableYield) {
        return token.getClaimableAmount(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readClaimableYield() external view override returns (uint256) {
        return BLAST_ETH.readClaimableYield(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readGasParams()
        external
        view
        override
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, IBlast.GasMode gasMode)
    {
        return BLAST_ETH.readGasParams(address(this));
    }

    /// @inheritdoc IBlastGovernor
    function readYieldConfiguration() external view override returns (uint8) {
        return BLAST_ETH.readYieldConfiguration(address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBlastGovernor
    function claim(
        address recipientOfYield,
        uint256 amount,
        IBlast token
    )
        external
        override
        onlyAdmin
        returns (uint256)
    {
        return token.claim(recipientOfYield, amount);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllGas(address recipientOfGas) external override onlyAdmin returns (uint256) {
        return BLAST_ETH.claimAllGas(address(this), recipientOfGas);
    }

    /// @inheritdoc IBlastGovernor
    function claimAllYield(address recipientOfYield) external override onlyAdmin returns (uint256) {
        return BLAST_ETH.claimAllYield(address(this), recipientOfYield);
    }

    /// @inheritdoc IBlastGovernor
    function configure(IBlast.YieldMode yieldMode, IBlast token) external {
        token.configure({ yieldMode: yieldMode });
    }

    /// @inheritdoc IBlastGovernor
    function configure(
        IBlast.YieldMode yieldMode,
        IBlast.GasMode gasMode,
        address newGovernor
    )
        external
        override
        onlyAdmin
    {
        BLAST_ETH.configure({ yieldMode: yieldMode, gasMode: gasMode, governor: newGovernor });
    }
}
