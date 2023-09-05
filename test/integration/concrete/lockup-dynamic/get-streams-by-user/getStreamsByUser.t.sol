// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { LockupDynamic_Integration_Concrete_Test } from "../LockupDynamic.t.sol";

contract GetStreamsByUser_LockupDynamic_Integration_Concrete_Test is LockupDynamic_Integration_Concrete_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        LockupDynamic_Integration_Concrete_Test.setUp();
        defaultStreamId = createDefaultStream();
    }

    function test_GetStreamsByUser_whenRecipientHasNoStream() external {
        uint256[] memory allStreams = lockupDynamic.getStreamsByUser(address(0x1234));
        assertEq(allStreams.length, 0);
    }

    modifier whenRecipientHasRegisteredStreams() {
        _;
    }

    function test_GetStreamsByUser() external whenRecipientHasRegisteredStreams {
        uint256[] memory allStreams = lockupDynamic.getStreamsByUser(users.recipient);
        assertEq(allStreams.length, 1);

        uint256 newStreamId = createDefaultStreamWithRecipient(users.recipient);
        allStreams = lockupDynamic.getStreamsByUser(users.recipient);

        assertEq(allStreams.length, 2);
        assertEq(allStreams[0], defaultStreamId);
        assertEq(allStreams[1], newStreamId);
    }
}
