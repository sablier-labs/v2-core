// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats, StdUtils } from "forge-std/Components.sol";

import { DataTypes } from "@sablier/v2-core/libraries/DataTypes.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { SD59x18 } from "@prb/math/SD59x18.sol";

/// @title MainnetForkBaseTest
/// @dev Strictly for test purposes.
abstract contract MainnetForkBaseTest is PRBTest, StdCheats, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event LogNamedArray(string key, uint64[] value);

    /*//////////////////////////////////////////////////////////////////////////
                             INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to convert an int256 number to type `SD59x18`.
    function sd59x18(int256 number) internal pure returns (SD59x18 result) {
        result = SD59x18.wrap(number);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to compare two SD59x18 arrays.
    function assertEq(SD59x18[] memory a, SD59x18[] memory b) internal {
        int256[] memory castedA;
        int256[] memory castedB;
        assembly {
            castedA := a
            castedB := b
        }
        assertEq(castedA, castedB);
    }

    /// @dev Helper function to compare two `LinearStream` structs.
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

    /// @dev Helper function to compare two `ProStream` structs.
    function assertEq(DataTypes.ProStream memory a, DataTypes.ProStream memory b) internal {
        assertEq(a.cancelable, b.cancelable);
        assertEq(a.depositAmount, b.depositAmount);
        assertEq(a.sender, b.sender);
        assertEq(uint256(a.startTime), uint256(b.startTime));
        assertEq(uint256(a.stopTime), uint256(b.stopTime));
        assertEq(a.segmentAmounts, b.segmentAmounts);
        assertEq(a.segmentExponents, b.segmentExponents);
        assertEqUint64Array(a.segmentMilestones, b.segmentMilestones);
        assertEq(address(a.token), address(b.token));
        assertEq(a.withdrawnAmount, b.withdrawnAmount);
    }

    /// @dev Helper function to compare two `uint64` arrays.
    function assertEqUint64Array(uint64[] memory a, uint64[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit Log("Error: a == b not satisfied [uint64[]]");
            emit LogNamedArray("  Expected", b);
            emit LogNamedArray("    Actual", a);
            fail();
        }
    }

    /// @dev Helper function to create a dynamical `uint256` array with 1 element.
    function createDynamicArray(uint256 element0) internal pure returns (uint256[] memory dynamicalArray) {
        dynamicalArray = new uint256[](1);
        dynamicalArray[0] = element0;
    }

    /// @dev Helper function to create a dynamical `SD59x18` array with 1 element.
    function createDynamicArray(SD59x18 element0) internal pure returns (SD59x18[] memory dynamicalArray) {
        dynamicalArray = new SD59x18[](1);
        dynamicalArray[0] = element0;
    }

    /// @dev Helper function to create a dynamical `uint64` array with 1 element.
    function createDynamicUint64Array(uint64 element0) internal pure returns (uint64[] memory dynamicalArray) {
        dynamicalArray = new uint64[](1);
        dynamicalArray[0] = element0;
    }
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
