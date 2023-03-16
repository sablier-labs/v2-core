// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD60x18 } from "@prb/math/UD60x18.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { LockupStorage } from "../LockupStorage.t.sol";

contract LinearStorage is LockupStorage {
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
                              SABLIER-V2-LOCKUP-LINEAR
    //////////////////////////////////////////////////////////////////////////*/

    mapping(uint256 id => LockupLinear.Stream stream) internal _streams;

    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId
    ) LockupStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId) {
        _name = "Sablier V2 Lockup Linear NFT";
        _symbol = "SAB-V2-LOCKUP-LIN";
    }

    function setStorage(LockupLinear.Stream memory stream, address recipient, uint256 streamId) internal {
        _streams[streamId] = stream;
        _balances[recipient] += 1;
        _owners[streamId] = recipient;
    }
}
