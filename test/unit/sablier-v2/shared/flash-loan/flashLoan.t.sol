// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { UD60x18, MAX_UD60x18, ud, unwrap, ZERO } from "@prb/math/UD60x18.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { SharedTest } from "../SharedTest.t.sol";

abstract contract FlashLoan_Test is SharedTest {
    bytes internal _data = "SomeData";

    // The dai ERC-20 balance of the Sablier contracts. See `deal` function in:
    // "test/unit/sablier-v2/linear/flash-loan/flashLoan.t.sol"
    // "test/unit/sablier-v2/pro/flash-loan/flashLoan.t.sol"
    uint128 internal _balance = 1_000e18;

    function setUp() public virtual override {
        super.setUp();

        // Make the recipient the caller in this test suite.
        changePrank(users.admin);

        // Give some dai tokens to the borrower contract to be able to repay the `flashFeeAmount`.
        deal({ token: address(dai), to: address(goodFlashLoanReceiver), give: 1_000e18 });
    }

    /// @dev it should revert.
    function test_RevertWhen_TokenNotFlashLoanable() external {
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2_TokenNonFlashLoanable.selector, dai));
        sablierV2.flashLoan(address(goodFlashLoanReceiver), dai, _balance, _data);
    }

    modifier tokenFlashLoanable() {
        comptroller.setFlashToken(dai);
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_InsufficientLiquidity(uint128 amount) external tokenFlashLoanable {
        amount = boundUint128(amount, _balance + 1, UINT128_MAX);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2_InsufficientFlashLoanLiquidity.selector, _balance, amount, dai)
        );
        sablierV2.flashLoan(address(goodFlashLoanReceiver), dai, amount, _data);
    }

    modifier sufficientLiquidity() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_FlashFeeTooHigh(UD60x18 flashFee) external tokenFlashLoanable sufficientLiquidity {
        flashFee = bound(flashFee, DEFAULT_MAX_FEE.add(ud(1)), MAX_UD60x18);

        // Set the flash fee.
        comptroller.setFlashFee(flashFee);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2_FlashFeeTooHigh.selector, flashFee, DEFAULT_MAX_FEE));
        sablierV2.flashLoan(address(goodFlashLoanReceiver), dai, _balance, _data);
    }

    modifier flashFeeNotTooHigh() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_NonBorrowerImplementer()
        external
        tokenFlashLoanable
        sufficientLiquidity
        flashFeeNotTooHigh
    {
        vm.expectRevert();
        sablierV2.flashLoan(address(empty), dai, _balance, _data);
    }

    modifier borrowerImplementer() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_BorrowerFail()
        external
        tokenFlashLoanable
        sufficientLiquidity
        flashFeeNotTooHigh
        borrowerImplementer
    {
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2_FlashBorrowFail.selector));
        sablierV2.flashLoan(address(badFlashLoanReceiver), dai, _balance, _data);
    }

    modifier borrowerNotFail() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_IsReentrancy()
        external
        tokenFlashLoanable
        sufficientLiquidity
        flashFeeNotTooHigh
        borrowerImplementer
        borrowerNotFail
    {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2_InsufficientFlashLoanLiquidity.selector, 0, _balance / 2, dai)
        );
        sablierV2.flashLoan(address(reentrantFlashLoanReceiver), dai, _balance / 2, _data);
    }

    modifier noReentrancy() {
        _;
    }

    /// @dev it should make the flash loan and emit a FlashLoan event.
    function test_FlashFeeZero()
        external
        tokenFlashLoanable
        sufficientLiquidity
        flashFeeNotTooHigh
        borrowerImplementer
        borrowerNotFail
        noReentrancy
    {
        // Set the flash fee.
        comptroller.setFlashFee(ZERO);

        // Expect an event to be emitted.
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.FlashLoan({
            receiver: address(goodFlashLoanReceiver),
            initiator: users.admin,
            token: dai,
            flashAmount: _balance,
            flashFeeAmount: 0
        });
        sablierV2.flashLoan(address(goodFlashLoanReceiver), dai, _balance, _data);
    }

    modifier flashFeeNotZero() {
        _;
    }

    /// @dev it should make the flash loan, update the protocol revenues, and emit a FlashLoan event.
    function testFuzz_FlashLoan(
        UD60x18 flashFee,
        uint128 amount,
        bytes calldata data
    )
        external
        tokenFlashLoanable
        sufficientLiquidity
        flashFeeNotTooHigh
        borrowerImplementer
        borrowerNotFail
        flashFeeNotZero
        noReentrancy
    {
        flashFee = bound(flashFee, DEFAULT_FLASH_FEE, DEFAULT_MAX_FEE);
        amount = boundUint128(amount, 0, _balance);

        uint128 initialProtocolRevenues = sablierV2.getProtocolRevenues(dai);

        // Set the fuzzed protocol fee.
        comptroller.setFlashFee(flashFee);

        // Calculate the flash fee amount.
        uint128 flashFeeAmount = uint128(unwrap(ud(amount).mul(flashFee)));

        // Calculate the amount that the borrower must return.
        uint128 returnAmount = amount + flashFeeAmount;

        // Expect an event to be emitted.
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        emit Events.FlashLoan({
            receiver: address(goodFlashLoanReceiver),
            initiator: users.admin,
            token: dai,
            flashAmount: amount,
            flashFeeAmount: flashFeeAmount
        });

        // Expect the `amount` tokens to be transferred to the borrower contract.
        vm.expectCall(address(dai), abi.encodeCall(IERC20.transfer, (address(goodFlashLoanReceiver), amount)));

        // Expect the `returnAmount` tokens to be transferred from the borrower contract to the SablierV2 contract.
        vm.expectCall(
            address(dai),
            abi.encodeCall(IERC20.transferFrom, (address(goodFlashLoanReceiver), address(sablierV2), returnAmount))
        );

        sablierV2.flashLoan(address(goodFlashLoanReceiver), dai, amount, data);

        uint128 actualProtocolRevenues = sablierV2.getProtocolRevenues(dai);
        uint128 expectedProtocolRevenues = initialProtocolRevenues + flashFeeAmount;
        assertEq(actualProtocolRevenues, expectedProtocolRevenues);
    }
}
