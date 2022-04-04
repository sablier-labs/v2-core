// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { ISablierV2Linear } from "@sablier/v2-core/interfaces/ISablierV2Linear.sol";
import { SablierV2Linear } from "@sablier/v2-core/SablierV2Linear.sol";

import "forge-std/console.sol";
import { DSTest } from "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";

import { GodModeERC20 } from "../shared/GodModeERC20.t.sol";

/// @title GodModeERC20
/// @author Sablier Labs Ltd.
/// @notice Common testing contract to share across Sablier V2 test contracts.
/// @dev Strictly for test purposes.
abstract contract SablierV2UnitTest is DSTest {
    // Constants
    uint256 internal constant TIME_OFFSET = 300;

    // Generic testing variables
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));
    GodModeERC20 internal token = new GodModeERC20("Stablecoin", "USD", 18);
    address payable[] internal users;
    Vm internal vm = Vm(HEVM_ADDRESS);

    // Sablier-specific testing variables
    SablierV2Linear public sablierV2Linear = new SablierV2Linear();
    ISablierV2Linear.LinearStream internal stream;

    /// @dev A setup function invoked before each test case.
    function setUp() public {
        // Create 2 users for testing.
        createUsers(2);

        // Sets all subsequent calls' `msg.sender` to be `users[0]`.
        vm.startPrank(users[0]);

        // Create a basic linear stream to be used as the frame of reference.
        stream = ISablierV2Linear.LinearStream({
            deposit: bn(3600),
            recipient: users[1],
            sender: users[0],
            startTime: block.timestamp + TIME_OFFSET,
            stopTime: block.timestamp + TIME_OFFSET + 3600,
            token: token
        });

        // Approve the SablierV2Linear contract to spend $USD.
        token.approve(address(sablierV2Linear), stream.deposit);
    }

    /// @dev Helper function that multiplies the `amount` by `10^18`.
    function bn(uint256 amount) public pure returns (uint256 result) {
        result = bn(amount, 18);
    }

    /// @dev Helper function that multiplies the `amount` by `10^decimals`.
    function bn(uint256 amount, uint256 decimals) public pure returns (uint256 result) {
        result = amount * 10**decimals;
    }

    /// @dev Create users with 100 ETH balance and 1M USD.
    function createUsers(uint256 numberOfUsers) public {
        users = new address payable[](numberOfUsers);
        for (uint256 i = 0; i < numberOfUsers; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            token.mint(user, bn(1_000_000));
            users[i] = user;
        }
    }

    /// @dev Converts bytes32 to address.
    function getNextUserAddress() public returns (address payable) {
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }
}
