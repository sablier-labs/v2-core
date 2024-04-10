// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { Base_Test } from "../Base.t.sol";

/// @notice Common logic needed by all fork tests.
abstract contract Fork_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     DATA TYPES
    //////////////////////////////////////////////////////////////////////////*/

    struct ForkInfo {
        uint256 id;
        address[] assets;
    }

    struct ForkChains {
        ForkInfo mainnet;
        ForkInfo arbitrum;
        ForkInfo avalanche;
        ForkInfo base;
        ForkInfo bnb;
        ForkInfo gnosis;
        ForkInfo optimism;
        ForkInfo polygon;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal ASSET;
    ForkChains internal forkChains;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier runForkTest() {
        if (!isProfileMultiChain) {
            // Select only Mainnet.
            vm.selectFork(forkChains.mainnet.id);
            deployCoreConditionally();

            for (uint256 i = 0; i < forkChains.mainnet.assets.length; ++i) {
                ASSET = IERC20(forkChains.mainnet.assets[i]);
                _;
            }
        } else {
            // Select Mainnet.
            vm.selectFork(forkChains.mainnet.id);
            deployCoreNormally();

            string memory symbol;

            // Run the test for all assets.
            for (uint256 i = 0; i < forkChains.mainnet.assets.length - 1; ++i) {
                ASSET = IERC20(forkChains.mainnet.assets[i]);
                _;
            }

            // Select Arbitrum.
            vm.selectFork(forkChains.arbitrum.id);
            deployCoreNormally();

            // Run the test for all assets.
            for (uint256 i = 0; i < forkChains.arbitrum.assets.length - 1; ++i) {
                ASSET = IERC20(forkChains.arbitrum.assets[i]);
                _;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    bool internal isProfileMultiChain;

    function setUp() public virtual override {
        // Create the fork for all chains.

        forkChains.mainnet.id = vm.createFork({ urlOrAlias: "mainnet", blockNumber: 19_610_954 });
        forkChains.mainnet.assets.push(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
        forkChains.mainnet.assets.push(0xdB25f211AB05b1c97D595516F45794528a807ad8); // EURS
        forkChains.mainnet.assets.push(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE); // SHIB
        forkChains.mainnet.assets.push(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
        forkChains.mainnet.assets.push(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT

        forkChains.arbitrum.id = vm.createFork({ urlOrAlias: "arbitrum", blockNumber: 198_875_211 });
        forkChains.arbitrum.assets.push(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1); // DAI
        forkChains.arbitrum.assets.push(0xD22a58f79e9481D1a88e00c343885A588b34b68B); // EURS
        forkChains.arbitrum.assets.push(0x5033833c9fe8B9d3E09EEd2f73d2aaF7E3872fd1); // SHIB
        forkChains.arbitrum.assets.push(0xaf88d065e77c8cC2239327C5EDb3A432268e5831); // USDC
        forkChains.arbitrum.assets.push(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9); // USDT

        forkChains.avalanche.id = vm.createFork({ urlOrAlias: "avalanche" });
        forkChains.avalanche.assets.push(0xd586E7F844cEa2F87f50152665BCbc2C279D8d70); // DAI
        forkChains.avalanche.assets.push(0x02D980A0D7AF3fb7Cf7Df8cB35d9eDBCF355f665); // SHIB
        forkChains.avalanche.assets.push(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E); // USDC
        forkChains.avalanche.assets.push(0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7); // USDT

        forkChains.base.id = vm.createFork({ urlOrAlias: "base" });
        forkChains.base.assets.push(0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb); // DAI
        forkChains.base.assets.push(0xdB25f211AB05b1c97D595516F45794528a807ad8); // EURS
        forkChains.base.assets.push(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE); // SHIB
        forkChains.base.assets.push(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913); // USDC
        forkChains.base.assets.push(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT

        forkChains.bnb.id = vm.createFork({ urlOrAlias: "bnb" });
        // forkChains.gnosis.id = vm.createFork({ urlOrAlias: "gnosis" });
        forkChains.optimism.id = vm.createFork({ urlOrAlias: "optimism" });
        forkChains.polygon.id = vm.createFork({ urlOrAlias: "polygon" });

        // TODO: add all the assets for the other chains.

        isProfileMultiChain = isForkMultichainProfile();

        // The base is set up after the fork is selected so that the base test contracts are deployed on the fork.
        Base_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks the user assumptions.
    function checkUsers(address sender, address recipient, address broker, address sablierContract) internal virtual {
        // The protocol does not allow the zero address to interact with it.
        vm.assume(sender != address(0) && recipient != address(0) && broker != address(0));

        // The goal is to not have overlapping users because the ASSET balance tests would fail otherwise.
        vm.assume(sender != recipient && sender != broker && recipient != broker);
        vm.assume(sender != sablierContract && recipient != sablierContract && broker != sablierContract);
        vm.assume(sender != address(ASSET) && recipient != address(ASSET) && broker != address(ASSET));

        // Avoid users blacklisted by USDC or USDT.
        assumeNoBlacklisted(address(ASSET), sender);
        assumeNoBlacklisted(address(ASSET), recipient);
        assumeNoBlacklisted(address(ASSET), broker);
    }

    function isForkMultichainProfile() internal view returns (bool) {
        string memory profile = vm.envOr({ name: "FOUNDRY_PROFILE", defaultValue: string("default") });
        return Strings.equal(profile, "fork-multichain");
    }
}
