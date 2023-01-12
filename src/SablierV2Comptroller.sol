// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { Adminable } from "@prb/contracts/access/Adminable.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";

import { Errors } from "./libraries/Errors.sol";
import { Events } from "./libraries/Events.sol";

import { ISablierV2Comptroller } from "./interfaces/ISablierV2Comptroller.sol";

/// @title SablierV2Comptroller
/// @dev This contract implements the ISablierV2Comptroller interface.
contract SablierV2Comptroller is
    ISablierV2Comptroller, // one dependency
    Adminable // one dependency
{
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Comptroller
    UD60x18 public override flashFee;

    /// @dev Tokens supported by Sablier to be flash loanable.
    mapping(IERC20 => bool) internal _flashTokens;

    /// @dev Global fees mapped by token addresses.
    mapping(IERC20 => UD60x18) internal _protocolFees;

    /*//////////////////////////////////////////////////////////////////////////
                             PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Comptroller
    function getProtocolFee(IERC20 token) external view override returns (UD60x18 protocolFee) {
        protocolFee = _protocolFees[token];
    }

    /// @inheritdoc ISablierV2Comptroller
    function isFlashLoanable(IERC20 token) external view override returns (bool result) {
        result = _flashTokens[token];
    }

    /*//////////////////////////////////////////////////////////////////////////
                           PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Comptroller
    function setFlashFee(UD60x18 newFlashFee) external override onlyAdmin {
        // Effects: set the new flash fee.
        UD60x18 oldFlashFee = flashFee;
        flashFee = newFlashFee;

        // Emit an event.
        emit Events.SetFlashFee(admin, oldFlashFee, newFlashFee);
    }

    /// @inheritdoc ISablierV2Comptroller
    function setFlashToken(IERC20 token) external override onlyAdmin {
        // Checks: the token is not flash loanable.
        if (_flashTokens[token]) {
            revert Errors.SablierV2Comptroller_TokenFlashLoanable(token);
        }

        // Effects: set the token flash loanable.
        _flashTokens[token] = true;

        // Emit an event.
        emit Events.SetFlashToken(admin, token);
    }

    /// @inheritdoc ISablierV2Comptroller
    function setProtocolFee(IERC20 token, UD60x18 newProtocolFee) external onlyAdmin {
        // Effects: set the new global fee.
        UD60x18 oldProtocolFee = _protocolFees[token];
        _protocolFees[token] = newProtocolFee;

        // Emit an event.
        emit Events.SetProtocolFee(msg.sender, token, oldProtocolFee, newProtocolFee);
    }
}
