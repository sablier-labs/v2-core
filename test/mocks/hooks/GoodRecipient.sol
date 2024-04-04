// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2Recipient } from "../../../src/interfaces/hooks/ISablierV2Recipient.sol";

contract GoodRecipient is ISablierV2Recipient {
    function onLockupStreamCanceled(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        pure
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;
    }

    function onLockupStreamRenounced(uint256 streamId) external pure {
        streamId;
    }

    function onLockupStreamWithdrawn(uint256 streamId, address caller, address to, uint128 amount) external pure {
        streamId;
        caller;
        to;
        amount;
    }
}
