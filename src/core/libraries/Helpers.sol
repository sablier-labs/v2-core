// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
import { Lockup, LockupDynamic, LockupTranched } from "./../types/DataTypes.sol";
import { Errors } from "./Errors.sol";

/// @title Helpers
/// @notice Library with functions needed to validate input parameters across lockup streams.
library Helpers {
    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/
    /// @dev Checks the parameters of the {SablierLockup-_createLD} function.
    function checkCreateLockupDynamic(
        address sender,
        uint40 startTime,
        uint128 totalAmount,
        LockupDynamic.Segment[] memory segments,
        uint256 maxCount,
        UD60x18 brokerFee,
        UD60x18 maxBrokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee, maxBrokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, startTime);

        // Check: validate the user-provided segments.
        _checkSegments(segments, createAmounts.deposit, startTime, maxCount);
    }

    /// @dev Checks the parameters of the {SablierLockup-_createLT} function.
    function checkCreateLockupTranched(
        address sender,
        uint40 startTime,
        uint128 totalAmount,
        LockupTranched.Tranche[] memory tranches,
        uint256 maxCount,
        UD60x18 brokerFee,
        UD60x18 maxBrokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee, maxBrokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, startTime);

        // Check: validate the user-provided segments.
        _checkTranches(tranches, createAmounts.deposit, startTime, maxCount);
    }

    /// @dev Checks the parameters of the {SablierLockup-_createLL} function.
    function checkCreateLockupLinear(
        address sender,
        uint40 startTime,
        uint40 cliffTime,
        uint40 endTime,
        uint128 totalAmount,
        UD60x18 brokerFee,
        UD60x18 maxBrokerFee
    )
        public
        pure
        returns (Lockup.CreateAmounts memory createAmounts)
    {
        // Check: verify the broker fee and calculate the amounts.
        createAmounts = _checkAndCalculateBrokerFee(totalAmount, brokerFee, maxBrokerFee);

        // Check: validate the user-provided common parameters.
        _checkCreateStream(sender, createAmounts.deposit, startTime);

        // Check: validate the user-provided cliff and end times.
        _checkCliffAndEndTime(startTime, cliffTime, endTime);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the broker fee is not greater than `maxBrokerFee`, and then calculates the broker fee amount and the
    /// deposit amount from the total amount.
    function _checkAndCalculateBrokerFee(
        uint128 totalAmount,
        UD60x18 brokerFee,
        UD60x18 maxBrokerFee
    )
        private
        pure
        returns (Lockup.CreateAmounts memory amounts)
    {
        // When the total amount is zero, the broker fee is also zero.
        if (totalAmount == 0) {
            return Lockup.CreateAmounts(0, 0);
        }

        // Check: the broker fee is not greater than `maxBrokerFee`.
        if (brokerFee.gt(maxBrokerFee)) {
            revert Errors.SablierLockup_BrokerFeeTooHigh(brokerFee, maxBrokerFee);
        }

        // Calculate the broker fee amount.
        // The cast to uint128 is safe because the maximum fee is hard coded.
        amounts.brokerFee = uint128(ud(totalAmount).mul(brokerFee).intoUint256());

        // Assert that the total amount is strictly greater than the broker fee amount.
        assert(totalAmount > amounts.brokerFee);

        // Calculate the deposit amount (the amount to stream, net of the broker fee).
        amounts.deposit = totalAmount - amounts.brokerFee;
    }

    /// @dev Checks the user-provided cliff and end times of a lockup linear stream.
    function _checkCliffAndEndTime(uint40 startTime, uint40 cliffTime, uint40 endTime) private pure {
        // Since a cliff time of zero means there is no cliff, the following checks are performed only if it's not zero.
        if (cliffTime > 0) {
            // Check: the start time is strictly less than the cliff time.
            if (startTime >= cliffTime) {
                revert Errors.SablierLockup_StartTimeNotLessThanCliffTime(startTime, cliffTime);
            }

            // Check: the cliff time is strictly less than the end time.
            if (cliffTime >= endTime) {
                revert Errors.SablierLockup_CliffTimeNotLessThanEndTime(cliffTime, endTime);
            }
        }

        // Check: the start time is strictly less than the end time.
        if (startTime >= endTime) {
            revert Errors.SablierLockup_StartTimeNotLessThanEndTime(startTime, endTime);
        }
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
    function _checkSegments(
        LockupDynamic.Segment[] memory segments,
        uint128 depositAmount,
        uint40 startTime,
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
        if (startTime >= segments[0].timestamp) {
            revert Errors.SablierLockup_StartTimeNotLessThanFirstSegmentTimestamp(startTime, segments[0].timestamp);
        }

        // Pre-declare the variables needed in the for loop.
        uint128 segmentAmountsSum;
        uint40 currentSegmentTimestamp;
        uint40 previousSegmentTimestamp;

        // Iterate over the segments to:
        //
        // 1. Calculate the sum of all segment amounts.
        // 2. Check that the timestamps are ordered.
        uint256 count = segments.length;
        for (uint256 index = 0; index < count; ++index) {
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
    function _checkTranches(
        LockupTranched.Tranche[] memory tranches,
        uint128 depositAmount,
        uint40 startTime,
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
        if (startTime >= tranches[0].timestamp) {
            revert Errors.SablierLockup_StartTimeNotLessThanFirstTrancheTimestamp(startTime, tranches[0].timestamp);
        }

        // Pre-declare the variables needed in the for loop.
        uint128 trancheAmountsSum;
        uint40 currentTrancheTimestamp;
        uint40 previousTrancheTimestamp;

        // Iterate over the tranches to:
        //
        // 1. Calculate the sum of all tranche amounts.
        // 2. Check that the timestamps are ordered.
        uint256 count = tranches.length;
        for (uint256 index = 0; index < count; ++index) {
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
