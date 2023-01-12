// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { IAdminable } from "@prb/contracts/access/IAdminable.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";

/// @title ISablierV2Controller
/// @notice This contract is in charge of the Sablier V2 protocol configuration, handling such values as the
/// protocol fees.
interface ISablierV2Comptroller is IAdminable {
    /// @notice Global flash fee as a 18 decimal percentage.
    /// @return The flash fee as an `UD60x18` number where 100% = 1e18.
    function flashFee() external view returns (UD60x18);

    /// @notice Queries the protocol fee charged on all Sablier V2 streams created with the provided token.
    /// @param token The address of the token to make the query for.
    /// @return protocolFee The protocol fee as an UD60x18 number where 100% = 1e18.
    function getProtocolFee(IERC20 token) external view returns (UD60x18 protocolFee);

    /// @notice Checks whether a token is flash loanable or not.
    /// @param token The address of the token to make the query for.
    /// @return result Whether the token is flash loanable or not.
    function isFlashLoanable(IERC20 token) external view returns (bool result);

    /// @notice Sets a new flash fee that will be charged on all flash loans.
    ///
    /// @dev Emits a {SetFlashFee} event.
    ///
    /// The fee follows the UD60x18 number format.
    /// Refer to the PRBMath documentation for more detail on the logic of UD60x18.
    ///
    /// Does not revert if the fee is the same.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    /// - The new protocol fee cannot be greater than `MAX_FEE`.
    ///
    /// @param newFlashFee The new flash fee to set.
    function setFlashFee(UD60x18 newFlashFee) external;

    /// @notice Sets a new token to be flash loanable.
    ///
    /// @dev Emits a {SetFlashToken} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    /// - The token must not be flash loanable.
    ///
    /// @param token The address of the token to be flash loanable.
    function setFlashToken(IERC20 token) external;

    /// @notice Sets a new protocol fee that will be charged on all streams created with the provided token.
    ///
    /// @dev Emits a {SetProtocolFee} event.
    ///
    /// Notes:
    /// - The fee is not in units of the token's decimals, instead it follows the UD60x18 number format. Refer to the
    /// PRBMath documentation for more detail on the logic of UD60x18.
    /// - Does not revert if the fee is the same.
    ///
    /// Requirements:
    /// - The caller must be the admin of the contract.
    /// - The new protocol fee cannot be greater than `MAX_FEE`.
    ///
    /// @param token The address of the token to make the query for.
    /// @param newProtocolFee The new protocol fee to set, as an UD60x18 number where 100% = 1e18.
    function setProtocolFee(IERC20 token, UD60x18 newProtocolFee) external;
}
