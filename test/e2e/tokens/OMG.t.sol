// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { DataTypes } from "@sablier/v2-core/libraries/DataTypes.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";

import { SablierV2MainnetForkTest } from "../SablierV2MainnetForkTest.t.sol";
import { OMG } from "../MainnetForkBaseTest.t.sol";

contract OMG_Test is SablierV2MainnetForkTest {
    address internal holder = 0x51B73dD023D6C889E708988e1f9949597b3714f2; // random OMG holder

    function setUp() public override {
        super.setUp();

        approveAndTransferOmg(holder, OMG(token()).balanceOf(holder));
    }

    function balance() internal view override returns (uint256) {
        return OMG(token()).balanceOf(address(this));
    }

    function token() internal pure override returns (address) {
        return 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07;
    }
}
