// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.18;

import { Errors } from "src/libraries/Errors.sol";

/// @title SablierV2NoDelegateCall
/// @notice This contract implements logic to prevent delegate calls.
abstract contract SablierV2NoDelegateCall {
    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    address internal immutable _original;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        _original = address(this);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Prevents delegate call in the function used.
    modifier noDelegateCall() {
        _checkNotDelegateCall();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that no delegate call is being made.
    ///
    /// Notes:
    /// - We are using an internal function instead of inlining it into a modifier because modifiers
    /// are copied into every method that uses them. The use of immutable variables means that
    /// the address bytes are also copied in every place the modifier is used, which can lead
    /// to increased contract size. By using a internal function instead, we can avoid this duplication
    /// of code and reduce the overall size of the contract.
    function _checkNotDelegateCall() internal view {
        if (address(this) != _original) {
            revert Errors.SablierV2NoDelegateCall();
        }
    }
}
