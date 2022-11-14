// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2ProBaseTest } from "../SablierV2ProBaseTest.t.sol";

contract GetSegmentAmounts__Tests is SablierV2ProBaseTest {
    /// @dev it should return zero.
    function testGetSegmentAmounts__StreamNonExistents() external {
        uint256 nonStreamId = 1729;
        uint256[] memory actualSegmentAmounts = sablierV2Pro.getSegmentAmounts(nonStreamId);
        uint256[] memory expectedSegmentAmounts;
        assertEq(actualSegmentAmounts, expectedSegmentAmounts);
    }

    modifier StreamExistent() {
        _;
    }

    /// @dev it should return the correct segment amounts.
    function testGetSegmentAmounts() external StreamExistent {
        uint256 daiStreamId = createDefaultDaiStream();
        uint256[] memory actualSegmentAmounts = sablierV2Pro.getSegmentAmounts(daiStreamId);
        uint256[] memory expectedSegmentAmounts = daiStream.segmentAmounts;
        assertEq(actualSegmentAmounts, expectedSegmentAmounts);
    }
}