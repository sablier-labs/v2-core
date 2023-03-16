// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { LockupStorage } from "../LockupStorage.t.sol";

contract LinearStorage is LockupStorage, ERC721("Sablier V2 Lockup Linear NFT", "SAB-V2-LOCKUP-LIN") {
    mapping(uint256 id => LockupLinear.Stream stream) internal _streams;

    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId
    ) LockupStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId) {}
}
