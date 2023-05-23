// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract SafeAssetDecimals_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_SafeAssetDecimals_EOA() external {
        address eoa = vm.addr({ privateKey: 1 });
        uint8 actualDecimals = safeAssetDecimals(address(eoa));
        uint8 expectedDecimals = 0;
        assertEq(actualDecimals, expectedDecimals, "decimals");
    }

    function test_SafeAssetDecimals_DecimalsNotImplemented() external {
        uint8 actualDecimals = safeAssetDecimals(address(noop));
        uint8 expectedDecimals = 0;
        assertEq(actualDecimals, expectedDecimals, "decimals");
    }

    modifier whenNotReverted() {
        _;
    }

    function test_SafeAssetDecimals() external whenNotReverted {
        uint8 actualDecimals = safeAssetDecimals(address(dai));
        uint8 expectedDecimals = dai.decimals();
        assertEq(actualDecimals, expectedDecimals, "decimals");
    }
}
