// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD60x18 } from "@prb/math/UD60x18.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { LockupPro } from "src/types/DataTypes.sol";

import { LockupStorage } from "../LockupStorage.t.sol";

contract ProStorage is LockupStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERC721
    //////////////////////////////////////////////////////////////////////////*/

    string private _name;
    string private _symbol;
    mapping(uint256 id => address owner) private _owners;
    mapping(address owner => uint256 count) private _balances;
    mapping(uint256 id => address approved) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool isOperator)) private _operatorApprovals;

    /*//////////////////////////////////////////////////////////////////////////
                              SABLIER-V2-LOCKUP-PRO
    //////////////////////////////////////////////////////////////////////////*/

    uint256 public immutable MAX_SEGMENT_COUNT;
    mapping(uint256 id => LockupPro.Stream stream) internal _streams;

    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId,
        uint256 _maxSegmentCount
    ) LockupStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId) {
        _name = "Sablier V2 Lockup Pro NFT";
        _symbol = "SAB-V2-LOCKUP-PRO";
        MAX_SEGMENT_COUNT = _maxSegmentCount;
    }

    function setStorage(LockupPro.Stream memory _stream, address recipient, uint256 streamId) internal {
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

        _balances[recipient] += 1;
        _owners[streamId] = recipient;
    }
}
