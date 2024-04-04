// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

contract ERC20Bytes32 {
    function symbol() external pure returns (bytes32) {
        return bytes32("ERC20");
    }
}
