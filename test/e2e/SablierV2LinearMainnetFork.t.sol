// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { Test } from "forge-std/Test.sol";

import { DataTypes } from "@sablier/v2-core/libraries/DataTypes.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { SablierV2Linear } from "@sablier/v2-core/SablierV2Linear.sol";

/// @title SablierV2LinearForkTests
/// @dev Strictly for test purposes.
abstract contract SablierV2LinearMainnetFork is Test {
    /*//////////////////////////////////////////////////////////////////////////
                                       SETUP
    //////////////////////////////////////////////////////////////////////////*/

    SablierV2Linear internal sablierV2Linear;

    function setUp() public virtual {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        sablierV2Linear = new SablierV2Linear();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CREATE TEST
    //////////////////////////////////////////////////////////////////////////*/

    function testCreate(
        uint256 depositAmount,
        uint64 startTime,
        uint64 cliffTime,
        uint64 stopTime,
        bool cancelable
    ) public virtual {
        vm.assume(depositAmount > 0 && depositAmount <= balance());
        vm.assume(cliffTime >= startTime && cliffTime <= stopTime);

        uint256 nextStreamId = sablierV2Linear.nextStreamId();

        uint256 streamId = sablierV2Linear.create(
            holder(),
            holder(),
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
            sender: holder(),
            startTime: startTime,
            stopTime: stopTime,
            token: IERC20(token()),
            withdrawnAmount: 0
        });

        assertEq(streamId, nextStreamId);
        assertEq(sablierV2Linear.nextStreamId(), nextStreamId + 1);
        assertEq(sablierV2Linear.getStream(streamId), stream);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HERLPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function approveAndTransfer(
        address caller,
        address spender,
        uint256 amount
    ) internal {
        vm.prank(caller);
        IERC20(token()).approve(spender, amount);
        IERC20(token()).transferFrom(caller, spender, amount);
        IERC20(token()).approve(address(sablierV2Linear), amount);
    }

    function approveAndTransferOmg(
        address caller,
        address spender,
        uint256 amount
    ) internal {
        vm.prank(caller);
        OMG(token()).approve(spender, amount);
        OMG(token()).transferFrom(caller, spender, amount);
        OMG(token()).approve(address(sablierV2Linear), amount);
    }

    function assertEq(DataTypes.LinearStream memory a, DataTypes.LinearStream memory b) internal {
        assertEq(a.cancelable, b.cancelable);
        assertEq(a.depositAmount, b.depositAmount);
        assertEq(a.sender, b.sender);
        assertEq(uint256(a.startTime), uint256(b.startTime));
        assertEq(uint256(a.cliffTime), uint256(b.cliffTime));
        assertEq(uint256(a.stopTime), uint256(b.stopTime));
        assertEq(address(a.token), address(b.token));
        assertEq(a.withdrawnAmount, b.withdrawnAmount);
    }

    function balance() internal view virtual returns (uint256);

    function holder() internal pure virtual returns (address);

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
