// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { CreateTest } from "../CreateTest.t.sol";

contract OMG__Test is CreateTest {
    OMG internal omg = OMG(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);

    function setUp() public override {
        super.setUp();

        omg.approve(address(sablierV2Linear), UINT256_MAX);
        omg.approve(address(sablierV2Pro), UINT256_MAX);
    }

    /// @dev random OMG holder
    function holder() internal pure override returns (address) {
        return 0x51B73dD023D6C889E708988e1f9949597b3714f2;
    }

    function token() internal pure override returns (IERC20) {
        return IERC20(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
    }
}

/// @dev An interface for the OmiseGo token, which doesn't return a bool value on `approve` function.
interface OMG {
    function approve(address spender, uint256 value) external;
}
