// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { unwrap } from "@prb/math/UD60x18.sol";
import { IERC3156FlashBorrower } from "erc3156/interfaces/IERC3156FlashBorrower.sol";
import { IERC3156FlashLender } from "erc3156/interfaces/IERC3156FlashLender.sol";

import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2LockupLinear } from "src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupPro } from "src/interfaces/ISablierV2LockupPro.sol";
import { LockupLinear, LockupPro } from "src/types/DataTypes.sol";

contract DelegateCall {
    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-FLASH-LOAN
    //////////////////////////////////////////////////////////////////////////*/

    function delegateCallFlashLoan(
        address flashLoan,
        IERC3156FlashBorrower receiver,
        address asset,
        uint256 amount,
        bytes memory flashData
    ) public returns (bool succes, bytes memory data) {
        (succes, data) = flashLoan.delegatecall(
            abi.encodeCall(IERC3156FlashLender.flashLoan, (receiver, asset, amount, flashData))
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function delegateCallBurn(
        address lockup,
        uint256 streamId
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.burn, streamId));
    }

    function delegateCallCancel(
        address lockup,
        uint256 streamId
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.cancel, streamId));
    }

    function delegateCallCancelMultiple(
        address lockup,
        uint256[] memory streamIds
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.cancelMultiple, streamIds));
    }

    function delegateCallRenounce(
        address lockup,
        uint256 streamId
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.renounce, streamId));
    }

    function delegateCallWithdraw(
        address lockup,
        uint256 streamId,
        address to,
        uint128 amount
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.withdraw, (streamId, to, amount)));
    }

    function delegateCallWithdrawMax(
        address lockup,
        uint256 streamId,
        address to
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(abi.encodeCall(ISablierV2Lockup.withdrawMax, (streamId, to)));
    }

    function delegateCallWithdrawMultiple(
        address lockup,
        uint256[] memory streamIds,
        address to,
        uint128[] memory amounts
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = lockup.delegatecall(
            abi.encodeCall(ISablierV2Lockup.withdrawMultiple, (streamIds, to, amounts))
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    function delegateCallCreateWithDurations(
        address linear,
        LockupLinear.CreateWithDurations memory params
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = linear.delegatecall(abi.encodeCall(ISablierV2LockupLinear.createWithDurations, params));
    }

    function delegateCallCreateWithRange(
        address linear,
        LockupLinear.CreateWithRange memory params
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = linear.delegatecall(abi.encodeCall(ISablierV2LockupLinear.createWithRange, params));
    }

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    function delegateCallCreateWithDeltas(
        address pro,
        LockupPro.CreateWithDeltas memory params
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = pro.delegatecall(abi.encodeCall(ISablierV2LockupPro.createWithDeltas, params));
    }

    function delegateCallCreateWithMilestones(
        address pro,
        LockupPro.CreateWithMilestones memory params
    ) public payable returns (bool succes, bytes memory data) {
        (succes, data) = pro.delegatecall(abi.encodeCall(ISablierV2LockupPro.createWithMilestones, params));
    }
}
