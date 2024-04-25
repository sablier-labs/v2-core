// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Base_Test } from "../Base.t.sol";

/// @notice Benchmark contract with common logic needed by all tests.
abstract contract Benchmark_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal immutable STREAM_ID = 50;

    /// @dev The directory where the benchmark files are stored.
    string internal benchmarksDir = "benchmarks/";

    /// @dev The path to the file where the benchmarks are stored.
    string internal benchmarksFile;

    string internal dataToAppend;

    /*//////////////////////////////////////////////////////////////////////////
                                   MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenCallerIsRecipient() {
        resetPrank({ msgSender: users.recipient });
        _;
    }

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
