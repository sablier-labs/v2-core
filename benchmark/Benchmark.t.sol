// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2Lockup } from "../src/interfaces/ISablierV2Lockup.sol";

import { Base_Test } from "../test/Base.t.sol";

/// @notice Benchmark contract with common logic needed by all tests.
abstract contract Benchmark_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal immutable AMOUNT_PER_SEGMENT = 100e18;
    uint128 internal immutable AMOUNT_PER_TRANCHE = 100e18;
    uint256 internal immutable STREAM_1 = 50;
    uint256 internal immutable STREAM_2 = 51;
    uint256 internal immutable STREAM_3 = 52;
    uint256 internal immutable STREAM_4 = 53;
    uint256 internal immutable STREAM_5 = 54;

    /// @dev The directory where the benchmark files are stored.
    string internal benchmarkResults = "benchmark/results/";

    /// @dev The path to the file where the benchmark results are stored.
    string internal benchmarkResultsFile;

    string internal contentToAppend;

    ISablierV2Lockup internal lockup;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();

        deal({ token: address(dai), to: users.sender, give: type(uint256).max });
        resetPrank({ msgSender: users.sender });

        // Create the first streams in each Lockup contract to initialize all the variables.
        _createFewStreams();
    }

    /*//////////////////////////////////////////////////////////////////////////
                    GAS BENCHMARKS FOR COMMON IMPLEMENTATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasBurn() internal {
        // Set the caller to the Recipient for `burn` and change timestamp to the end time.
        resetPrank({ msgSender: users.recipient });

        lockup.withdraw(STREAM_1, users.recipient, defaults.DEPOSIT_AMOUNT());

        uint256 beforeGas = gasleft();
        lockup.burn(STREAM_1);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `burn` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCancel() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });

        uint256 beforeGas = gasleft();
        lockup.cancel(STREAM_2);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `cancel` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasRenounce() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint256 beforeGas = gasleft();
        lockup.renounce(STREAM_3);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `renounce` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasWithdraw_ByRecipient() internal {
        // Set the caller to the Recipient for the next call
        resetPrank({ msgSender: users.recipient });

        uint128 withdrawAmount = defaults.WITHDRAW_AMOUNT();

        uint256 beforeGas = gasleft();
        lockup.withdraw(STREAM_4, users.alice, withdrawAmount);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `withdraw` (by Recipient) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasWithdraw() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint128 withdrawAmount = defaults.WITHDRAW_AMOUNT();

        uint256 beforeGas = gasleft();
        lockup.withdraw(STREAM_5, users.recipient, withdrawAmount);
        uint256 afterGas = gasleft();

        contentToAppend = string.concat("| `withdraw` (by Anyone) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a line to the file at given path.
    function _appendToFile(string memory path, string memory line) internal {
        vm.writeLine({ path: path, data: line });
    }

    function _createFewStreams() internal {
        for (uint128 i = 0; i < 100; ++i) {
            lockupDynamic.createWithTimestamps(defaults.createWithTimestampsLD());
            lockupLinear.createWithTimestamps(defaults.createWithTimestampsLL());
            lockupTranched.createWithTimestamps(defaults.createWithTimestampsLT());
        }
    }
}
