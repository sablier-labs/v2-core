// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISablierV2LockupDynamic } from "src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "src/interfaces/ISablierV2LockupLinear.sol";

import { Fork_Test } from "./Fork.t.sol";

contract NFTDescriptor_Fork_Test is Fork_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal constant USDB = IERC20(0x4300000000000000000000000000000000000003);
    address internal constant USDB_HOLDER = 0x020cA66C30beC2c4Fe3861a94E4DB4A498A35872;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() Fork_Test(USDB, USDB_HOLDER) { }

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Loads the Lockup V2.1 contracts pre-deployed on Mainnet.
    modifier loadDeployments_V2_1() {
        lockupDynamic = ISablierV2LockupDynamic(0xDf578C2c70A86945999c65961417057363530a1c);
        lockupLinear = ISablierV2LockupLinear(0xcb099EfC90e88690e287259410B9AE63e1658CC6);
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Fork_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The following test checks whether the new NFT descriptor is compatible with Lockup Dynamic v2.1.
    ///
    /// Checklist:
    /// - It should expect a call to {ISablierV2LockupDynamic.tokenURI}.
    /// - The test would fail if the call to {ISablierV2LockupDynamic.tokenURI} reverts.
    ///
    /// Given enough fuzz runs, all the following scenarios will be fuzzed:
    /// - Multiple values of streamId.
    function testForkFuzz_TokenURI_LockupDynamic_V2_1(uint256 streamId) external loadDeployments_V2_1 {
        streamId = _bound(streamId, 1, lockupDynamic.nextStreamId() - 1);

        // Set the new NFT descriptor for the previous version of Lockup Dynamic.
        resetPrank({ msgSender: lockupDynamic.admin() });
        lockupDynamic.setNFTDescriptor(nftDescriptor);

        // Expects a successful call to the new NFT Descriptor.
        vm.expectCall({
            callee: address(nftDescriptor),
            data: abi.encodeCall(nftDescriptor.tokenURI, (lockupDynamic, streamId)),
            count: 1
        });

        // Generate the token URI using the new NFT Descriptor.
        lockupDynamic.tokenURI(streamId);
    }

    /// @dev The following test checks whether the new NFT descriptor is compatible with Lockup Linear v2.1.
    ///
    /// Checklist:
    /// - It should expect a call to {ISablierV2LockupLinear.tokenURI}.
    /// - The test would fail if the call to {ISablierV2LockupLinear.tokenURI} reverts.
    ///
    /// Given enough fuzz runs, all the following scenarios will be fuzzed:
    /// - Multiple values of streamId.
    function testForkFuzz_TokenURI_LockupLinear_V2_1(uint256 streamId) external loadDeployments_V2_1 {
        streamId = _bound(streamId, 1, lockupLinear.nextStreamId() - 1);

        // Set the new NFT descriptor for the previous version of Lockup Linear.
        resetPrank({ msgSender: lockupLinear.admin() });
        lockupLinear.setNFTDescriptor(nftDescriptor);

        // Expects a successful call to the new NFT Descriptor.
        vm.expectCall({
            callee: address(nftDescriptor),
            data: abi.encodeCall(nftDescriptor.tokenURI, (lockupLinear, streamId)),
            count: 1
        });

        // Generate the token URI using the new NFT Descriptor.
        lockupLinear.tokenURI(streamId);
    }
}
