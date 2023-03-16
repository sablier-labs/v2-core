// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD60x18 } from "@prb/math/UD60x18.sol";
import { Vm } from "@prb/test/Vm.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { Errors } from "src/libraries/Errors.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { LinearStorage } from "../../lockup/linear/LinearStorage.t.sol";

contract Cancel_Linear_DelegateCall is LinearStorage {
    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId,
        LockupLinear.Stream memory stream,
        address recipient,
        Vm vm
    ) payable LinearStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId) {
        setStreamStorage(stream, recipient, _nextStreamId - 1);
        delegateCallCancel(_original, _nextStreamId - 1, vm);
    }

    function delegateCallCancel(address linear, uint256 streamId, Vm vm) public payable {
        vm.expectRevert(Errors.SablierV2Config_NotDelegateCall.selector);
        linear.delegatecall(abi.encodeCall(ISablierV2Lockup.cancel, streamId));
    }

    function setStreamStorage(LockupLinear.Stream memory stream, address recipient, uint256 streamId) public {
        _streams[streamId] = stream;
        _mint({ to: recipient, tokenId: streamId });
    }
}
