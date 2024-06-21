// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierRecipient } from "../../src/interfaces/ISablierRecipient.sol";
import { ISablierV2Lockup } from "../../src/interfaces/ISablierV2Lockup.sol";

contract RecipientGood is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = true;

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
    }

    function onSablierLockupWithdraw(uint256 streamId, address caller, address to, uint128 amount) external pure {
        streamId;
        caller;
        to;
        amount;
    }
}

contract RecipientMarkerFalse is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = false;

    function onSablierLockupCancel(uint256, address, uint128, uint128) external pure { }

    function onSablierLockupWithdraw(uint256, address, address, uint128) external pure { }
}

contract RecipientMarkerMissing {
    function onSablierLockupCancel(uint256, address, uint128, uint128) external pure { }

    function onSablierLockupWithdraw(uint256, address, address, uint128) external pure { }
}

contract RecipientReentrant is ISablierRecipient {
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
        ISablierV2Lockup(msg.sender).withdraw(streamId, address(this), recipientAmount);
    }

    function onSablierLockupWithdraw(uint256 streamId, address caller, address to, uint128 amount) external {
        streamId;
        caller;
        to;
        amount;
        ISablierV2Lockup(msg.sender).withdraw(streamId, address(this), amount);
    }
}

contract RecipientReverting is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = true;

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
