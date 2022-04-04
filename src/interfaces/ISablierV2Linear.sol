// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.4;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { ISablierV2 } from "./ISablierV2.sol";

/// @notice The interface of the SablierV2Linear contract.
/// @author Sablier Labs Ltd.
interface ISablierV2Linear is ISablierV2 {
    /// EVENTS ///

    /// @notice Emitted when a linear stream is created.
    event CreateLinearStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    );

    /// STRUCTS ///

    /// @notice Linear stream parameters.
    struct LinearStream {
        uint256 deposit;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        IERC20 token;
    }

    /// NON-CONSTANT FUNCTIONS ///

    /// @notice Creates a new stream funded by `msg.sender` and paid toward `recipient`.
    ///
    /// @dev Emits a `CreateLinearStream` event.
    ///
    /// Requirements:
    /// - `recipient` cannot be the zero address.
    /// - `deposit` cannot be zero.
    /// - `startTime` cannot be after the stop time.
    /// - `msg.sender` must have allowed this contract to spend `deposit` tokens.
    ///
    /// @param recipient The address toward which to stream the money.
    /// @param deposit The amount of money to be streamed.
    /// @param token The address of the ERC-20 token to use for streaming.
    /// @param startTime The unix timestamp in seconds for when the stream starts.
    /// @param stopTime The unix timestamp in seconds for when the stream stops.
    /// @return streamId The id of the newly created stream.
    function create(
        address recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256 streamId);

    /// @notice Creates a new stream funded by provided `sender` and paid toward `recipient`.
    ///
    /// @dev Emits a `CreateLinearStream` event.
    ///
    /// Requirements:
    /// - `sender` cannot be the zero address.
    /// - `recipient` cannot be the zero address.
    /// - `deposit` cannot be zero.
    /// - `startTime` cannot be after the stop time.
    /// - `sender` must have allowed this contract to spend `deposit` tokens.
    ///
    /// @param sender The address which funds the stream.
    /// @param recipient The address toward which to stream the money.
    /// @param deposit The amount of money to be streamed.
    /// @param token The address of the ERC-20 token to use for streaming.
    /// @param startTime The unix timestamp in seconds for when the stream starts.
    /// @param stopTime The unix timestamp in seconds for when the stream stops.
    /// @return streamId The id of the newly created stream.
    function createFrom(
        address sender,
        address recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256 streamId);
}
