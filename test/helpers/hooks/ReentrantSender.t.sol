// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "src/interfaces/ISablierV2.sol";
import { ISablierV2Sender } from "src/hooks/ISablierV2Sender.sol";

contract ReentrantSender is ISablierV2Sender {
    function onStreamCanceled(
        uint256 streamId,
        address caller,
        uint128 recipientAmount,
        uint128 senderAmount
    ) external {
        streamId;
        caller;
        recipientAmount;
        senderAmount;
        ISablierV2(msg.sender).cancel(streamId);
    }
}