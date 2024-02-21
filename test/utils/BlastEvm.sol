// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { stdStorage, StdStorage } from "forge-std/src/StdStorage.sol";

import { Blast } from "../mocks/blast/Blast.sol";
import { ERC20Rebasing } from "../mocks/blast/ERC20Rebasing.sol";
import { GasMode } from "../mocks/blast/Gas.sol";
import { YieldMode } from "../mocks/blast/Yield.sol";

abstract contract BlastEvm {
    using stdStorage for StdStorage;

    StdStorage internal stdstore;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    Blast internal blast;
    address internal blastGas;
    address internal blastYield;
    ERC20Rebasing internal busd;

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Deploys the Blast related contracts.
    function deployBlastContracts() internal {
        blast = new Blast();
        blastGas = blast.GAS_CONTRACT();
        blastYield = blast.YIELD_CONTRACT();
        busd = new ERC20Rebasing();
    }

    function initializeDefaultConfiguration(address contractAddress) internal {
        // Set the default Yield configuration
        stdstore.target(blastYield).sig("yieldMode(address)").with_key(contractAddress).checked_write(
            uint8(YieldMode.VOID)
        );

        // Set the default Gas configuration
        stdstore.target(blastGas).sig("gasMode(address)").with_key(contractAddress).checked_write(uint8(GasMode.VOID));

        // Set the default Yield configuration for token
        stdstore.target(address(busd)).sig("yieldMode(address)").with_key(contractAddress).checked_write(
            uint8(YieldMode.AUTOMATIC)
        );
    }
}
