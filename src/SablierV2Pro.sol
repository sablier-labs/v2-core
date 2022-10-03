// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { ERC721 } from "@solmate/tokens/ERC721.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { SafeERC20 } from "@prb/contracts/token/erc20/SafeERC20.sol";
import { SCALE, SD59x18, toSD59x18, ZERO } from "@prb/math/SD59x18.sol";

import { DataTypes } from "./libraries/DataTypes.sol";
import { Events } from "./libraries/Events.sol";
import { Validations } from "./libraries/Validations.sol";

import { ISablierV2 } from "./interfaces/ISablierV2.sol";
import { ISablierV2Pro } from "./interfaces/ISablierV2Pro.sol";
import { SablierV2 } from "./SablierV2.sol";

/// @title SablierV2Pro
/// @author Sablier Labs Ltd.
contract SablierV2Pro is
    ERC721("Sablier V2 Pro", "SAB-V2-PRO"), // one dependency
    ISablierV2Pro, // one dependency
    SablierV2 // two dependencies
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The maximum value an exponent can have is 10.
    SD59x18 public constant MAX_EXPONENT = SD59x18.wrap(10e18);

    /// @notice The maximum number of segments allowed in a stream.
    uint256 public immutable MAX_SEGMENT_COUNT;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sablier V2 pro streams mapped by unsigned integers.
    mapping(uint256 => DataTypes.ProStream) internal _streams;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(uint256 maxSegmentCount) {
        MAX_SEGMENT_COUNT = maxSegmentCount;
    }

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2
    function getDepositAmount(uint256 streamId) public view override returns (uint256 depositAmount) {
        uint256[] memory segmentAmounts = _streams[streamId].segmentAmounts;
        for (uint256 i = 0; i < segmentAmounts.length; ) {
            depositAmount += segmentAmounts[i];
            unchecked {
                i += 1;
            }
        }
    }

    /// @inheritdoc ISablierV2
    function getRecipient(uint256 streamId) public view override(ISablierV2, SablierV2) returns (address recipient) {
        recipient = _ownerOf[streamId];
    }

    /// @inheritdoc ISablierV2
    function getReturnableAmount(uint256 streamId) external view returns (uint256 returnableAmount) {
        // If the stream does not exist, return zero.
        if (_streams[streamId].sender == address(0)) {
            return 0;
        }

        unchecked {
            uint256 withdrawableAmount = getWithdrawableAmount(streamId);
            returnableAmount = getDepositAmount(streamId) - _streams[streamId].withdrawnAmount - withdrawableAmount;
        }
    }

    /// @inheritdoc ISablierV2
    function getSender(uint256 streamId) public view override(ISablierV2, SablierV2) returns (address sender) {
        sender = _streams[streamId].sender;
    }

    /// @inheritdoc ISablierV2Pro
    function getSegmentAmounts(uint256 streamId) external view override returns (uint256[] memory segmentAmounts) {
        segmentAmounts = _streams[streamId].segmentAmounts;
    }

    /// @inheritdoc ISablierV2Pro
    function getSegmentExponents(uint256 streamId) external view override returns (SD59x18[] memory segmentExponents) {
        segmentExponents = _streams[streamId].segmentExponents;
    }

    /// @inheritdoc ISablierV2Pro
    function getSegmentMilestones(uint256 streamId) external view override returns (uint64[] memory segmentMilestones) {
        segmentMilestones = _streams[streamId].segmentMilestones;
    }

    /// @inheritdoc ISablierV2
    function getStartTime(uint256 streamId) external view override returns (uint64 startTime) {
        startTime = _streams[streamId].startTime;
    }

    /// @inheritdoc ISablierV2
    function getStopTime(uint256 streamId) external view override returns (uint64 stopTime) {
        stopTime = _streams[streamId].stopTime;
    }

    /// @inheritdoc ISablierV2Pro
    function getStream(uint256 streamId) external view returns (DataTypes.ProStream memory stream) {
        return _streams[streamId];
    }

    /// @inheritdoc ISablierV2
    function getWithdrawableAmount(uint256 streamId) public view returns (uint256 withdrawableAmount) {
        // If the stream does not exist, return zero.
        if (_streams[streamId].sender == address(0)) {
            return 0;
        }

        // If the start time is greater than or equal to the block timestamp, return zero.
        uint256 currentTime = block.timestamp;

        if (uint256(_streams[streamId].startTime) >= currentTime) {
            return 0;
        }

        unchecked {
            // If the current time is greater than or equal to the stop time, return the deposit minus
            // the withdrawn amount.
            if (currentTime >= uint256(_streams[streamId].stopTime)) {
                return getDepositAmount(streamId) - _streams[streamId].withdrawnAmount;
            }

            // Define the common variables used in the calculations below.
            SD59x18 currentSegmentAmount;
            SD59x18 currentSegmentExponent;
            SD59x18 elapsedSegmentTime;
            SD59x18 totalSegmentTime;
            uint256 previousSegmentAmounts;

            // If there's more than one segment, we have to iterate over all of them.
            uint256 segmentCount = _streams[streamId].segmentAmounts.length;
            if (segmentCount > 1) {
                // Sum up the amounts found in all preceding segments. Set the sum to the negation of the first segment
                // amount such that we avoid adding an if statement in the while loop.
                uint256 currentSegmentMilestone = uint256(_streams[streamId].segmentMilestones[0]);
                uint256 index = 1;
                while (currentSegmentMilestone < currentTime) {
                    previousSegmentAmounts += _streams[streamId].segmentAmounts[index - 1];
                    currentSegmentMilestone = uint256(_streams[streamId].segmentMilestones[index]);
                    index += 1;
                }

                // After the loop exits, the current segment is found at index `index - 1`, while the previous segment
                // is found at `index - 2`.
                currentSegmentAmount = SD59x18.wrap(int256(_streams[streamId].segmentAmounts[index - 1]));
                currentSegmentExponent = _streams[streamId].segmentExponents[index - 1];
                currentSegmentMilestone = uint256(_streams[streamId].segmentMilestones[index - 1]);

                // If the current segment is at an index that is >= 2, take the difference between the current segment
                // milestone and the previous segment milestone.
                if (index > 1) {
                    uint256 previousSegmentMilestone = uint256(_streams[streamId].segmentMilestones[index - 2]);
                    elapsedSegmentTime = toSD59x18(int256(currentTime - previousSegmentMilestone));

                    // Calculate the time between the current segment milestone and the previous segment milestone.
                    totalSegmentTime = toSD59x18(int256(currentSegmentMilestone - previousSegmentMilestone));
                }
                // If the current segment is at index 1, take the difference between the current segment milestone and
                // the start time of the stream.
                else {
                    elapsedSegmentTime = toSD59x18(int256(currentTime - uint256(_streams[streamId].startTime)));
                    totalSegmentTime = toSD59x18(
                        int256(currentSegmentMilestone - uint256(_streams[streamId].startTime))
                    );
                }
            }
            // Otherwise, if there's only one segment, we use the start time of the stream in the calculations.
            else {
                currentSegmentAmount = SD59x18.wrap(int256(_streams[streamId].segmentAmounts[0]));
                currentSegmentExponent = _streams[streamId].segmentExponents[0];
                elapsedSegmentTime = toSD59x18(int256(currentTime - uint256(_streams[streamId].startTime)));
                totalSegmentTime = toSD59x18(
                    int256(uint256(_streams[streamId].stopTime) - uint256(_streams[streamId].startTime))
                );
            }

            // Calculate the streamed amount.
            SD59x18 elapsedTimePercentage = elapsedSegmentTime.div(totalSegmentTime);
            SD59x18 multiplier = elapsedTimePercentage.pow(currentSegmentExponent);
            SD59x18 proRataAmount = multiplier.mul(currentSegmentAmount);
            SD59x18 streamedAmount = SD59x18.wrap(int256(previousSegmentAmounts)).add(proRataAmount);
            SD59x18 withdrawnAmount = SD59x18.wrap(int256(_streams[streamId].withdrawnAmount));
            withdrawableAmount = uint256(SD59x18.unwrap(streamedAmount.uncheckedSub(withdrawnAmount)));
        }
    }

    /// @inheritdoc ISablierV2
    function getWithdrawnAmount(uint256 streamId) external view override returns (uint256 withdrawnAmount) {
        withdrawnAmount = _streams[streamId].withdrawnAmount;
    }

    /// @inheritdoc ISablierV2
    function isApprovedOrOwner(uint256 streamId) public view override(ISablierV2, SablierV2) returns (bool) {
        address owner = _ownerOf[streamId];
        return (msg.sender == owner || isApprovedForAll[owner][msg.sender] || getApproved[streamId] == msg.sender);
    }

    /// @inheritdoc ISablierV2
    function isCancelable(uint256 streamId) public view override(ISablierV2, SablierV2) returns (bool cancelable) {
        cancelable = _streams[streamId].cancelable;
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 streamId) public view override streamExists(streamId) returns (string memory) {
        return "";
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierV2Pro
    function create(
        address sender,
        address recipient,
        uint256 depositAmount,
        IERC20 token,
        uint64 startTime,
        uint256[] memory segmentAmounts,
        SD59x18[] memory segmentExponents,
        uint64[] memory segmentMilestones,
        bool cancelable
    ) external returns (uint256 streamId) {
        // Checks, Effects and Interactions: create the stream.
        streamId = _create(
            sender,
            recipient,
            depositAmount,
            token,
            startTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones,
            cancelable
        );
    }

    /// @inheritdoc ISablierV2Pro
    function createWithDuration(
        address sender,
        address recipient,
        uint256 depositAmount,
        IERC20 token,
        uint256[] memory segmentAmounts,
        SD59x18[] memory segmentExponents,
        uint64[] memory segmentDeltas,
        bool cancelable
    ) external override returns (uint256 streamId) {
        uint64 startTime = uint64(block.timestamp);
        uint256 deltaCount = segmentDeltas.length;

        // Calculate the segment milestones. It is fine to use unchecked arithmetic because the `_create`
        // function will nonetheless check the segments.
        uint64[] memory segmentMilestones = new uint64[](deltaCount);
        unchecked {
            segmentMilestones[0] = startTime + segmentDeltas[0];
            for (uint256 i = 1; i < deltaCount; ) {
                segmentMilestones[i] = segmentMilestones[i - 1] + segmentDeltas[i];
                i += 1;
            }
        }

        // Checks, Effects and Interactions: create the stream.
        streamId = _create(
            sender,
            recipient,
            depositAmount,
            token,
            startTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones,
            cancelable
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the public functions that call this internal function.
    function _cancel(uint256 streamId) internal override isAuthorizedForStream(streamId) {
        DataTypes.ProStream memory stream = _streams[streamId];

        // Calculate the withdraw and the return amounts.
        uint256 withdrawAmount = getWithdrawableAmount(streamId);
        uint256 returnAmount;
        unchecked {
            returnAmount = getDepositAmount(streamId) - stream.withdrawnAmount - withdrawAmount;
        }

        address recipient = getRecipient(streamId);

        // Effects: delete the stream from storage.
        delete _streams[streamId];

        // Interactions: withdraw the tokens to the recipient, if any.
        if (withdrawAmount > 0) {
            stream.token.safeTransfer(recipient, withdrawAmount);
        }

        // Interactions: return the tokens to the sender, if any.
        if (returnAmount > 0) {
            stream.token.safeTransfer(stream.sender, returnAmount);
        }

        // Emit an event.
        emit Events.Cancel(streamId, recipient, withdrawAmount, returnAmount);
    }

    /// @dev See the documentation for the public functions that call this internal function.
    function _create(
        address sender,
        address recipient,
        uint256 depositAmount,
        IERC20 token,
        uint64 startTime,
        uint256[] memory segmentAmounts,
        SD59x18[] memory segmentExponents,
        uint64[] memory segmentMilestones,
        bool cancelable
    ) internal returns (uint256 streamId) {
        // Validates the requirements for the `create` function.
        uint64 stopTime = Validations.proCreate(
            sender,
            recipient,
            depositAmount,
            startTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones,
            MAX_EXPONENT,
            MAX_SEGMENT_COUNT
        );

        // Effects: create and store the stream.
        streamId = nextStreamId;
        _streams[streamId] = DataTypes.ProStream({
            cancelable: cancelable,
            segmentAmounts: segmentAmounts,
            segmentExponents: segmentExponents,
            segmentMilestones: segmentMilestones,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: token,
            withdrawnAmount: 0
        });

        // Effects: mint the NFT to the recipient's address.
        _mint(recipient, streamId);

        // Effects: bump the next stream id. This cannot realistically overflow, ever.
        unchecked {
            nextStreamId = streamId + 1;
        }

        // Interactions: perform the ERC-20 transfer.
        token.safeTransferFrom(msg.sender, address(this), depositAmount);

        // Emit an event.
        emit Events.CreateProStream(
            streamId,
            msg.sender,
            sender,
            recipient,
            depositAmount,
            token,
            startTime,
            stopTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones,
            cancelable
        );
    }

    /// @dev See the documentation for the public functions that call this internal function.
    function _renounce(uint256 streamId) internal override {
        // Effects: make the stream non-cancelable.
        _streams[streamId].cancelable = false;

        // Emit an event.
        emit Events.Renounce(streamId);
    }

    /// @dev See the documentation for the public functions that call this internal function.
    function _withdraw(
        uint256 streamId,
        address to,
        uint256 amount
    ) internal override {
        // Validates the requirements for the `amount` argument.
        Validations.withdrawAmount(streamId, amount, getWithdrawableAmount(streamId));

        // Effects: update the withdrawn amount.
        unchecked {
            _streams[streamId].withdrawnAmount += amount;
        }

        // Load the stream in memory, we will need it below.
        DataTypes.ProStream memory stream = _streams[streamId];

        // Effects: if this stream is done, save gas by deleting it from storage.
        if (getDepositAmount(streamId) == stream.withdrawnAmount) {
            delete _streams[streamId];
        }

        // Interactions: perform the ERC-20 transfer.
        stream.token.safeTransfer(to, amount);

        // Emit an event.
        emit Events.Withdraw(streamId, to, amount);
    }
}
