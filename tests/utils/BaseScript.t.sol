// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { StdAssertions } from "forge-std/src/StdAssertions.sol";

import { BaseScript } from "@sablier/evm-utils/src/tests/BaseScript.sol";

contract BaseScriptMock is BaseScript { }

contract BaseScript_Test is StdAssertions {
    using Strings for uint256;

    BaseScriptMock internal baseScript;

    function setUp() public {
        baseScript = new BaseScriptMock();
    }

    function test_ConstructCreate2Salt() public view {
        string memory chainId = block.chainid.toString();
        string memory version = "2.0.1";
        string memory salt = string.concat("ChainID ", chainId, ", Version ", version);

        bytes32 actualSalt = baseScript.SALT();
        bytes32 expectedSalt = bytes32(abi.encodePacked(salt));
        assertEq(actualSalt, expectedSalt, "CREATE2 salt mismatch");
    }
}
