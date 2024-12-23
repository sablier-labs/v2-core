// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Batch } from "src/abstracts/Batch.sol";

contract BatchMock is Batch {
    error InvalidNumber(uint256);

    uint256 internal _number = 10;

    // A view only function.
    function getNumber() public view returns (uint256) {
        return _number;
    }

    // A view only function that reverts.
    function getNumberAndRevert() public pure returns (uint256) {
        revert InvalidNumber(1);
    }

    // A state changing function with no return value.
    function setNumber(uint256 number) public {
        _number = number;
    }

    // A state changing function with payable modifier and return value.
    function setNumberWithPayableAndReturn(uint256 number) public payable returns (uint256) {
        _number = number;
        return _number;
    }

    // A state changing function with payable modifier but reverts with custom error.
    function setNumberWithPayableAndRevert(uint256 number) public payable {
        _number = number;
        revert InvalidNumber(number);
    }

    // A state changing function with payable modifier but reverts with string error.
    function setNumberWithPayableAndRevertString(uint256 number) public payable {
        _number = number;
        revert("You cannot pass");
    }

    // A state changing function with payable modifier and no return value.
    function setNumberWithPayable(uint256 number) public payable {
        _number = number;
    }
}
