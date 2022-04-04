// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.4;

import { SafeERC20 } from "@prb/contracts/token/erc20/SafeERC20.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { ISablierV2 } from "./interfaces/ISablierV2.sol";
import { ISablierV2Linear } from "./interfaces/ISablierV2Linear.sol";

contract SablierV2Linear is ISablierV2Linear {
    using SafeERC20 for IERC20;

    /// PUBLIC STORAGE ///

    /// @inheritdoc ISablierV2
    uint256 public override nextStreamId;

    /// INTERNAL STORAGE ///

    /// @dev Sablier V2 streams mapped by unsigned integers.
    mapping(uint256 => LinearStream) internal streams;

    /// MODIFIERS ///

    /// @dev Checks that `streamId` points to a stream that exists.
    modifier streamExists(uint256 streamId) {
        if (streams[streamId].sender == address(0)) {
            revert SablierV2__NonExistentStream(streamId);
        }
        _;
    }

    /// @notice Checks that `msg.sender` is either the sender or the recipient of the stream.
    modifier onlySenderOrRecipient(uint256 streamId) {
        if (msg.sender != streams[streamId].sender && msg.sender != streams[streamId].recipient) {
            revert SablierV2__Unauthorized(msg.sender);
        }
        _;
    }

    /// CONSTRUCTOR ///

    constructor() {
        nextStreamId = 1;
    }

    /// CONSTANT FUNCTIONS ///

    function getBasicStream(uint256 streamId) external pure returns (uint256) {
        streamId;
        return 0;
    }

    function getStreamedAmount(uint256 streamId) external pure returns (uint256) {
        streamId;
        return 0;
    }

    function getTimeDelta(uint256 streamId) external pure returns (uint256) {
        streamId;
        return 0;
    }

    function getWithdrawableAmount(uint256 streamId) external pure returns (uint256) {
        streamId;
        return 0;
    }

    function getWithdrawnAmount(uint256 streamId) external pure returns (uint256) {
        streamId;
        return 0;
    }

    /// NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc ISablierV2
    function cancel(uint256 streamId) external view streamExists(streamId) onlySenderOrRecipient(streamId) {
        streamId;
    }

    /// @inheritdoc ISablierV2
    function create(bytes calldata params) external returns (uint256 streamId) {
        (address recipient, uint256 deposit, IERC20 token, uint256 startTime, uint256 stopTime) = abi.decode(
            params,
            (address, uint256, IERC20, uint256, uint256)
        );
        streamId = this.createFrom(msg.sender, recipient, deposit, token, startTime, stopTime);
    }

    /// @inheritdoc ISablierV2Linear
    function create(
        address recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256 streamId) {
        streamId = createInternal(msg.sender, recipient, deposit, token, startTime, stopTime);
    }

    /// @inheritdoc ISablierV2
    function createFrom(address sender, bytes memory params) public returns (uint256 streamId) {
        (address recipient, uint256 deposit, IERC20 token, uint256 startTime, uint256 stopTime) = abi.decode(
            params,
            (address, uint256, IERC20, uint256, uint256)
        );
        streamId = this.createFrom(sender, recipient, deposit, token, startTime, stopTime);
    }

    /// @inheritdoc ISablierV2Linear
    function createFrom(
        address sender,
        address recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    ) public returns (uint256 streamId) {
        // Checks: `msg.sender` is authorized to create this stream on behalf of `sender`.
        // TODO
        // Effects: reset permission
    }

    /// @inheritdoc ISablierV2
    function letGo(uint256 streamId) external pure {
        streamId;
    }

    /// @inheritdoc ISablierV2
    function withdraw(uint256 streamId, uint256 amount)
        external
        view
        streamExists(streamId)
        onlySenderOrRecipient(streamId)
    {
        streamId;
        amount;
    }

    /// INTERNAL FUNCTIONS ///

    /// @dev See the documentation for the public functions that call this internal function.
    function createInternal(
        address sender,
        address recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    ) internal returns (uint256 streamId) {
        // Checks: the recipient cannot be the zero address.
        if (recipient == address(0)) {
            revert SablierV2__RecipientZeroAddress();
        }

        // Checks: the deposit cannot be zero.
        if (deposit == 0) {
            revert SablierV2__DepositZero();
        }

        // Checks: the start time cannot be after the stop time.
        if (startTime > stopTime) {
            revert SablierV2__StartTimeAfterStopTime(startTime, stopTime);
        }

        // Create and store the stream.
        streamId = nextStreamId;
        streams[streamId] = LinearStream({
            deposit: deposit,
            recipient: recipient,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: token
        });

        // Effects: bump the next stream id.
        // We're using unchecked arithmetic because this cannot realistically overflow, ever.
        unchecked {
            nextStreamId = streamId + 1;
        }

        // Interactions: perform the ERC-20 transfer.

        token.safeTransferFrom(sender, address(this), deposit);

        // Emit an event.
        emit CreateLinearStream(streamId, sender, recipient, deposit, token, startTime, stopTime);
    }
}
