// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable no-console
pragma solidity >=0.8.22 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { console2 } from "forge-std/src/console2.sol";
import { Script } from "forge-std/src/Script.sol";
import { stdJson } from "forge-std/src/StdJson.sol";

contract BaseScript is Script {
    using Strings for uint256;
    using stdJson for string;

    /// @dev The default value for `segmentCountMap` and `trancheCountMap`.
    uint256 internal constant DEFAULT_MAX_COUNT = 500;

    /// @dev The address of the Sablier deployer.
    address internal constant SABLIER_DEPLOYER = 0xb1bEF51ebCA01EB12001a639bDBbFF6eEcA12B9F;

    /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
    string internal constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

    /// @dev Needed for the deterministic deployments.
    bytes32 internal constant ZERO_SALT = bytes32(0);

    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    /// @dev Used to derive the broadcaster's address if $EOA is not defined.
    string internal mnemonic;

    /// @dev Admin address mapped by the chain Id.
    mapping(uint256 chainId => address admin) internal adminMap;

    /// @dev Maximum segment count mapped by the chain Id.
    mapping(uint256 chainId => uint256 count) internal segmentCountMap;

    /// @dev Maximum tranche count mapped by the chain Id.
    mapping(uint256 chainId => uint256 count) internal trancheCountMap;

    /// @dev Initializes the transaction broadcaster like this:
    ///
    /// - If $EOA is defined, use it.
    /// - Otherwise, derive the broadcaster address from $MNEMONIC.
    /// - If $MNEMONIC is not defined, default to a test mnemonic.
    ///
    /// The use case for $EOA is to specify the broadcaster key and its address via the command line.
    constructor() {
        address from = vm.envOr({ name: "EOA", defaultValue: address(0) });
        if (from != address(0)) {
            broadcaster = from;
        } else {
            mnemonic = vm.envOr({ name: "MNEMONIC", defaultValue: TEST_MNEMONIC });
            (broadcaster,) = deriveRememberKey({ mnemonic: mnemonic, index: 0 });
        }

        // Populate the segment and tranche count map.
        populateSegmentAndTrancheCountMap();

        // If there is no maximum value set for a specific chain, use the default value.
        if (segmentCountMap[block.chainid] == 0) {
            segmentCountMap[block.chainid] = DEFAULT_MAX_COUNT;
        }
        if (trancheCountMap[block.chainid] == 0) {
            trancheCountMap[block.chainid] = DEFAULT_MAX_COUNT;
        }

        // Populate the admin map.
        populateAdminMap();

        // If there is no admin set for a specific chain, use the Sablier deployer.
        if (adminMap[block.chainid] == address(0)) {
            adminMap[block.chainid] = SABLIER_DEPLOYER;
        }
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    ///
    /// Notes:
    /// - The salt format is "ChainID <chainid>, Version <version>".
    /// - The version is obtained from `package.json`.
    function constructCreate2Salt() public view returns (bytes32) {
        string memory chainId = block.chainid.toString();
        string memory version = getVersion();
        string memory create2Salt = string.concat("ChainID ", chainId, ", Version ", version);
        console2.log("The CREATE2 salt is \"%s\"", create2Salt);
        return bytes32(abi.encodePacked(create2Salt));
    }

    function getVersion() public view returns (string memory) {
        string memory json = vm.readFile("package.json");
        return json.readString(".version");
    }

    /// @dev Populates the admin map.
    function populateAdminMap() internal {
        // Arbitrum chain ID.
        adminMap[42_161] = 0xF34E41a6f6Ce5A45559B1D3Ee92E141a3De96376;

        // Avalanche chain ID.
        adminMap[43_114] = 0x4735517616373c5137dE8bcCDc887637B8ac85Ce;

        // Base chain ID.
        adminMap[8453] = 0x83A6fA8c04420B3F9C7A4CF1c040b63Fbbc89B66;

        // BNB chain ID.
        adminMap[56] = 0x6666cA940D2f4B65883b454b7Bc7EEB039f64fa3;

        // Gnosis chain ID.
        adminMap[100] = 0x72ACB57fa6a8fa768bE44Db453B1CDBa8B12A399;

        // Ethereum chain ID.
        adminMap[1] = 0x79Fb3e81aAc012c08501f41296CCC145a1E15844;

        // Optimism chain ID.
        adminMap[10] = 0x43c76FE8Aec91F63EbEfb4f5d2a4ba88ef880350;

        // Polygon chain ID.
        adminMap[137] = 0x40A518C5B9c1d3D6d62Ba789501CE4D526C9d9C6;

        // Scroll chain ID.
        adminMap[534_352] = 0x0F7Ad835235Ede685180A5c611111610813457a9;
    }

    /// @dev Populates the segment & tranche count map. Values can be updated using the `update-counts.sh` script.
    function populateSegmentAndTrancheCountMap() internal {
        // forgefmt: disable-start

        // Arbitrum chain ID
        segmentCountMap[42161] = 1160;
        trancheCountMap[42161] = 1200;

        // Avalanche chain ID.
        segmentCountMap[43114] = 520;
        trancheCountMap[43114] = 540;

        // Base chain ID.
        segmentCountMap[8453] = 2170;
        trancheCountMap[8453] = 2270;

        // Blast chain ID.
        segmentCountMap[81457] = 1080;
        trancheCountMap[81457] = 1120;

        // BNB chain ID.
        segmentCountMap[56] = 4820;
        trancheCountMap[56] = 5130;

        // Ethereum chain ID.
        segmentCountMap[1] = 1080;
        trancheCountMap[1] = 1120;

        // Gnosis chain ID.
        segmentCountMap[100] = 600;
        trancheCountMap[100] = 620;

        // Optimism chain ID.
        segmentCountMap[10] = 1080;
        trancheCountMap[10] = 1120;

        // Polygon chain ID.
        segmentCountMap[137] = 1080;
        trancheCountMap[137] = 1120;

        // Scroll chain ID.
        segmentCountMap[534352] = 330;
        trancheCountMap[534352] = 340;

        // Sepolia chain ID.
        segmentCountMap[11155111] = 1080;
        trancheCountMap[11155111] = 1120;

        // forgefmt: disable-end
    }
}
