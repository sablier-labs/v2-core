// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD2x18, ud2x18 } from "@prb/math/src/UD2x18.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

import { Broker, Lockup, LockupDynamic, LockupLinear } from "src/types/DataTypes.sol";

import { Constants } from "./Constants.sol";
import { Users } from "./Types.sol";

/// @notice Contract with default values used throughout the tests.
contract Defaults is Constants {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    UD60x18 public constant BROKER_FEE = UD60x18.wrap(0.003e18); // 0.3%
    uint128 public constant BROKER_FEE_AMOUNT = 30.120481927710843373e18; // 0.3% of total amount
    uint128 public constant CLIFF_AMOUNT = 2500e18;
    uint40 public immutable CLIFF_TIME;
    uint40 public constant CLIFF_DURATION = 2500 seconds;
    uint128 public constant DEPOSIT_AMOUNT = 10_000e18;
    uint40 public immutable END_TIME;
    uint256 public constant MAX_SEGMENT_COUNT = 300;
    uint40 public immutable MAX_SEGMENT_DURATION;
    UD60x18 public constant PROTOCOL_FEE = UD60x18.wrap(0.001e18); // 0.1%
    uint128 public constant PROTOCOL_FEE_AMOUNT = 10.040160642570281124e18; // 0.1% of total amount
    uint128 public constant REFUND_AMOUNT = DEPOSIT_AMOUNT - CLIFF_AMOUNT;
    uint256 public SEGMENT_COUNT;
    uint40 public immutable START_TIME;
    uint128 public constant TOTAL_AMOUNT = 10_040.160642570281124497e18; // deposit / (1 - fee)
    uint40 public constant TOTAL_DURATION = 10_000 seconds;
    uint128 public constant WITHDRAW_AMOUNT = 2600e18;
    uint40 public immutable WARP_26_PERCENT; // 26% of the way through the stream

    IERC20 private asset;
    Users private users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        START_TIME = uint40(MAY_1_2023) + 2 days;
        CLIFF_TIME = START_TIME + CLIFF_DURATION;
        END_TIME = START_TIME + TOTAL_DURATION;
        MAX_SEGMENT_DURATION = TOTAL_DURATION / uint40(MAX_SEGMENT_COUNT);
        SEGMENT_COUNT = 2;
        WARP_26_PERCENT = START_TIME + CLIFF_DURATION + 100 seconds;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function setAsset(IERC20 asset_) public {
        asset = asset_;
    }

    function setUsers(Users memory users_) public {
        users = users_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    function broker() public view returns (Broker memory) {
        return Broker({ account: users.broker, fee: BROKER_FEE });
    }

    function durations() public pure returns (LockupLinear.Durations memory) {
        return LockupLinear.Durations({ cliff: CLIFF_DURATION, total: TOTAL_DURATION });
    }

    function lockupAmounts() public pure returns (Lockup.Amounts memory) {
        return Lockup.Amounts({ deposited: DEPOSIT_AMOUNT, refunded: 0, withdrawn: 0 });
    }

    function lockupCreateAmounts() public pure returns (Lockup.CreateAmounts memory) {
        return Lockup.CreateAmounts({
            deposit: DEPOSIT_AMOUNT,
            protocolFee: PROTOCOL_FEE_AMOUNT,
            brokerFee: BROKER_FEE_AMOUNT
        });
    }

    function lockupDynamicRange() public view returns (LockupDynamic.Range memory) {
        return LockupDynamic.Range({ start: START_TIME, end: END_TIME });
    }

    function lockupDynamicStream() public view returns (LockupDynamic.StreamLD memory) {
        return LockupDynamic.StreamLD({
            amounts: lockupAmounts(),
            asset: asset,
            endTime: END_TIME,
            isCancelable: true,
            isDepleted: false,
            isStream: true,
            isTransferable: true,
            segments: segments(),
            sender: users.sender,
            startTime: START_TIME,
            wasCanceled: false
        });
    }

    function lockupLinearRange() public view returns (LockupLinear.Range memory) {
        return LockupLinear.Range({ start: START_TIME, cliff: CLIFF_TIME, end: END_TIME });
    }

    function lockupLinearStream() public view returns (LockupLinear.StreamLL memory) {
        return LockupLinear.StreamLL({
            amounts: lockupAmounts(),
            asset: asset,
            cliffTime: CLIFF_TIME,
            endTime: END_TIME,
            isCancelable: true,
            isTransferable: true,
            isDepleted: false,
            isStream: true,
            sender: users.sender,
            startTime: START_TIME,
            wasCanceled: false
        });
    }

    function maxSegments() public view returns (LockupDynamic.Segment[] memory maxSegments_) {
        uint128 amount = DEPOSIT_AMOUNT / uint128(MAX_SEGMENT_COUNT);
        UD2x18 exponent = ud2x18(2.71e18);

        // Generate a bunch of segments with the same amount, same exponent, and with timestamps evenly spread apart.
        maxSegments_ = new LockupDynamic.Segment[](MAX_SEGMENT_COUNT);
        for (uint40 i = 0; i < MAX_SEGMENT_COUNT; ++i) {
            maxSegments_[i] = (
                LockupDynamic.Segment({
                    amount: amount,
                    exponent: exponent,
                    timestamp: START_TIME + MAX_SEGMENT_DURATION * (i + 1)
                })
            );
        }
    }

    function segments() public view returns (LockupDynamic.Segment[] memory segments_) {
        segments_ = new LockupDynamic.Segment[](2);
        segments_[0] = (
            LockupDynamic.Segment({ amount: 2500e18, exponent: ud2x18(3.14e18), timestamp: START_TIME + CLIFF_DURATION })
        );
        segments_[1] = (
            LockupDynamic.Segment({ amount: 7500e18, exponent: ud2x18(0.5e18), timestamp: START_TIME + TOTAL_DURATION })
        );
    }

    function segmentsWithDurations()
        public
        view
        returns (LockupDynamic.SegmentWithDuration[] memory segmentsWithDurations_)
    {
        LockupDynamic.Segment[] memory segments_ = segments();
        segmentsWithDurations_ = new LockupDynamic.SegmentWithDuration[](2);
        segmentsWithDurations_[0] = (
            LockupDynamic.SegmentWithDuration({
                amount: segments_[0].amount,
                exponent: segments_[0].exponent,
                duration: 2500 seconds
            })
        );
        segmentsWithDurations_[1] = (
            LockupDynamic.SegmentWithDuration({
                amount: segments_[1].amount,
                exponent: segments_[1].exponent,
                duration: 7500 seconds
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       PARAMS
    //////////////////////////////////////////////////////////////////////////*/

    function createWithDurationsLD() public view returns (LockupDynamic.CreateWithDurations memory) {
        return LockupDynamic.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: TOTAL_AMOUNT,
            asset: asset,
            cancelable: true,
            transferable: true,
            segments: segmentsWithDurations(),
            broker: broker()
        });
    }

    function createWithDurationsLL() public view returns (LockupLinear.CreateWithDurations memory) {
        return LockupLinear.CreateWithDurations({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: TOTAL_AMOUNT,
            asset: asset,
            cancelable: true,
            transferable: true,
            durations: durations(),
            broker: broker()
        });
    }

    function createWithTimestampsLD() public view returns (LockupDynamic.CreateWithTimestamps memory) {
        return LockupDynamic.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: TOTAL_AMOUNT,
            asset: asset,
            cancelable: true,
            transferable: true,
            startTime: START_TIME,
            segments: segments(),
            broker: broker()
        });
    }

    function createWithTimestampsLL() public view returns (LockupLinear.CreateWithTimestamps memory) {
        return LockupLinear.CreateWithTimestamps({
            sender: users.sender,
            recipient: users.recipient,
            totalAmount: TOTAL_AMOUNT,
            asset: asset,
            cancelable: true,
            transferable: true,
            range: lockupLinearRange(),
            broker: broker()
        });
    }
}
