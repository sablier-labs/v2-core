// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2Recipient } from "../../../src/interfaces/hooks/ISablierV2Recipient.sol";

contract RevertingRecipient is ISablierV2Recipient {
    function onSablierLockupCancel(
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
        revert("You shall not pass");
    }

    function onSablierLockupWithdraw(uint256 streamId, address caller, address to, uint128 amount) external pure {
        streamId;
        caller;
        to;
        amount;
        revert("You shall not pass");
    }
}
