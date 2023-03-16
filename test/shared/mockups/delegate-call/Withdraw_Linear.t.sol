// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { UD60x18 } from "@prb/math/UD60x18.sol";
import { Vm } from "@prb/test/Vm.sol";

import { ISablierV2Comptroller } from "src/interfaces/ISablierV2Comptroller.sol";
import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2NFTDescriptor } from "src/interfaces/ISablierV2NFTDescriptor.sol";
import { Errors } from "src/libraries/Errors.sol";
import { LockupLinear } from "src/types/DataTypes.sol";

import { LinearStorage } from "../../lockup/linear/LinearStorage.t.sol";

contract Withdraw_Linear_DelegateCall is LinearStorage {
    constructor(
        address _admin,
        UD60x18 _maxFee,
        ISablierV2Comptroller _comptroller,
        address _original,
        ISablierV2NFTDescriptor _nftDescriptor,
        uint256 _nextStreamId,
        LockupLinear.Stream memory stream,
        address recipient,
        uint128 withdrawAmount,
        Vm vm
    ) payable LinearStorage(_admin, _maxFee, _comptroller, _original, _nftDescriptor, _nextStreamId) {
        uint256 streamId = _nextStreamId - 1;
        setStorage(stream, recipient, streamId);

        vm.expectRevert(Errors.SablierV2Config_NotDelegateCall.selector);
        (bool succes, ) = _original.delegatecall(
            abi.encodeCall(ISablierV2Lockup.withdraw, (streamId, recipient, withdrawAmount))
        );
        succes; // To avoid: "Warning: Return value of low-level calls not used."
    }
}
