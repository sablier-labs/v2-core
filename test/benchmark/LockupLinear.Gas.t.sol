// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { LockupLinear } from "src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Tests used to benchmark LockupLinear.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupLinear_Gas_Test is Benchmark_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/
    function setUp() public override {
        super.setUp();

        lockup = lockupLinear;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testGas_Implementations() external {
        // Set the file path.
        benchmarksFile = string.concat(benchmarksDir, "SablierV2LockupLinear.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarksFile,
            data: string.concat("# Benchmarks for LockupLinear\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n")
        });

        // Set the caller to the Recipient for `burn` and change timestamp to the end time.
        resetPrank({ msgSender: users.recipient });
        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();
        gasCreateWithDurations();
        gasCreateWithTimestamps();
        gasRenounce();
        gasWithdraw();

        // Set the caller to the Recipient for the next call.
        resetPrank({ msgSender: users.recipient });
        gasWithdraw_ByRecipient();
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurations() internal {
        LockupLinear.CreateWithDurations memory params = defaults.createWithDurationsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithDurations(params);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `createWithDurations` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarksFile, contentToAppend);
    }

    function gasCreateWithTimestamps() internal {
        LockupLinear.CreateWithTimestamps memory params = defaults.createWithTimestampsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `createWithTimestamps` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarksFile, contentToAppend);
    }
}
