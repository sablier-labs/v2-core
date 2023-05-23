// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { ERC20Bytes32 } from "../../../../mocks/erc20/ERC20Bytes32.sol";
import { NFTDescriptor_Integration_Basic_Test } from "../NFTDescriptor.t.sol";

contract SafeAssetSymbol_Integration_Test is NFTDescriptor_Integration_Basic_Test {
    function setUp() public virtual override {
        NFTDescriptor_Integration_Basic_Test.setUp();
    }

    function test_SafeAssetSymbol_Bytes32() external {
        ERC20Bytes32 asset = new ERC20Bytes32();
        string memory actualSymbol = safeAssetSymbol(address(asset));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    function test_SafeAssetSymbol_EOA() external {
        address eoa = vm.addr({ privateKey: 1 });
        string memory actualSymbol = safeAssetSymbol(address(eoa));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    function test_SafeAssetSymbol_SymbolNotImplemented() external {
        string memory actualSymbol = safeAssetSymbol(address(noop));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    modifier whenNotReverted() {
        _;
    }

    function test_SafeAssetSymbol() external whenNotReverted {
        string memory actualSymbol = safeAssetSymbol(address(dai));
        string memory expectedSymbol = dai.symbol();
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }
}
