// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2ProBaseTest } from "../SablierV2ProBaseTest.t.sol";

contract IsApprovedOrOwner__Tests is SablierV2ProBaseTest {
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
        bool actualApprovedOrOwner = sablierV2Pro.isApprovedOrOwner(nonStreamId);
        bool expectedApprovedOrOwner = false;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return false.
    function testIsApprovedOrOwner__CallerUnauthorized() external {
        changePrank(users.eve);
        bool actualApprovedOrOwner = sablierV2Pro.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = false;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerOwner() external {
        bool actualApprovedOrOwner = sablierV2Pro.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerApprovedOneStream() external {
        sablierV2Pro.approve(users.alice, daiStreamId);
        changePrank(users.alice);
        bool actualApprovedOrOwner = sablierV2Pro.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }

    /// @dev it should return true.
    function testIsApprovedOrOwner__CallerApprovedAllStreams() external {
        sablierV2Pro.setApprovalForAll(users.alice, true);
        changePrank(users.alice);
        bool actualApprovedOrOwner = sablierV2Pro.isApprovedOrOwner(daiStreamId);
        bool expectedApprovedOrOwner = true;
        assertEq(actualApprovedOrOwner, expectedApprovedOrOwner);
    }
}
