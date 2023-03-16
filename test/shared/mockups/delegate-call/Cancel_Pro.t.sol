// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD60x18 } from "@prb/math/UD60x18.sol";
import { Vm } from "@prb/test/Vm.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { Errors } from "src/libraries/Errors.sol";
import { LockupPro } from "src/types/DataTypes.sol";

import { ProStorage } from "../../lockup/pro/ProStorage.t.sol";

contract Cancel_Pro_DelegateCall is ProStorage {
    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId,
        uint256 _maxSegmentCount,
        LockupPro.Stream memory _stream,
        address recipient,
        Vm vm
    ) payable ProStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId, _maxSegmentCount) {
        setStreamStorage(_stream, recipient, _nextStreamId - 1);
        delegateCallCancel(_original, _nextStreamId - 1, vm);
    }

    function delegateCallCancel(address pro, uint256 streamId, Vm vm) public payable {
        vm.expectRevert(Errors.SablierV2Config_NotDelegateCall.selector);
        pro.delegatecall(abi.encodeCall(ISablierV2Lockup.cancel, streamId));
    }

    function setStreamStorage(LockupPro.Stream memory _stream, address recipient, uint256 streamId) public {
        LockupPro.Stream storage stream = _streams[streamId];
        stream.amounts = _stream.amounts;
        stream.asset = _stream.asset;
        stream.endTime = _stream.endTime;
        stream.isCancelable = _stream.isCancelable;
        stream.sender = _stream.sender;
        stream.startTime = _stream.startTime;
        stream.status = _stream.status;

        for (uint256 i = 0; i < _stream.segments.length; ++i) {
            stream.segments.push(_stream.segments[i]);
        }

        _mint({ to: recipient, tokenId: streamId });
    }
}
