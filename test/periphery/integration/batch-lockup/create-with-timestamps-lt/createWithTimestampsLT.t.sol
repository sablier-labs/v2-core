// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "periphery/libraries/Errors.sol";
import { BatchLockup } from "periphery/types/DataTypes.sol";

import { Periphery_Test } from "../../../Periphery.t.sol";

contract CreateWithTimestampsLT_Integration_Test is Periphery_Test {
    function setUp() public virtual override {
        Periphery_Test.setUp();
    }

    function test_RevertWhen_BatchSizeZero() external {
        BatchLockup.CreateWithTimestampsLT[] memory batchParams = new BatchLockup.CreateWithTimestampsLT[](0);
        vm.expectRevert(Errors.SablierV2BatchLockup_BatchSizeZero.selector);
        batchLockup.createWithTimestampsLT(lockupTranched, dai, batchParams);
    }

    modifier whenBatchSizeNotZero() {
        _;
    }

    function test_BatchCreateWithTimestamps() external whenBatchSizeNotZero {
        // Asset flow: Alice → batchLockup → Sablier
        // Expect transfers from Alice to the batchLockup, and then from the batchLockup to the Sablier contract.
        expectCallToTransferFrom({ from: users.alice, to: address(batchLockup), value: defaults.TOTAL_TRANSFER_AMOUNT() });
        expectMultipleCallsToCreateWithTimestampsLT({
            count: defaults.BATCH_SIZE(),
            params: defaults.createWithTimestampsLT()
        });
        expectMultipleCallsToTransferFrom({
            count: defaults.BATCH_SIZE(),
            from: address(batchLockup),
            to: address(lockupTranched),
            value: defaults.DEPOSIT_AMOUNT()
        });

        // Assert that the batch of streams has been created successfully.
        uint256[] memory actualStreamIds =
            batchLockup.createWithTimestampsLT(lockupTranched, dai, defaults.batchCreateWithTimestampsLT());
        uint256[] memory expectedStreamIds = defaults.incrementalStreamIds();
        assertEq(actualStreamIds, expectedStreamIds, "stream ids mismatch");
    }
}
