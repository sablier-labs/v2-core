// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { SablierLockupBase } from "./abstracts/SablierLockupBase.sol";
import { ILockupNFTDescriptor } from "./interfaces/ILockupNFTDescriptor.sol";
import { ISablierLockup } from "./interfaces/ISablierLockup.sol";
import { Errors } from "./libraries/Errors.sol";
import { Helpers } from "./libraries/Helpers.sol";
import { VestingMath } from "./libraries/VestingMath.sol";
import { Lockup, LockupDynamic, LockupLinear, LockupTranched } from "./types/DataTypes.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ██╗      ██████╗  ██████╗██╗  ██╗██╗   ██╗██████╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██║     ██╔═══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    ██║     ██║   ██║██║     █████╔╝ ██║   ██║██████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ██║     ██║   ██║██║     ██╔═██╗ ██║   ██║██╔═══╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║    ███████╗╚██████╔╝╚██████╗██║  ██╗╚██████╔╝██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/

/// @title SablierLockup
/// @notice See the documentation in {ISablierLockup}.
contract SablierLockup is ISablierLockup, SablierLockupBase {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockup
    uint256 public immutable override MAX_COUNT;

    /// @dev Cliff timestamp mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 => uint40) internal _cliffs;

    /// @dev Stream segments mapped by stream IDs. This is used in Lockup Dynamic models.
    mapping(uint256 => LockupDynamic.Segment[]) internal _segments;

    /// @dev Stream tranches mapped by stream IDs. This is used in Lockup Tranched models.
    mapping(uint256 => LockupTranched.Tranche[]) internal _tranches;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialAdmin The address of the initial contract admin.
    /// @param initialNFTDescriptor The address of the NFT descriptor contract.
    /// @param maxCount The maximum number of segments and tranched allowed in a stream.
    constructor(
        address initialAdmin,
        ILockupNFTDescriptor initialNFTDescriptor,
        uint256 maxCount
    )
        ERC721("Sablier Lockup NFT", "SAB-LOCKUP")
        SablierLockupBase(initialAdmin, initialNFTDescriptor)
    {
        MAX_COUNT = maxCount;
        nextStreamId = 1;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockup
    function getCliff(uint256 streamId) external view override notNull(streamId) returns (uint40 cliff) {
        cliff = _cliffs[streamId];
    }

    /// @inheritdoc ISablierLockup
    function getSegments(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (LockupDynamic.Segment[] memory segments)
    {
        if (_streams[streamId].lockupModel != Lockup.Model.LOCKUP_DYNAMIC) {
            revert Errors.SablierLockup_NotDynamicDistribution(_streams[streamId].lockupModel);
        }

        segments = _segments[streamId];
    }

    /// @inheritdoc ISablierLockup
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

    /// @inheritdoc ISablierLockup
    function getTranches(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (LockupTranched.Tranche[] memory tranches)
    {
        if (_streams[streamId].lockupModel != Lockup.Model.LOCKUP_TRANCHED) {
            revert Errors.SablierLockup_NotTranchedDistribution(_streams[streamId].lockupModel);
        }

        tranches = _tranches[streamId];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierLockup
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
        LockupDynamic.Segment[] memory segments_ = VestingMath.calculateSegmentTimestamps(segments);

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
                endTime: segments_[segments_.length - 1].timestamp,
                broker: params.broker
            }),
            segments_
        );
    }

    /// @inheritdoc ISablierLockup
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

        // Calculate the cliff time and the end time. It is safe to use unchecked arithmetic because {_createLL} will
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
                endTime: timestamps.end,
                broker: params.broker
            }),
            timestamps.cliff
        );
    }

    /// @inheritdoc ISablierLockup
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
        LockupTranched.Tranche[] memory tranches_ = VestingMath.calculateTrancheTimestamps(tranches);

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
                endTime: tranches_[tranches_.length - 1].timestamp,
                broker: params.broker
            }),
            tranches_
        );
    }

    /// @inheritdoc ISablierLockup
    function createWithTimestampsLD(
        Lockup.CreateWithTimestamps calldata params,
        LockupDynamic.Segment[] calldata segments
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Check: `params.endTime` equals the last segment's timestamp.
        if (params.endTime != segments[segments.length - 1].timestamp) {
            revert Errors.SablierLockup_EndTimeNotEqualToLastSegmentTimestamp(
                params.endTime, segments[segments.length - 1].timestamp
            );
        }

        // Checks, Effects and Interactions: create the stream.
        streamId = _createLD(params, segments);
    }

    /// @inheritdoc ISablierLockup
    function createWithTimestampsLL(
        Lockup.CreateWithTimestamps calldata params,
        uint40 cliff
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Checks, Effects and Interactions: create the stream.
        streamId = _createLL(params, cliff);
    }

    /// @inheritdoc ISablierLockup
    function createWithTimestampsLT(
        Lockup.CreateWithTimestamps calldata params,
        LockupTranched.Tranche[] calldata tranches
    )
        external
        override
        noDelegateCall
        returns (uint256 streamId)
    {
        // Check: `params.endTime` equals the last tranche's timestamp.
        if (params.endTime != tranches[tranches.length - 1].timestamp) {
            revert Errors.SablierLockup_EndTimeNotEqualToLastTrancheTimestamp(
                params.endTime, tranches[tranches.length - 1].timestamp
            );
        }

        // Checks, Effects and Interactions: create the stream.
        streamId = _createLT(params, tranches);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc SablierLockupBase
    function _calculateStreamedAmount(uint256 streamId) internal view override returns (uint128 streamedAmount) {
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

        // Calculate streamed amount for Lockup Dynamic models.
        if (_streams[streamId].lockupModel == Lockup.Model.LOCKUP_DYNAMIC) {
            return VestingMath.calculateLockupDynamicStreamedAmount({
                segments: _segments[streamId],
                withdrawnAmount: _streams[streamId].amounts.withdrawn,
                startTime: _streams[streamId].startTime
            });
        }
        // Calculate streamed amount for Lockup Linear models.
        else if (_streams[streamId].lockupModel == Lockup.Model.LOCKUP_LINEAR) {
            // If the cliff time is in the future, return zero.
            if (_cliffs[streamId] > uint40(block.timestamp)) {
                return 0;
            }

            return VestingMath.calculateLockupLinearStreamedAmount({
                depositedAmount: _streams[streamId].amounts.deposited,
                withdrawnAmount: _streams[streamId].amounts.withdrawn,
                startTime: _streams[streamId].startTime,
                endTime: _streams[streamId].endTime
            });
        }
        // Calculate streamed amount for Lockup Tranched models.
        else if (_streams[streamId].lockupModel == Lockup.Model.LOCKUP_TRANCHED) {
            LockupTranched.Tranche[] memory tranches = _tranches[streamId];

            // If the first tranche's timestamp is in the future, return zero.
            if (tranches[0].timestamp > block.timestamp) {
                return 0;
            }

            return VestingMath.calculateLockupTranchedStreamedAmount({ tranches: tranches });
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _create(
        Lockup.CreateWithTimestamps memory params,
        Lockup.CreateAmounts memory createAmounts,
        Lockup.Model lockupModel
    )
        internal
        returns (uint256 streamId)
    {
        // Load the stream ID in a variable.
        streamId = nextStreamId;

        // Effect: create the stream.
        _streams[streamId] = Lockup.Stream({
            sender: params.sender,
            startTime: params.startTime,
            endTime: params.endTime,
            isCancelable: params.cancelable,
            wasCanceled: false,
            asset: params.asset,
            isDepleted: false,
            isStream: true,
            isTransferable: params.transferable,
            lockupModel: lockupModel,
            amounts: Lockup.Amounts({ deposited: createAmounts.deposit, withdrawn: 0, refunded: 0 })
        });

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
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLD(
        Lockup.CreateWithTimestamps memory params,
        LockupDynamic.Segment[] memory segments
    )
        internal
        returns (uint256 streamId)
    {
        // Check: validate the user-provided parameters and segments.
        Lockup.CreateAmounts memory createAmounts = Helpers.checkCreateLockupDynamic({
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.totalAmount,
            segments: segments,
            maxCount: MAX_COUNT,
            brokerFee: params.broker.fee,
            maxBrokerFee: MAX_BROKER_FEE
        });

        // Effect: store the segments. Since Solidity lacks a syntax for copying arrays of structs directly from
        // memory to storage, a manual approach is necessary. See https://github.com/ethereum/solidity/issues/12783.
        uint256 segmentCount = segments.length;
        for (uint256 i = 0; i < segmentCount; ++i) {
            _segments[streamId].push(segments[i]);
        }

        streamId = _create({ params: params, createAmounts: createAmounts, lockupModel: Lockup.Model.LOCKUP_DYNAMIC });

        // Log the newly created stream.
        emit ISablierLockup.CreateLockupDynamicStream({
            streamId: streamId,
            funder: msg.sender,
            sender: params.sender,
            recipient: params.recipient,
            amounts: createAmounts,
            asset: params.asset,
            cancelable: params.cancelable,
            transferable: params.transferable,
            timestamps: Lockup.Timestamps({ start: params.startTime, end: params.endTime, cliff: 0 }),
            broker: params.broker.account,
            segments: segments
        });
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLL(Lockup.CreateWithTimestamps memory params, uint40 cliff) internal returns (uint256 streamId) {
        // Check: validate the user-provided parameters and cliff.
        Lockup.CreateAmounts memory createAmounts = Helpers.checkCreateLockupLinear({
            sender: params.sender,
            startTime: params.startTime,
            cliffTime: cliff,
            endTime: params.endTime,
            totalAmount: params.totalAmount,
            brokerFee: params.broker.fee,
            maxBrokerFee: MAX_BROKER_FEE
        });

        if (cliff > 0) {
            _cliffs[streamId] = cliff;
        }

        streamId = _create({ params: params, createAmounts: createAmounts, lockupModel: Lockup.Model.LOCKUP_LINEAR });

        // Log the newly created stream.
        emit ISablierLockup.CreateLockupLinearStream({
            streamId: streamId,
            funder: msg.sender,
            sender: params.sender,
            recipient: params.recipient,
            amounts: createAmounts,
            asset: params.asset,
            cancelable: params.cancelable,
            transferable: params.transferable,
            timestamps: Lockup.Timestamps({ start: params.startTime, end: params.endTime, cliff: cliff }),
            broker: params.broker.account
        });
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _createLT(
        Lockup.CreateWithTimestamps memory params,
        LockupTranched.Tranche[] memory tranches
    )
        internal
        returns (uint256 streamId)
    {
        // Check: validate the user-provided parameters and tranches.
        Lockup.CreateAmounts memory createAmounts = Helpers.checkCreateLockupTranched({
            sender: params.sender,
            startTime: params.startTime,
            totalAmount: params.totalAmount,
            tranches: tranches,
            maxCount: MAX_COUNT,
            brokerFee: params.broker.fee,
            maxBrokerFee: MAX_BROKER_FEE
        });

        // Effect: store the tranches. Since Solidity lacks a syntax for copying arrays of structs directly from
        // memory to storage, a manual approach is necessary. See https://github.com/ethereum/solidity/issues/12783.
        uint256 trancheCount = tranches.length;
        for (uint256 i = 0; i < trancheCount; ++i) {
            _tranches[streamId].push(tranches[i]);
        }

        streamId = _create({ params: params, createAmounts: createAmounts, lockupModel: Lockup.Model.LOCKUP_TRANCHED });

        // Log the newly created stream.
        emit ISablierLockup.CreateLockupTranchedStream({
            streamId: streamId,
            funder: msg.sender,
            sender: params.sender,
            recipient: params.recipient,
            amounts: createAmounts,
            asset: params.asset,
            cancelable: params.cancelable,
            transferable: params.transferable,
            timestamps: Lockup.Timestamps({ start: params.startTime, end: params.endTime, cliff: 0 }),
            broker: params.broker.account,
            tranches: tranches
        });
    }
}
