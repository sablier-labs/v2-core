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

        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();
        gasCreateWithDurations();
        gasCreateWithTimestamps();
        gasRenounce();
        gasWithdraw();

        gasWithdraw_ByRecipient();
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurations() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        LockupLinear.CreateWithDurations memory params = defaults.createWithDurationsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithDurations(params);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `createWithDurations` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarksFile, contentToAppend);
    }

    function gasCreateWithTimestamps() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        LockupLinear.CreateWithTimestamps memory params = defaults.createWithTimestampsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `createWithTimestamps` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarksFile, contentToAppend);
    }
}
