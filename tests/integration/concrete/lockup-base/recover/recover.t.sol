// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Errors as EvmUtilsErorrs } from "@sablier/evm-utils/src/libraries/Errors.sol";

import { ISablierLockupBase } from "src/interfaces/ISablierLockupBase.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../Integration.t.sol";

contract Recover_Integration_Concrete_Test is Integration_Test {
    uint256 internal surplusAmount = 1e18;

    function setUp() public override {
        Integration_Test.setUp();
        createDefaultStream();
    }

    function test_RevertWhen_CallerNotAdmin() external {
        resetPrank({ msgSender: users.eve });
        vm.expectRevert(abi.encodeWithSelector(EvmUtilsErorrs.CallerNotAdmin.selector, users.admin, users.eve));
        lockup.recover(dai, users.eve);
    }

    function test_RevertWhen_TokenBalanceNotExceedAggregateAmount() external whenCallerAdmin {
        // Using dai token for this test because it has zero surplus.
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockupBase_SurplusZero.selector, address(dai)));
        lockup.recover(dai, users.admin);
    }

    function test_WhenTokenBalanceExceedAggregateAmount() external whenCallerAdmin {
        // Increase the lockup contract balance in order to have a surplus.
        deal({ token: address(dai), to: address(lockup), give: dai.balanceOf(address(lockup)) + surplusAmount });

        assertEq(dai.balanceOf(address(lockup)), surplusAmount + lockup.aggregateBalance(dai));

        // It should emit {Recover} and {Transfer} events.
        vm.expectEmit({ emitter: address(dai) });
        emit IERC20.Transfer({ from: address(lockup), to: users.admin, value: surplusAmount });
        vm.expectEmit({ emitter: address(lockup) });
        emit ISablierLockupBase.Recover(users.admin, dai, users.admin, surplusAmount);

        // Recover the surplus.
        lockup.recover(dai, users.admin);

        // It should lead to token balance same as aggregate amount.
        assertEq(dai.balanceOf(address(lockup)), lockup.aggregateBalance(dai));
    }
}
