// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { DataTypes } from "@sablier/v2-core/libraries/DataTypes.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { SablierV2Linear } from "@sablier/v2-core/SablierV2Linear.sol";
import { SablierV2Pro } from "@sablier/v2-core/SablierV2Pro.sol";
import { SD59x18 } from "@prb/math/SD59x18.sol";

import { TestPlus } from "../TestPlus.t.sol";

/// @title SablierV2MainnetForkTest
/// @dev Strictly for test purposes.
abstract contract SablierV2MainnetForkTest is TestPlus {
    /*//////////////////////////////////////////////////////////////////////////
                                       STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    SablierV2Linear internal sablierV2Linear;
    SablierV2Pro internal sablierV2Pro;
    SD59x18[] internal segmentExponents = createDynamicArray(sd59x18(3.14e18));

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        sablierV2Linear = new SablierV2Linear();
        sablierV2Pro = new SablierV2Pro(200);

        // Make the holder the `msg.sender` in this test suite.
        vm.startPrank(holder());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev it should create the linear stream.
    function testCreateLinear(
        address sender,
        address recipient,
        uint64 startTime,
        uint64 cliffTime,
        uint64 stopTime,
        bool cancelable
    ) external {
        vm.assume(sender != address(0) && recipient != address(0));
        vm.assume(cliffTime >= startTime && cliffTime <= stopTime);

        uint256 depositAmount = IERC20(token()).balanceOf(holder());

        uint256 nextStreamId = sablierV2Linear.nextStreamId();

        // Create the stream.
        uint256 streamId = sablierV2Linear.create(
            sender,
            recipient,
            depositAmount,
            IERC20(token()),
            startTime,
            cliffTime,
            stopTime,
            cancelable
        );

        // Declare the stream struct.
        DataTypes.LinearStream memory stream = DataTypes.LinearStream({
            cancelable: cancelable,
            cliffTime: cliffTime,
            depositAmount: depositAmount,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: IERC20(token()),
            withdrawnAmount: 0
        });

        // Run the tests.
        assertEq(streamId, nextStreamId);
        assertEq(sablierV2Linear.nextStreamId(), nextStreamId + 1);
        assertEq(sablierV2Linear.getStream(streamId), stream);
    }

    /// @dev it should create the pro stream.
    function testCreatePro(
        address sender,
        address recipient,
        uint64 startTime,
        uint64 stopTime,
        bool cancelable
    ) external {
        vm.assume(sender != address(0) && recipient != address(0));
        vm.assume(startTime > 0 && startTime <= stopTime);

        uint256 depositAmount = IERC20(token()).balanceOf(holder());
        uint256[] memory segmentAmounts = createDynamicArray(depositAmount);
        uint64[] memory segmentMilestones = createDynamicUint64Array(stopTime);

        uint256 nextStreamId = sablierV2Pro.nextStreamId();

        // Create the stream.
        uint256 streamId = sablierV2Pro.create(
            sender,
            recipient,
            depositAmount,
            IERC20(token()),
            startTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones,
            cancelable
        );

        // Declare the stream struct.
        DataTypes.ProStream memory stream = DataTypes.ProStream({
            cancelable: cancelable,
            depositAmount: depositAmount,
            segmentAmounts: segmentAmounts,
            segmentExponents: segmentExponents,
            segmentMilestones: segmentMilestones,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: IERC20(token()),
            withdrawnAmount: 0
        });

        // Run the tests.
        assertEq(streamId, nextStreamId);
        assertEq(sablierV2Pro.nextStreamId(), nextStreamId + 1);
        assertEq(sablierV2Pro.getStream(streamId), stream);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve `sablierV2Linear` and `sablierV2Pro` contracts to spend tokens.
    function approveSablier() internal {
        IERC20(token()).approve(address(sablierV2Linear), UINT256_MAX);
        IERC20(token()).approve(address(sablierV2Pro), UINT256_MAX);
    }

    /// @dev Helper function to return the tokens holder address.
    function holder() internal pure virtual returns (address);

    /// @dev Helper function to return the token address.
    function token() internal pure virtual returns (address);
}
