// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2MainnetForkTest } from "../SablierV2MainnetForkTest.t.sol";

contract OMG_Test is SablierV2MainnetForkTest {
    function setUp() public override {
        super.setUp();

        OMG(token()).approve(address(sablierV2Linear), UINT256_MAX);
        OMG(token()).approve(address(sablierV2Pro), UINT256_MAX);
    }

    function holder() internal pure override returns (address) {
        return 0x51B73dD023D6C889E708988e1f9949597b3714f2; // random OMG holder
    }

    function token() internal pure override returns (address) {
        return 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07;
    }
}

/// @dev An interface for the Omise Go token which doesn't return a bool value on
/// `approve` and `transferFrom` functions.
interface OMG {
    function approve(address spender, uint256 value) external;

    function balanceOf(address who) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}
