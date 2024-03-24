// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Vm } from "forge-std/src/Vm.sol";

// TODO: Remove this after forge-std changes the visibility of `vm` to internal in the upstream contract.
abstract contract BaseVm {
    /// @dev The virtual address of the Foundry VM.
    address private constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    /// @dev An instance of the Foundry VM, which contains cheatcodes for testing.
    Vm internal constant vm = Vm(VM_ADDRESS);
}
