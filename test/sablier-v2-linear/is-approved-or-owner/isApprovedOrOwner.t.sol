// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2LinearBaseTest } from "../SablierV2LinearBaseTest.t.sol";

contract IsApprovedOrOwner__Tests is SablierV2LinearBaseTest {
    uint256 internal daiStreamId;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Create the default stream, since most tests need it.
        daiStreamId = createDefaultDaiStream();

        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);
    }

    /// @dev it should return false.
    function testIsApprovedOrOwner__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        bool actualApprovedOrOwner = sablierV2Linear.isApprovedOrOwner(nonStreamId);
        bool expectedApprovedOrOwner = false;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return false.
    function testIsApprovedOrOwner__CallerUnauthorized() external {
        changePrank(users.eve);
        bool actualApprovedOrOwner = sablierV2Linear.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = false;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerOwner() external {
        bool actualApprovedOrOwner = sablierV2Linear.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerApprovedOneStream() external {
        sablierV2Linear.approve(users.alice, daiStreamId);
        changePrank(users.alice);
        bool actualApprovedOrOwner = sablierV2Linear.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerApprovedAllStreams() external {
        sablierV2Linear.setApprovalForAll(users.alice, true);
        changePrank(users.alice);
        bool actualApprovedOrOwner = sablierV2Linear.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }
}
