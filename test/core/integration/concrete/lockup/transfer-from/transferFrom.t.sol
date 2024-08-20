// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";

import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Integration_Test } from "../../../Integration.t.sol";

abstract contract TransferFrom_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) {
        resetPrank({ msgSender: users.recipient });
    }

    function test_RevertGiven_NonTransferableStream() external {
        uint256 notTransferableStreamId = createDefaultStreamNotTransferable();
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_NotTransferable.selector, notTransferableStreamId));
        lockup.transferFrom({ from: users.recipient, to: users.alice, tokenId: notTransferableStreamId });
    }

    function test_GivenTransferableStream() external {
        // Create a stream.
        uint256 streamId = createDefaultStream();

        // It should emit {MetadataUpdate} and {Transfer} events.
        vm.expectEmit({ emitter: address(lockup) });
        emit MetadataUpdate({ _tokenId: streamId });
        vm.expectEmit({ emitter: address(lockup) });
        emit Transfer({ from: users.recipient, to: users.alice, tokenId: streamId });

        // Transfer the NFT.
        lockup.transferFrom({ from: users.recipient, to: users.alice, tokenId: streamId });

        // It should change the stream recipient (and NFT owner).
        address actualRecipient = lockup.getRecipient(streamId);
        address expectedRecipient = users.alice;
        assertEq(actualRecipient, expectedRecipient, "recipient");
    }
}
