// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

import { ERC20GodMode } from "@prb/contracts/token/erc20/ERC20GodMode.sol";

contract DeployToken is Script {
    uint256 internal constant MAX_SEGMENT_COUNT = 200;

    // 1. Set up you ".env" file
    // 2. Run the command: forge script script/DeployToken.s.sol:DeployToken --sender $YOUR_SENDER
    // --private-key $YOUR_PRIVATE_KEY --rpc-url $YOUR_RPC_URL --broadcast -vvvv
    function run() public returns (ERC20GodMode token) {
        vm.startBroadcast();

        token = new ERC20GodMode("Test token", "TKN", 18);

        console2.log("Token address:", address(token));

        vm.stopBroadcast();
    }
}
