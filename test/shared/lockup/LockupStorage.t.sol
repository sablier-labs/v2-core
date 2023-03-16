// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { UD60x18 } from "@prb/math/UD60x18.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";

contract LockupStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                SABLIER-V2-ADMINABLE
    //////////////////////////////////////////////////////////////////////////*/
    address public admin;

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    UD60x18 public immutable MAX_FEE;
    ISablierV2Comptroller public comptroller;
    address internal immutable original;
    mapping(IERC20 asset => uint128 revenues) internal protocolRevenues;

    /*//////////////////////////////////////////////////////////////////////////
                               SABLIER-V2-FLASH-LOAN
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 internal constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    /*//////////////////////////////////////////////////////////////////////////
                                 SABLIER-V2-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    uint256 public nextStreamId;
    ISablierV2NFTDescriptor internal nftDescriptor;

    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId
    ) {
        admin = _admin;

        MAX_FEE = _maxFee;
        comptroller = _comptroller;
        original = _original;

        nftDescriptor = _nftDescriptor;
        nextStreamId = _nextStreamId;
    }
}
