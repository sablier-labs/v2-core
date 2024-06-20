// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierRecipient } from "../../../src/interfaces/ISablierRecipient.sol";
import { ISablierV2Lockup } from "../../../src/interfaces/ISablierV2Lockup.sol";

contract ReentrantRecipient is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = true;

    function onSablierLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
    {
        streamId;
        senderAmount;
        sender;
        recipientAmount;
        ISablierV2Lockup(msg.sender).cancel(streamId);
    }

    function onSablierLockupWithdraw(uint256 streamId, address caller, address to, uint128 amount) external {
        streamId;
        caller;
        to;
        amount;
        ISablierV2Lockup(msg.sender).withdraw(streamId, address(this), amount);
    }
}
