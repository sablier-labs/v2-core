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
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        return ISablierRecipient.onSablierLockupCancel.selector;
    }

    function onSablierLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        return ISablierRecipient.onSablierLockupWithdraw.selector;
    }
}

contract RecipientInvalidSelector is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = true;

    function onSablierLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        return 0x10000000;
    }

    function onSablierLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        return 0x12345678;
    }
}

contract RecipientMarkerFalse is ISablierRecipient {
    bool public constant override IS_SABLIER_RECIPIENT = false;

    function onSablierLockupCancel(uint256, address, uint128, uint128) external pure override returns (bytes4) {
        return ISablierRecipient.onSablierLockupCancel.selector;
    }

    function onSablierLockupWithdraw(uint256, address, address, uint128) external pure override returns (bytes4) {
        return ISablierRecipient.onSablierLockupWithdraw.selector;
    }
}

contract RecipientMarkerMissing {
    function onSablierLockupCancel(uint256, address, uint128, uint128) external pure returns (bytes4) {
        return ISablierRecipient.onSablierLockupCancel.selector;
    }

    function onSablierLockupWithdraw(uint256, address, address, uint128) external pure returns (bytes4) {
        return ISablierRecipient.onSablierLockupWithdraw.selector;
    }
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
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        ISablierV2Lockup(msg.sender).withdraw(streamId, address(this), recipientAmount);

        return ISablierRecipient.onSablierLockupCancel.selector;
    }

    function onSablierLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        ISablierV2Lockup(msg.sender).withdraw(streamId, address(this), amount);

        return ISablierRecipient.onSablierLockupWithdraw.selector;
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
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;
        revert("You shall not pass");
    }

    function onSablierLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;
        revert("You shall not pass");
    }
}
