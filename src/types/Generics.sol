// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { UD60x18 } from "@prb/math/UD60x18.sol";

/// @notice Struct encapsulating the broker parameters passed to the create functions. Both can be set to zero.
/// @param account The address receiving the broker's fee.
/// @param fee The broker's percentage fee from the total amount, denoted as a fixed-point number where 1e18 is 100%.
struct Broker {
    address account;
    UD60x18 fee;
}
