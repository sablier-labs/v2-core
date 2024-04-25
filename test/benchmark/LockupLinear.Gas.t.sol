// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { LockupLinear } from "src/types/DataTypes.sol";

import { Benchmark_Test } from "./Benchmark.t.sol";

/// @notice Benchmark Test for the LockupLinear contract.
/// @dev This contract creates a markdown file with the gas usage of each function in the benchmarks directory.
contract LockupLinear_Gas_Test is Benchmark_Test {
    function setUp() public override {
        super.setUp();

        benchmarksFile = string.concat(benchmarksDir, "SablierV2LockupLinear.md");

        // Create the file if it doesn't exist, otherwise overwrite it
        vm.writeFile({
            path: benchmarksFile,
            data: string.concat(
                "# Benchmarks for implementations in the LockupLinear contract\n\n",
                "| Implementation | Gas Usage |\n",
                "| --- | --- |\n"
            )
        });
    }

    function testGas_Implementations() external {
        // Set the caller to recipient for `burn` and change timestamp to end time
        resetPrank({ msgSender: users.recipient });
        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        // Set the caller to sender for the next few calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();
        gasCreateWithDurations();
        gasCreateWithTimestamps();
        gasRenounce();
        gasWithdraw();

        // Set the caller to recipient for the next call
        resetPrank({ msgSender: users.recipient });
        gasWithdraw_ByRecipient();
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR EACH IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    function gasBurn() internal {
        vm.warp({ newTimestamp: defaults.END_TIME() });

        lockupLinear.withdraw(STREAM_1, users.recipient, defaults.DEPOSIT_AMOUNT());

        uint256 beforeGas = gasleft();
        lockupLinear.burn(STREAM_1);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `burn` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCancel() internal {
        uint256 beforeGas = gasleft();
        lockupLinear.cancel(STREAM_2);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `cancel` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCreateWithDurations() internal {
        LockupLinear.CreateWithDurations memory params = defaults.createWithDurationsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithDurations(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `createWithDurations` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCreateWithTimestamps() internal {
        LockupLinear.CreateWithTimestamps memory params = defaults.createWithTimestampsLL();

        uint256 beforeGas = gasleft();
        lockupLinear.createWithTimestamps(params);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `createWithTimestamps` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasRenounce() internal {
        uint256 beforeGas = gasleft();
        lockupLinear.renounce(STREAM_3);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `renounce` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw_ByRecipient() internal {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 beforeGas = gasleft();
        lockupLinear.withdraw(STREAM_4, users.alice, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Recipient) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw() internal {
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 beforeGas = gasleft();
        lockupLinear.withdraw(STREAM_5, users.recipient, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Anyone) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }
}
