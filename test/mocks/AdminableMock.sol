// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Adminable } from "../../contracts/abstracts/Adminable.sol";
import { IAdminable } from "../../contracts/interfaces/IAdminable.sol";

contract AdminableMock is Adminable {
    constructor(address initialAdmin) {
        admin = initialAdmin;
        emit IAdminable.TransferAdmin({ oldAdmin: address(0), newAdmin: initialAdmin });
    }
}
