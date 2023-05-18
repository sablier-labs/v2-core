// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @notice Namespace for the structs used in both {SablierV2LockupLinear} and {SablierV2LockupDynamic}.
library Lockup {
    /// @notice Struct encapsulating the deposit, withdrawn, and refunded amounts, all denoted in units
    /// of the asset's decimals.
    /// @dev Because the deposited and the withdrawn amount are often read together, declaring them in
    /// the same slot saves gas.
    /// @param deposited The initial amount deposited in the stream, net of fees.
    /// @param withdrawn The cumulative amount withdrawn from the stream.
    /// @param refunded The amount refunded to the sender. Unless the stream was canceled, this is always zero.
    struct Amounts {
        // slot 0
        uint128 deposited;
        uint128 withdrawn;
        // slot 1
        uint128 refunded;
    }

    /// @notice Struct encapsulating the deposit amount, the protocol fee amount, and the broker fee amount,
    /// all denoted in units of the asset's decimals.
    /// @param deposit The amount to deposit in the stream.
    /// @param protocolFee The protocol fee amount.
    /// @param brokerFee The broker fee amount.
    struct CreateAmounts {
        uint128 deposit;
        uint128 protocolFee;
        uint128 brokerFee;
    }

    /// @notice Enum representing the different statuses of a stream.
    /// @custom:value PENDING Stream created but not started; assets are in a pending state.
    /// @custom:value STREAMING Active stream where assets are currently being streamed.
    /// @custom:value SETTLED All assets have been streamed; recipient is due to withdraw them.
    /// @custom:value CANCELED Canceled stream; remaining assets await recipient's withdrawal.
    /// @custom:value DEPLETED Depleted stream; all assets have been withdrawn and/or refunded.
    enum Status {
        PENDING, // value 0
        STREAMING, // value 1
        SETTLED, // value 2
        CANCELED, // value 3
        DEPLETED // value 4
    }
}
