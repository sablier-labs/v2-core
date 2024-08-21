// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ERC20Mock } from "test/mocks/erc20/ERC20Mock.sol";
import { ERC20Bytes32 } from "test/mocks/erc20/ERC20Bytes32.sol";
import { NFTDescriptor_Integration_Shared_Test } from "../../../shared/nft-descriptor/NFTDescriptor.t.sol";

contract SafeAssetSymbol_Integration_Concrete_Test is NFTDescriptor_Integration_Shared_Test {
    function test_WhenAssetIsNotContract() external view {
        address eoa = vm.addr({ privateKey: 1 });
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(eoa));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    modifier whenAssetIsContract() {
        _;
    }

    function test_GivenSymbolNotImplemented() external view whenAssetIsContract {
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(noop));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    modifier givenSymbolImplemented() {
        _;
    }

    function test_GivenSymbolAsBytes32() external whenAssetIsContract givenSymbolImplemented {
        ERC20Bytes32 asset = new ERC20Bytes32();
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(asset));
        string memory expectedSymbol = "ERC20";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    modifier givenSymbolAsString() {
        _;
    }

    function test_GivenSymbolLongerThan30Chars()
        external
        whenAssetIsContract
        givenSymbolImplemented
        givenSymbolAsString
    {
        ERC20Mock asset = new ERC20Mock({
            name: "Token",
            symbol: "This symbol is has more than 30 characters and it should be ignored"
        });
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(asset));
        string memory expectedSymbol = "Long Symbol";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    modifier givenSymbolNotLongerThan30Chars() {
        _;
    }

    function test_GivenSymbolContainsNon_alphanumericChars()
        external
        whenAssetIsContract
        givenSymbolImplemented
        givenSymbolAsString
        givenSymbolNotLongerThan30Chars
    {
        ERC20Mock asset = new ERC20Mock({ name: "Token", symbol: "<svg/onload=alert(\"xss\")>" });
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(asset));
        string memory expectedSymbol = "Unsupported Symbol";
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }

    function test_GivenSymbolContainsAlphanumericChars()
        external
        view
        whenAssetIsContract
        givenSymbolImplemented
        givenSymbolAsString
        givenSymbolNotLongerThan30Chars
    {
        string memory actualSymbol = nftDescriptorMock.safeAssetSymbol_(address(dai));
        string memory expectedSymbol = dai.symbol();
        assertEq(actualSymbol, expectedSymbol, "symbol");
    }
}
