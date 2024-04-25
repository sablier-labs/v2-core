// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { LockupLinear } from "src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Benchmark Test for the LockupLinear contract.
/// @dev This contract creates a markdown file with the gas usage of each function in the benchmarks directory.
contract LockupLinear_Gas_Test is Benchmark_Test {
    function setUp() public override {
        super.setUp();

        benchmarksFile = string.concat(benchmarksDir, "lockupLinear.md");

        // Create the file if it doesn't exist, otherwise overwrite it
        vm.writeFile({
            path: benchmarksFile,
            data: string.concat(
                "# Benchmarks for implementations of the SablierV2LockupLinear contract\n\n",
                "| Implementation | Gas Usage |\n",
                "| --- | --- |\n"
            )
        });
    }

    function testGas_Burn() public givenCallerIsRecipient {
        vm.warp({ newTimestamp: defaults.END_TIME() });

        lockupLinear.withdraw(STREAM_ID, users.recipient, defaults.DEPOSIT_AMOUNT());

        uint256 beforeGas = gasleft();
        lockupLinear.burn(STREAM_ID);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `burn` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_Cancel() public {
        uint256 beforeGas = gasleft();
        lockupLinear.cancel(STREAM_ID);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `cancel` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_CreateWithDurations() public {
        LockupLinear.CreateWithDurations memory params = defaults.createWithDurationsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithDurations(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `createWithDurations` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_CreateWithTimestamps() public {
        LockupLinear.CreateWithTimestamps memory params = defaults.createWithTimestampsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `createWithTimestamps` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_Renounce() public {
        uint256 beforeGas = gasleft();
        lockupLinear.renounce(STREAM_ID);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `renounce` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_Withdraw_ByRecipient() public givenCallerIsRecipient {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 beforeGas = gasleft();
        lockupLinear.withdraw(STREAM_ID, users.alice, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw (by Recipient)` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function testGas_Withdraw() public {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 beforeGas = gasleft();
        lockupLinear.withdraw(STREAM_ID, users.recipient, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw (by Anyone)` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }
}
