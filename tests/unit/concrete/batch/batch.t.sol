// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Base_Test } from "../../../Base.t.sol";
import { BatchMock } from "../../../mocks/BatchMock.sol";

contract Batch_Unit_Concrete_Test is Base_Test {
    BatchMock internal batchMock;
    bytes[] internal calls;
    bytes[] internal results;
    uint256 internal newNumber = 100;

    function setUp() public virtual override {
        Base_Test.setUp();

        batchMock = new BatchMock();
    }

    function test_RevertWhen_FunctionDoesNotExist() external {
        calls = new bytes[](1);
        calls[0] = abi.encodeWithSignature("nonExistentFunction()");

        // It should revert.
        vm.expectRevert(bytes(""));
        batchMock.batch(calls);
    }

    modifier whenFunctionExists() {
        _;
    }

    modifier givenNonStateChangingFunction() {
        _;
    }

    function test_RevertWhen_FunctionReverts() external whenFunctionExists givenNonStateChangingFunction {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.getNumberAndRevert, ());

        // It should revert.
        vm.expectRevert(abi.encodeWithSelector(BatchMock.InvalidNumber.selector, 1));
        batchMock.batch(calls);
    }

    function test_WhenFunctionNotRevert() external whenFunctionExists givenNonStateChangingFunction {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.getNumber, ());
        results = batchMock.batch(calls);

        // It should return expected value.
        assertEq(results.length, 1);
        assertEq(abi.decode(results[0], (uint256)), 10);
    }

    modifier givenStateChangingFunction() {
        _;
    }

    modifier whenNotPayable() {
        _;
    }

    function test_RevertWhen_BatchIncludesETHValue()
        external
        whenFunctionExists
        givenStateChangingFunction
        whenNotPayable
    {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumber, (newNumber));

        // It should revert.
        vm.expectRevert(bytes(""));
        batchMock.batch{ value: 1 wei }(calls);
    }

    function test_WhenBatchNotIncludeETHValue() external whenFunctionExists givenStateChangingFunction whenNotPayable {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumber, (newNumber));

        results = batchMock.batch(calls);

        // It should return empty value.
        assertEq(results.length, 1);
        assertEq(results[0], hex"");
    }

    modifier whenPayable() {
        _;
    }

    function test_RevertWhen_FunctionRevertsWithCustomError()
        external
        whenFunctionExists
        givenStateChangingFunction
        whenPayable
    {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumberWithPayableAndRevert, (newNumber));

        // It should revert.
        vm.expectRevert(abi.encodeWithSelector(BatchMock.InvalidNumber.selector, newNumber));
        batchMock.batch{ value: 1 wei }(calls);
    }

    function test_RevertWhen_FunctionRevertsWithStringError()
        external
        whenFunctionExists
        givenStateChangingFunction
        whenPayable
    {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumberWithPayableAndRevertString, (newNumber));

        // It should revert.
        vm.expectRevert("You cannot pass");
        batchMock.batch{ value: 1 wei }(calls);
    }

    function test_WhenFunctionReturnsAValue() external whenFunctionExists givenStateChangingFunction whenPayable {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumberWithPayableAndReturn, (newNumber));
        results = batchMock.batch{ value: 1 wei }(calls);

        // It should return expected value.
        assertEq(results.length, 1);
        assertEq(abi.decode(results[0], (uint256)), newNumber);
    }

    function test_WhenFunctionDoesNotReturnAValue()
        external
        whenFunctionExists
        givenStateChangingFunction
        whenPayable
    {
        calls = new bytes[](1);
        calls[0] = abi.encodeCall(batchMock.setNumberWithPayable, (newNumber));
        results = batchMock.batch{ value: 1 wei }(calls);

        // It should return empty value.
        assertEq(results.length, 1);
        assertEq(results[0], hex"");
    }
}
