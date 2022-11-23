// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { AbstractSablierV2IntegrationTest } from "../AbstractSablierV2IntegrationTest.t.sol";

contract AbstractSablierV2__Test is AbstractSablierV2IntegrationTest {
    function testConstructor() external {
        assertEq(abstractSablierV2.nextStreamId(), 1);
    }
}
