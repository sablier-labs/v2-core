// SPDX-License-Identifier: LGPL-3.0
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

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        sablierV2Linear = new SablierV2Linear();
        sablierV2Pro = new SablierV2Pro(200);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev it should create the linear stream.
    function testCreateLinear(
        address sender,
        address recipient,
        uint256 depositAmount,
        uint64 startTime,
        uint64 cliffTime,
        uint64 stopTime,
        bool cancelable
    ) external {
        vm.assume(sender != address(0) && recipient != address(0));
        vm.assume(depositAmount > 0 && depositAmount <= balance());
        vm.assume(cliffTime >= startTime && cliffTime <= stopTime);

        uint256 nextStreamId = sablierV2Linear.nextStreamId();

        // Call the function with `address(this)` as the `msg.sender`.
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

        assertEq(streamId, nextStreamId);
        assertEq(sablierV2Linear.nextStreamId(), nextStreamId + 1);
        assertEq(sablierV2Linear.getStream(streamId), stream);
    }

    /// @dev it should create the pro stream.
    function testCreatePro(
        address sender,
        address recipient,
        uint256 depositAmount,
        uint64 startTime,
        uint64 stopTime,
        bool cancelable
    ) external {
        vm.assume(sender != address(0) && recipient != address(0));
        vm.assume(depositAmount > 0 && depositAmount <= balance());
        vm.assume(startTime > 0 && startTime <= stopTime);

        uint256[] memory segmentAmounts = createDynamicArray(depositAmount);
        SD59x18[] memory segmentExponents = createDynamicArray(sd59x18(3.14e18));
        uint64[] memory segmentMilestones = createDynamicUint64Array(stopTime);

        uint256 nextStreamId = sablierV2Pro.nextStreamId();

        // Call the function with `address(this)` as the `msg.sender`.
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

        assertEq(streamId, nextStreamId);
        assertEq(sablierV2Pro.nextStreamId(), nextStreamId + 1);
        assertEq(sablierV2Pro.getStream(streamId), stream);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to transfer the `amount` of tokens to this contract with `caller` as the `msg.sender`,
    /// and approve `sablierV2Linear` and `sablierV2Pro` contracts to spend tokens.
    function approveAndTransfer(address caller, uint256 amount) internal {
        vm.prank(caller);
        IERC20(token()).approve(address(this), amount);
        IERC20(token()).transferFrom(caller, address(this), amount);
        IERC20(token()).approve(address(sablierV2Linear), amount);
        IERC20(token()).approve(address(sablierV2Pro), amount);
    }

    /// @dev Helper function to transfer the `amount` of OMG tokens to this contract with `caller` as the `msg.sender`,
    /// and approve `sablierV2Linear` and `sablierV2Pro` contracts to spend tokens.
    function approveAndTransferOmg(address caller, uint256 amount) internal {
        vm.prank(caller);
        OMG(token()).approve(address(this), amount);
        OMG(token()).transferFrom(caller, address(this), amount);
        OMG(token()).approve(address(sablierV2Linear), amount);
        OMG(token()).approve(address(sablierV2Pro), amount);
    }

    /// @dev Helper function to return the available balance of this contract.
    function balance() internal view virtual returns (uint256);

    /// @dev Helper function to return the token address.
    function token() internal pure virtual returns (address);
}

/// @dev An interface for the Omise Go token which doesn't return a bool value on
/// `approve` and `transferFrom` functions.
interface OMG {
    function approve(address spender, uint256 value) external;

    function balanceOf(address who) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}
