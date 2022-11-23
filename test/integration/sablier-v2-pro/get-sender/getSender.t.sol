// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2ProIntegrationTest } from "../SablierV2ProIntegrationTest.t.sol";

contract GetSender__Test is SablierV2ProIntegrationTest {
    /// @dev it should return zero.
    function testGetSender__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        address actualSender = sablierV2Pro.getSender(nonStreamId);
        address expectedSender = address(0);
        assertEq(actualSender, expectedSender);
    }

    modifier StreamExistent() {
        _;
    }

    /// @dev it should return the correct sender.
    function testGetSender() external StreamExistent {
        uint256 daiStreamId = createDefaultDaiStream();
        address actualSender = sablierV2Pro.getSender(daiStreamId);
        address expectedSender = daiStream.sender;
        assertEq(actualSender, expectedSender);
    }
}
