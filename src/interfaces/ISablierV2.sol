// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.4;

/// @notice The common interface between all Sablier V2 streaming contracts.
/// @author Sablier Labs Ltd.
interface ISablierV2 {
    /// CUSTOM ERRORS ///

    /// @notice Emitted when creating a stream and the deposit is zero.
    error SablierV2__DepositZero();

    /// @notice Emitted when the user provides an id pointing to a nonexistent stream.
    error SablierV2__NonExistentStream(uint256 streamId);

    /// @notice Emitted when creating a stream and the recipient is the zero address.
    error SablierV2__RecipientZeroAddress();

    /// @notice Emitted when the stop time is after the start time.
    error SablierV2__StartTimeAfterStopTime(uint256 startTime, uint256 stopTime);

    /// @notice Emitted when the caller is not authorized to perform the call.
    error SablierV2__Unauthorized(address caller);

    /// EVENTS ///

    /// CONSTANT FUNCTIONS ///

    function getBasicStream(uint256 streamId) external view returns (uint256);

    function getStreamedAmount(uint256 streamId) external view returns (uint256);

    function getTimeDelta(uint256 streamId) external view returns (uint256);

    function getWithdrawableAmount(uint256 streamId) external view returns (uint256);

    function getWithdrawnAmount(uint256 streamId) external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    function cancel(uint256 streamId) external;

    function create(bytes calldata params) external returns (uint256 streamId);

    function createFrom(address sender, bytes memory params) external returns (uint256 streamId);

    function letGo(uint256 streamId) external;

    /// @notice Counter for stream ids.
    /// @return The next stream id;
    function nextStreamId() external view returns (uint256);

    function withdraw(uint256 streamId, uint256 amount) external;
}
