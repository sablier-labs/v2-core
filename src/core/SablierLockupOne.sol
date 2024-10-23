// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

import { SablierLockup } from "./abstracts/SablierLockup.sol";
import { ILockupNFTDescriptor } from "./interfaces/ILockupNFTDescriptor.sol";
import { ISablierLockupOne } from "./interfaces/ISablierLockupOne.sol";
import { Errors } from "./libraries/Errors.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { Lockup, LockupDynamic, LockupLinear, LockupTranched } from "./types/DataTypes.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ██╗      ██████╗  ██████╗██╗  ██╗██╗   ██╗██████╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██║     ██╔═══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    ██║     ██║   ██║██║     █████╔╝ ██║   ██║██████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ██║     ██║   ██║██║     ██╔═██╗ ██║   ██║██╔═══╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║    ███████╗╚██████╔╝╚██████╗██║  ██╗╚██████╔╝██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/

/// @title SablierLockupOne
/// @notice See the documentation in {ISablierLockupOne}.
contract SablierLockupOne is ISablierLockupOne, SablierLockup {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockupOne
    uint256 public immutable override MAX_COUNT;

    /// @dev Cliff times mapped by stream IDs.
    mapping(uint256 => uint40) internal _cliffs;

    /// @dev Stream segments mapped by stream IDs. This is useful for lockup dynamic streams..
    mapping(uint256 => LockupDynamic.Segment[]) internal _segments;

    /// @dev Stream tranches mapped by stream IDs. This is useful for lockup tranched streams.
    mapping(uint256 => LockupTranched.Tranche[]) internal _tranches;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Emits a {TransferAdmin} event.
    /// @param initialAdmin The address of the initial contract admin.
    /// @param initialNFTDescriptor The address of the NFT descriptor contract.
    /// @param maxCount The maximum number of segments and tranched allowed in a stream.
    constructor(
        address initialAdmin,
        ILockupNFTDescriptor initialNFTDescriptor,
        uint256 maxCount
    )
        ERC721("Sablier Lockup NFT", "SAB-LOCKUP")
        SablierLockup(initialAdmin, initialNFTDescriptor)
    {
        MAX_COUNT = maxCount;
        nextStreamId = 1;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockupOne
    function getCliffTime(uint256 streamId) external view override notNull(streamId) returns (uint40 cliffTime) {
        if (_streams[streamId].family != Lockup.Family.LOCKUP_LINEAR) {
            revert Errors.SablierLockup_NotLinearFamily(_streams[streamId].family);
        }

        cliffTime = _cliffs[streamId];
    }

    /// @inheritdoc ISablierLockupOne
    function getSegments(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (LockupDynamic.Segment[] memory segments)
    {
        if (_streams[streamId].family != Lockup.Family.LOCKUP_DYNAMIC) {
            revert Errors.SablierLockup_NotDynamicFamily(_streams[streamId].family);
        }

        segments = _segments[streamId];
    }

    /// @inheritdoc ISablierLockupOne
    function getStreamType(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (Lockup.Family streamFamily)
    {
        return _streams[streamId].family;
    }

    /// @inheritdoc ISablierLockupOne
    function getTimestamps(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (Lockup.Timestamps memory timestamps)
    {
        timestamps = Lockup.Timestamps({
            start: _streams[streamId].startTime,
            cliff: _cliffs[streamId],
            end: _streams[streamId].endTime
        });
    }

    /// @inheritdoc ISablierLockupOne
    function getTranches(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (LockupTranched.Tranche[] memory tranches)
    {
        if (_streams[streamId].family != Lockup.Family.LOCKUP_TRANCHED) {
            revert Errors.SablierLockup_NotTranchedFamily(_streams[streamId].family);
        }

        tranches = _tranches[streamId];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockupOne
    function createWithDurationsLD(
        Lockup.CreateWithDurations calldata params,
        LockupDynamic.SegmentWithDuration[] calldata segments
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Generate the canonical segments.
        LockupDynamic.Segment[] memory segments_ = Helpers.calculateSegmentTimestamps(segments);

        // Checks, Effects and Interactions: create the stream.
        streamId = _createLD(
            Lockup.CreateWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                totalAmount: params.totalAmount,
                asset: params.asset,
                cancelable: params.cancelable,
                transferable: params.transferable,
                startTime: uint40(block.timestamp),
                broker: params.broker
            }),
            segments_
        );
    }

    /// @inheritdoc ISablierLockupOne
    function createWithTimestampsLD(
        Lockup.CreateWithTimestamps calldata params,
        LockupDynamic.Segment[] calldata segments
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Checks, Effects and Interactions: create the stream.
        streamId = _createLD(params, segments);
    }

    /// @inheritdoc ISablierLockupOne
    function createWithDurationsLL(
        Lockup.CreateWithDurations calldata params,
        LockupLinear.Durations calldata durations
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Set the current block timestamp as the stream's start time.
        Lockup.Timestamps memory timestamps;
        timestamps.start = uint40(block.timestamp);

        // Calculate the cliff time and the end time. It is safe to use unchecked arithmetic because {_create} will
        // nonetheless check that the end time is greater than the cliff time, and also that the cliff time, if set,
        // is greater than or equal to the start time.
        unchecked {
            if (durations.cliff > 0) {
                timestamps.cliff = timestamps.start + durations.cliff;
            }
            timestamps.end = timestamps.start + durations.total;
        }

        // Checks, Effects and Interactions: create the stream.
        streamId = _createLL(
            Lockup.CreateWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                totalAmount: params.totalAmount,
                asset: params.asset,
                cancelable: params.cancelable,
                transferable: params.transferable,
                startTime: timestamps.start,
                broker: params.broker
            }),
            timestamps.cliff,
            timestamps.end
        );
    }

    /// @inheritdoc ISablierLockupOne
    function createWithTimestampsLL(
        Lockup.CreateWithTimestamps calldata params,
        uint40 cliffTime,
        uint40 endTime
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Checks, Effects and Interactions: create the stream.
        streamId = _createLL(params, cliffTime, endTime);
    }

    /// @inheritdoc ISablierLockupOne
    function createWithDurationsLT(
        Lockup.CreateWithDurations calldata params,
        LockupTranched.TrancheWithDuration[] calldata tranches
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Generate the canonical tranches.
        LockupTranched.Tranche[] memory tranches_ = Helpers.calculateTrancheTimestamps(tranches);

        // Checks, Effects and Interactions: create the stream.
        streamId = _createLT(
            Lockup.CreateWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                totalAmount: params.totalAmount,
                asset: params.asset,
                cancelable: params.cancelable,
                transferable: params.transferable,
                startTime: uint40(block.timestamp),
                broker: params.broker
            }),
            tranches_
        );
    }

    /// @inheritdoc ISablierLockupOne
    function createWithTimestampsLT(
        Lockup.CreateWithTimestamps calldata params,
        LockupTranched.Tranche[] calldata tranches
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Checks, Effects and Interactions: create the stream.
        streamId = _createLT(params, tranches);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc SablierLockup
    function _calculateStreamedAmount(uint256 streamId) internal view override returns (uint128 streamedAmount) {
        if (_streams[streamId].family == Lockup.Family.LOCKUP_LINEAR) {
            streamedAmount = _calculateStreamedAmountLL(streamId);
        } else if (_streams[streamId].family == Lockup.Family.LOCKUP_DYNAMIC) {
            streamedAmount = _calculateStreamedAmountLD(streamId);
        } else if (_streams[streamId].family == Lockup.Family.LOCKUP_TRANCHED) {
            streamedAmount = _calculateStreamedAmountLT(streamId);
        }
    }

    /// @dev The distribution function is for Lockup Dynamic streams:
    ///
    /// $$
    /// f(x) = x^{exp} * csa + \Sigma(esa)
    /// $$
    ///
    /// Where:
    ///
    /// - $x$ is the elapsed time divided by the total duration of the current segment.
    /// - $exp$ is the current segment exponent.
    /// - $csa$ is the current segment amount.
    /// - $\Sigma(esa)$ is the sum of all vested segments' amounts.
    function _calculateStreamedAmountLD(uint256 streamId) internal view returns (uint128) {
        // If the start time is in the future, return zero.
        uint40 blockTimestamp = uint40(block.timestamp);
        if (_streams[streamId].startTime >= blockTimestamp) {
            return 0;
        }

        // If the end time is not in the future, return the deposited amount.
        uint40 endTime = _streams[streamId].endTime;
        if (endTime <= blockTimestamp) {
            return _streams[streamId].amounts.deposited;
        }

        // Otherwise, there is only one segment, and the calculation is simpler.
        return Helpers.calculateStreamedAmountForSegments(_streams[streamId], _segments[streamId]);
    }

    /// @dev The distribution function is for Lockup Linear streams:
    ///
    /// $$
    /// f(x) = x * d + c
    /// $$
    ///
    /// Where:
    ///
    /// - $x$ is the elapsed time divided by the stream's total duration.
    /// - $d$ is the deposited amount.
    /// - $c$ is the cliff amount.
    function _calculateStreamedAmountLL(uint256 streamId) internal view returns (uint128) {
        uint256 cliffTime = uint256(_cliffs[streamId]);
        uint256 startTime = uint256(_streams[streamId].startTime);
        uint256 blockTimestamp = block.timestamp;

        // If the cliff time or the start time is in the future, return zero.
        if (cliffTime > blockTimestamp || startTime >= blockTimestamp) {
            return 0;
        }

        // If the end time is not in the future, return the deposited amount.
        uint256 endTime = uint256(_streams[streamId].endTime);
        if (blockTimestamp >= endTime) {
            return _streams[streamId].amounts.deposited;
        }

        // In all other cases, calculate the amount streamed so far. Normalization to 18 decimals is not needed
        // because there is no mix of amounts with different decimals.
        unchecked {
            // Calculate how much time has passed since the stream started, and the stream's total duration.
            UD60x18 elapsedTime = ud(blockTimestamp - startTime);
            UD60x18 totalDuration = ud(endTime - startTime);

            // Divide the elapsed time by the stream's total duration.
            UD60x18 elapsedTimePercentage = elapsedTime.div(totalDuration);

            // Cast the deposited amount to UD60x18.
            UD60x18 depositedAmount = ud(_streams[streamId].amounts.deposited);

            // Calculate the streamed amount by multiplying the elapsed time percentage by the deposited amount.
            UD60x18 streamedAmount = elapsedTimePercentage.mul(depositedAmount);

            // Although the streamed amount should never exceed the deposited amount, this condition is checked
            // without asserting to avoid locking assets in case of a bug. If this situation occurs, the withdrawn
            // amount is considered to be the streamed amount, and the stream is effectively frozen.
            if (streamedAmount.gt(depositedAmount)) {
                return _streams[streamId].amounts.withdrawn;
            }

            // Cast the streamed amount to uint128. This is safe due to the check above.
            return uint128(streamedAmount.intoUint256());
        }
    }

    /// @dev The distribution function is for Lockup Tranched streams:
    ///
    /// $$
    /// f(x) = \Sigma(eta)
    /// $$
    ///
    /// Where:
    ///
    /// - $\Sigma(eta)$ is the sum of all vested tranches' amounts.
    function _calculateStreamedAmountLT(uint256 streamId) internal view returns (uint128) {
        uint40 blockTimestamp = uint40(block.timestamp);
        LockupTranched.Tranche[] memory tranches = _tranches[streamId];

        // If the first tranche's timestamp is in the future, return zero.
        if (tranches[0].timestamp > blockTimestamp) {
            return 0;
        }

        // If the end time is not in the future, return the deposited amount.
        if (_streams[streamId].endTime <= blockTimestamp) {
            return _streams[streamId].amounts.deposited;
        }

        // Sum the amounts in all tranches that have already been vested.
        // Using unchecked arithmetic is safe because the sum of the tranche amounts is equal to the total amount
        // at this point.
        uint128 streamedAmount = tranches[0].amount;
        for (uint256 i = 1; i < tranches.length; ++i) {
            // The loop breaks at the first tranche with a timestamp in the future. A tranche is considered vested if
            // its timestamp is less than or equal to the block timestamp.
            if (tranches[i].timestamp > blockTimestamp) {
                break;
            }
            unchecked {
                streamedAmount += tranches[i].amount;
            }
        }

        return streamedAmount;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _create(
        Lockup.CreateWithTimestamps memory params,
        Lockup.CreateAmounts memory createAmounts,
        uint40 endTime,
        Lockup.Family family
    )
        internal
        returns (uint256 streamId)
    {
        // Load the stream ID in a variable.
        streamId = nextStreamId;

        // Effect: create the stream.
        Lockup.Stream storage stream = _streams[streamId];
        stream.amounts.deposited = createAmounts.deposit;
        stream.asset = params.asset;
        stream.isCancelable = params.cancelable;
        stream.isStream = true;
        stream.isTransferable = params.transferable;
        stream.family = family;
        stream.sender = params.sender;
        stream.startTime = params.startTime;
        stream.endTime = endTime;

        // Effect: mint the NFT to the recipient.
        _mint({ to: params.recipient, tokenId: streamId });

        // Interaction: transfer the deposit amount.
        params.asset.safeTransferFrom({ from: msg.sender, to: address(this), value: createAmounts.deposit });

        // Interaction: pay the broker fee, if not zero.
        if (createAmounts.brokerFee > 0) {
            params.asset.safeTransferFrom({ from: msg.sender, to: params.broker.account, value: createAmounts.brokerFee });
        }

        unchecked {
            // Effect: bump the next stream ID.
            nextStreamId = streamId + 1;
        }

        // Log the newly created stream.
        emit ISablierLockupOne.CreateLockupStream({
            streamId: streamId,
            funder: msg.sender,
            sender: params.sender,
            recipient: params.recipient,
            amounts: createAmounts,
            asset: params.asset,
            cancelable: params.cancelable,
            transferable: params.transferable,
            timestamps: Lockup.Timestamps({ start: stream.startTime, end: stream.endTime, cliff: 0 }),
            broker: params.broker.account
        });
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLD(
        Lockup.CreateWithTimestamps memory params,
        LockupDynamic.Segment[] memory segments
    )
        internal
        returns (uint256 streamId)
    {
        // Check: verify the broker fee and calculate the amounts.
        Lockup.CreateAmounts memory createAmounts =
            Helpers.checkAndCalculateBrokerFee(params.totalAmount, params.broker.fee, MAX_BROKER_FEE);

        // Check: validate the user-provided parameters.
        Helpers.checkCreateLockupDynamic(params.sender, createAmounts.deposit, segments, MAX_COUNT, params.startTime);

        uint40 endTime;
        unchecked {
            // The segment count cannot be zero at this point.
            uint256 segmentCount = segments.length;
            endTime = segments[segmentCount - 1].timestamp;

            // Effect: store the segments. Since Solidity lacks a syntax for copying arrays of structs directly from
            // memory to storage, a manual approach is necessary. See https://github.com/ethereum/solidity/issues/12783.
            for (uint256 i = 0; i < segmentCount; ++i) {
                _segments[streamId].push(segments[i]);
            }
        }

        streamId = _create(params, createAmounts, endTime, Lockup.Family.LOCKUP_DYNAMIC);

        // Log the segments.
        emit ISablierLockupOne.Segments({ streamId: streamId, segments: segments });
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLL(
        Lockup.CreateWithTimestamps memory params,
        uint40 cliffTime,
        uint40 endTime
    )
        internal
        returns (uint256 streamId)
    {
        // Check: verify the broker fee and calculate the amounts.
        Lockup.CreateAmounts memory createAmounts =
            Helpers.checkAndCalculateBrokerFee(params.totalAmount, params.broker.fee, MAX_BROKER_FEE);

        // Check: validate the user-provided parameters.
        Helpers.checkCreateLockupLinear(params.sender, createAmounts.deposit, params.startTime, cliffTime, endTime);

        if (cliffTime > 0) {
            _cliffs[streamId] = cliffTime;
        }

        streamId = _create(params, createAmounts, endTime, Lockup.Family.LOCKUP_LINEAR);
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLT(
        Lockup.CreateWithTimestamps memory params,
        LockupTranched.Tranche[] memory tranches
    )
        internal
        returns (uint256 streamId)
    {
        // Check: verify the broker fee and calculate the amounts.
        Lockup.CreateAmounts memory createAmounts =
            Helpers.checkAndCalculateBrokerFee(params.totalAmount, params.broker.fee, MAX_BROKER_FEE);

        // Check: validate the user-provided parameters.
        Helpers.checkCreateLockupTranched(params.sender, createAmounts.deposit, tranches, MAX_COUNT, params.startTime);

        uint40 endTime;
        unchecked {
            // The tranche count cannot be zero at this point.
            uint256 trancheCount = tranches.length;
            endTime = tranches[trancheCount - 1].timestamp;

            // Effect: store the tranches. Since Solidity lacks a syntax for copying arrays of structs directly from
            // memory to storage, a manual approach is necessary. See https://github.com/ethereum/solidity/issues/12783.
            for (uint256 i = 0; i < trancheCount; ++i) {
                _tranches[streamId].push(tranches[i]);
            }
        }

        streamId = _create(params, createAmounts, endTime, Lockup.Family.LOCKUP_TRANCHED);

        // Log the tranches.
        emit ISablierLockupOne.Tranches({ streamId: streamId, tranches: tranches });
    }
}
