// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import { Lockup, LockupDynamic, LockupTranched } from "./../types/DataTypes.sol";
import { Errors } from "./Errors.sol";

/// @title Helpers
/// @notice Library with functions needed to validate input parameters across lockup streams.
library Helpers {
    /// @dev The maximum broker fee that can be charged by the broker, denoted as a fixed-point number where
    /// 1e18 is 100%.
    UD60x18 public constant MAX_BROKER_FEE = UD60x18.wrap(0.1e18);

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the parameters of the {SablierLockup-_createLD} function.
    function checkCreateLockupDynamic(
        address sender,
        Lockup.Timestamps memory timestamps,
        uint128 totalAmount,
        LockupDynamic.Segment[] memory segments,
        uint256 maxCount,
        UD60x18 brokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, timestamps.start);

        // Check: validate the user-provided segments.
        _checkSegments(segments, createAmounts.deposit, timestamps, maxCount);
    }

    /// @dev Checks the parameters of the {SablierLockup-_createLL} function.
    function checkCreateLockupLinear(
        address sender,
        Lockup.Timestamps memory timestamps,
        uint40 cliffTime,
        uint128 totalAmount,
        UD60x18 brokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, timestamps.start);

        // Since a cliff time of zero means there is no cliff, the following checks are performed only if it's not zero.
        if (cliffTime > 0) {
            // Check: the start time is strictly less than the cliff time.
            if (timestamps.start >= cliffTime) {
                revert Errors.SablierLockup_StartTimeNotLessThanCliffTime(timestamps.start, cliffTime);
            }

            // Check: the cliff time is strictly less than the end time.
            if (cliffTime >= timestamps.end) {
                revert Errors.SablierLockup_CliffTimeNotLessThanEndTime(cliffTime, timestamps.end);
            }
        }

        // Check: the start time is strictly less than the end time.
        if (timestamps.start >= timestamps.end) {
            revert Errors.SablierLockup_StartTimeNotLessThanEndTime(timestamps.start, timestamps.end);
        }
    }

    /// @dev Checks the parameters of the {SablierLockup-_createLT} function.
    function checkCreateLockupTranched(
        address sender,
        Lockup.Timestamps memory timestamps,
        uint128 totalAmount,
        LockupTranched.Tranche[] memory tranches,
        uint256 maxCount,
        UD60x18 brokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, timestamps.start);

        // Check: validate the user-provided segments.
        _checkTranches(tranches, createAmounts.deposit, timestamps, maxCount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the broker fee is not greater than `MAX_BROKER_FEE`, and then calculates the broker fee amount and
    /// the deposit amount from the total amount.
    function _checkAndCalculateBrokerFee(
        uint128 totalAmount,
        UD60x18 brokerFee
    )
        private
        pure
        returns (Lockup.CreateAmounts memory amounts)
    {
        // When the total amount is zero, the broker fee is also zero.
        if (totalAmount == 0) {
            return Lockup.CreateAmounts(0, 0);
        }

        // If the broker fee is zero, the deposit amount is the total amount.
        if (brokerFee.isZero()) {
            return Lockup.CreateAmounts(totalAmount, 0);
        }

        // Check: the broker fee is not greater than `MAX_BROKER_FEE`.
        if (brokerFee.gt(MAX_BROKER_FEE)) {
            revert Errors.SablierLockup_BrokerFeeTooHigh(brokerFee, MAX_BROKER_FEE);
        }

        // Calculate the broker fee amount.
        amounts.brokerFee = ud(totalAmount).mul(brokerFee).intoUint128();

        // Assert that the total amount is strictly greater than the broker fee amount.
        assert(totalAmount > amounts.brokerFee);

        // Calculate the deposit amount (the amount to stream, net of the broker fee).
        amounts.deposit = totalAmount - amounts.brokerFee;
    }

    /// @dev Checks the user-provided common parameters across lockup streams.
    function _checkCreateStream(address sender, uint128 depositAmount, uint40 startTime) private pure {
        // Check: the sender is not the zero address.
        if (sender == address(0)) {
            revert Errors.SablierLockup_SenderZeroAddress();
        }

        // Check: the deposit amount is not zero.
        if (depositAmount == 0) {
            revert Errors.SablierLockup_DepositAmountZero();
        }

        // Check: the start time is not zero.
        if (startTime == 0) {
            revert Errors.SablierLockup_StartTimeZero();
        }
    }

    /// @dev Checks:
    ///
    /// 1. The first timestamp is strictly greater than the start time.
    /// 2. The timestamps are ordered chronologically.
    /// 3. There are no duplicate timestamps.
    /// 4. The deposit amount is equal to the sum of all segment amounts.
    /// 5. The end time equals the last segment's timestamp.
    function _checkSegments(
        LockupDynamic.Segment[] memory segments,
        uint128 depositAmount,
        Lockup.Timestamps memory timestamps,
        uint256 maxSegmentCount
    )
        private
        pure
    {
        // Check: the segment count is not zero.
        uint256 segmentCount = segments.length;
        if (segmentCount == 0) {
            revert Errors.SablierLockup_SegmentCountZero();
        }

        // Check: the segment count is not greater than the maximum allowed.
        if (segmentCount > maxSegmentCount) {
            revert Errors.SablierLockup_SegmentCountTooHigh(segmentCount);
        }

        // Check: the start time is strictly less than the first segment timestamp.
        if (timestamps.start >= segments[0].timestamp) {
            revert Errors.SablierLockup_StartTimeNotLessThanFirstSegmentTimestamp(
                timestamps.start, segments[0].timestamp
            );
        }

        // Check: the end time equals the last segment's timestamp.
        if (timestamps.end != segments[segmentCount - 1].timestamp) {
            revert Errors.SablierLockup_EndTimeNotEqualToLastSegmentTimestamp(
                timestamps.end, segments[segmentCount - 1].timestamp
            );
        }

        // Check: the end time equals the last segment's timestamp.
        if (timestamps.end != segments[segments.length - 1].timestamp) {
            revert Errors.SablierLockup_EndTimeNotEqualToLastSegmentTimestamp(
                timestamps.end, segments[segments.length - 1].timestamp
            );
        }

        // Pre-declare the variables needed in the for loop.
        uint128 segmentAmountsSum;
        uint40 currentSegmentTimestamp;
        uint40 previousSegmentTimestamp;

        // Iterate over the segments to:
        //
        // 1. Calculate the sum of all segment amounts.
        // 2. Check that the timestamps are ordered.
        for (uint256 index = 0; index < segmentCount; ++index) {
            // Add the current segment amount to the sum.
            segmentAmountsSum += segments[index].amount;

            // Check: the current timestamp is strictly greater than the previous timestamp.
            currentSegmentTimestamp = segments[index].timestamp;
            if (currentSegmentTimestamp <= previousSegmentTimestamp) {
                revert Errors.SablierLockup_SegmentTimestampsNotOrdered(
                    index, previousSegmentTimestamp, currentSegmentTimestamp
                );
            }

            // Make the current timestamp the previous timestamp of the next loop iteration.
            previousSegmentTimestamp = currentSegmentTimestamp;
        }

        // Check: the deposit amount is equal to the segment amounts sum.
        if (depositAmount != segmentAmountsSum) {
            revert Errors.SablierLockup_DepositAmountNotEqualToSegmentAmountsSum(depositAmount, segmentAmountsSum);
        }
    }

    /// @dev Checks:
    ///
    /// 1. The first timestamp is strictly greater than the start time.
    /// 2. The timestamps are ordered chronologically.
    /// 3. There are no duplicate timestamps.
    /// 4. The deposit amount is equal to the sum of all tranche amounts.
    /// 5. The end time equals the last tranche's timestamp.
    function _checkTranches(
        LockupTranched.Tranche[] memory tranches,
        uint128 depositAmount,
        Lockup.Timestamps memory timestamps,
        uint256 maxTrancheCount
    )
        private
        pure
    {
        // Check: the tranche count is not zero.
        uint256 trancheCount = tranches.length;
        if (trancheCount == 0) {
            revert Errors.SablierLockup_TrancheCountZero();
        }

        // Check: the tranche count is not greater than the maximum allowed.
        if (trancheCount > maxTrancheCount) {
            revert Errors.SablierLockup_TrancheCountTooHigh(trancheCount);
        }

        // Check: the start time is strictly less than the first tranche timestamp.
        if (timestamps.start >= tranches[0].timestamp) {
            revert Errors.SablierLockup_StartTimeNotLessThanFirstTrancheTimestamp(
                timestamps.start, tranches[0].timestamp
            );
        }

        // Check: the end time equals the tranche's timestamp.
        if (timestamps.end != tranches[trancheCount - 1].timestamp) {
            revert Errors.SablierLockup_EndTimeNotEqualToLastTrancheTimestamp(
                timestamps.end, tranches[trancheCount - 1].timestamp
            );
        }

        // Pre-declare the variables needed in the for loop.
        uint128 trancheAmountsSum;
        uint40 currentTrancheTimestamp;
        uint40 previousTrancheTimestamp;

        // Iterate over the tranches to:
        //
        // 1. Calculate the sum of all tranche amounts.
        // 2. Check that the timestamps are ordered.
        for (uint256 index = 0; index < trancheCount; ++index) {
            // Add the current tranche amount to the sum.
            trancheAmountsSum += tranches[index].amount;

            // Check: the current timestamp is strictly greater than the previous timestamp.
            currentTrancheTimestamp = tranches[index].timestamp;
            if (currentTrancheTimestamp <= previousTrancheTimestamp) {
                revert Errors.SablierLockup_TrancheTimestampsNotOrdered(
                    index, previousTrancheTimestamp, currentTrancheTimestamp
                );
            }

            // Make the current timestamp the previous timestamp of the next loop iteration.
            previousTrancheTimestamp = currentTrancheTimestamp;
        }

        // Check: the deposit amount is equal to the tranche amounts sum.
        if (depositAmount != trancheAmountsSum) {
            revert Errors.SablierLockup_DepositAmountNotEqualToTrancheAmountsSum(depositAmount, trancheAmountsSum);
        }
    }
}
