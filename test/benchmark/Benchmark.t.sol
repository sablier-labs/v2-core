// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";

import { Base_Test } from "../Base.t.sol";

/// @notice Benchmark contract with common logic needed by all tests.
abstract contract Benchmark_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal immutable STREAM_1 = 50;
    uint256 internal immutable STREAM_2 = 51;
    uint256 internal immutable STREAM_3 = 52;
    uint256 internal immutable STREAM_4 = 53;
    uint256 internal immutable STREAM_5 = 54;

    /// @dev The directory where the benchmark files are stored.
    string internal benchmarksDir = "benchmarks/";

    /// @dev The path to the file where the benchmarks are stored.
    string internal benchmarksFile;

    string internal dataToAppend;

    ISablierV2Lockup internal lockup;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();

        deal({ token: address(dai), to: users.sender, give: type(uint256).max });
        resetPrank({ msgSender: users.sender });

        // Create the first stream in each Lockup contract to initialize all the variables
        _createFewStreams();
    }

    /*//////////////////////////////////////////////////////////////////////////
                    GAS BENCHMARKS FOR COMMON IMPLEMENTATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasBurn() internal {
        lockup.withdraw(STREAM_1, users.recipient, defaults.DEPOSIT_AMOUNT());

        uint256 beforeGas = gasleft();
        lockup.burn(STREAM_1);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `burn` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasCancel() internal {
        uint256 beforeGas = gasleft();
        lockup.cancel(STREAM_2);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `cancel` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasRenounce() internal {
        uint256 beforeGas = gasleft();
        lockup.renounce(STREAM_3);
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `renounce` | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw_ByRecipient() internal {
        uint256 beforeGas = gasleft();
        lockup.withdraw(STREAM_4, users.alice, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Recipient) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
    }

    function gasWithdraw() internal {
        uint256 beforeGas = gasleft();
        lockup.withdraw(STREAM_5, users.recipient, defaults.WITHDRAW_AMOUNT());
        uint256 afterGas = gasleft();

        dataToAppend = string.concat("| `withdraw` (by Anyone) | ", vm.toString(beforeGas - afterGas), " |");

        // Append the data to the file
        _appendToFile(benchmarksFile, dataToAppend);
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
