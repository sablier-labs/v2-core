// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Linear } from "@sablier/v2-core/interfaces/ISablierV2Linear.sol";
import { SablierV2Linear } from "@sablier/v2-core/SablierV2Linear.sol";

import "forge-std/console.sol";
import { DSTest } from "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";

import { SablierV2UnitTest } from "../../SablierV2UnitTest.t.sol";

interface CheatCodes {
    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;
}

contract SablierV2LinearCreateTest is SablierV2UnitTest {
    /// @dev when the recipient is the zero address, it should revert.
    function testCannotCreateStreamRecipientZeroAddress() external {
        vm.expectRevert(ISablierV2.SablierV2__RecipientZeroAddress.selector);
        address recipient = address(0);
        sablierV2Linear.create(recipient, stream.deposit, stream.token, stream.startTime, stream.stopTime);
    }

    /// @dev when the deposit is zero, it should revert.
    function testCannotCreateStreamDepositZero() external {
        vm.expectRevert(ISablierV2.SablierV2__DepositZero.selector);
        uint256 deposit = 0;
        sablierV2Linear.create(stream.recipient, deposit, stream.token, stream.startTime, stream.stopTime);
    }

    /// @dev when the start time is after the stop time.
    function testCannotCreateStreamStopTimeAfterStartTime() external {
        uint256 startTime = stream.stopTime;
        uint256 stopTime = stream.startTime;
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__StartTimeAfterStopTime.selector, startTime, stopTime)
        );
        sablierV2Linear.create(stream.recipient, stream.deposit, stream.token, startTime, stopTime);
    }

    /// @dev when the start time is the same as the stop time, it should create the stream.
    function testCreateStreamStopTimeSameAsStartTime() external {
        // TODO
    }

    /// @dev when the token is not a contract, it should revert.
    function testCannotCreateStreamTokenNotContract() external {
        // TODO
    }

    /// @dev when the token is missing the return value, it should create the stream.
    function testCreateStreamTokenMissingReturnValue() external {
        // TODO
    }

    /// @dev when all checks pass, it should create the stream.
    function testCreateStream() external {
        sablierV2Linear.create(stream.recipient, stream.deposit, stream.token, stream.startTime, stream.stopTime);
    }

    /// @dev when all checks pass, it should bump the next stream id.
    function testCreateStreamNextStreamId() external {
        uint256 nextStreamId = sablierV2Linear.nextStreamId();
        uint256 expectedNextStreamId = nextStreamId + 1;
        sablierV2Linear.create(stream.recipient, stream.deposit, stream.token, stream.startTime, stream.stopTime);
        uint256 actualNextStreamId = sablierV2Linear.nextStreamId();
        assertEq(expectedNextStreamId, actualNextStreamId);
    }

    event CreateLinearStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        IERC20 token,
        uint256 startTime,
        uint256 stopTime
    );

    /// @dev when all checks pass, it should emit a CreateLinearStream event.
    function testCreateStreamEvent() external {
        uint256 streamId = sablierV2Linear.nextStreamId();
        vm.expectEmit(true, true, true, true);
        emit CreateLinearStream(
            streamId,
            stream.sender,
            stream.recipient,
            stream.deposit,
            stream.token,
            stream.startTime,
            stream.stopTime
        );
        sablierV2Linear.create(stream.recipient, stream.deposit, stream.token, stream.startTime, stream.stopTime);
    }
}
