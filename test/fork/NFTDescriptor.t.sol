// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISablierV2LockupDynamic } from "src/interfaces/ISablierV2LockupDynamic.sol";
import { ISablierV2LockupLinear } from "src/interfaces/ISablierV2LockupLinear.sol";

import { Fork_Test } from "./Fork.t.sol";

abstract contract NFTDescriptor_Fork_Test is Fork_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IERC20 asset, address holder) Fork_Test(asset, holder) { }

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Fork_Test.setUp();

        // Loads lockup v2.1 pre-deployed contracts on Mainnet.
        loadDeployments_V2_1();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Given enough fuzz runs, all the following scenarios will be fuzzed:
    /// - Multiple values of streamId.
    function testForkFuzz_TokenURI_LockupDynamic(uint256 streamId) external {
        streamId = bound(streamId, 1, lockupDynamic.nextStreamId() - 1);

        string memory tokenURIBefore = lockupDynamic.tokenURI(streamId);

        // Change the NFT descriptor for the previous versions of lockups to the newly deployed.
        resetPrank({ msgSender: lockupDynamic.admin() });
        lockupDynamic.setNFTDescriptor(nftDescriptor);

        string memory tokenURIAfter = lockupDynamic.tokenURI(streamId);

        // Assert that the token URI has not changed.
        assertEq(tokenURIBefore, tokenURIAfter, "incompatible token URI");
    }

    /// @dev Given enough fuzz runs, all the following scenarios will be fuzzed:
    /// - Multiple values of streamId.
    function testForkFuzz_TokenURI_LockupLinear(uint256 streamId) external {
        streamId = bound(streamId, 1, lockupLinear.nextStreamId() - 1);

        string memory tokenURIBefore = lockupLinear.tokenURI(streamId);

        // Change the NFT descriptor for the previous versions of lockups to the newly deployed.
        resetPrank({ msgSender: lockupLinear.admin() });
        lockupLinear.setNFTDescriptor(nftDescriptor);

        string memory tokenURIAfter = lockupLinear.tokenURI(streamId);

        // Assert that the token URI has not changed.
        assertEq(tokenURIBefore, tokenURIAfter, "incompatible token URI incompatible");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Loads v2.1 pre-deployed on Mainnet.
    function loadDeployments_V2_1() internal {
        lockupDynamic = ISablierV2LockupDynamic(0x7CC7e125d83A581ff438608490Cc0f7bDff79127);
        lockupLinear = ISablierV2LockupLinear(0xAFb979d9afAd1aD27C5eFf4E27226E3AB9e5dCC9);
    }
}
