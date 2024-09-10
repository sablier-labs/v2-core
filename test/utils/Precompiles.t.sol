// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Precompiles } from "precompiles/Precompiles.sol";
import { LibString } from "solady/src/utils/LibString.sol";
import { ILockupNFTDescriptor } from "src/core/interfaces/ILockupNFTDescriptor.sol";
import { ISablierLockupDynamic } from "src/core/interfaces/ISablierLockupDynamic.sol";
import { ISablierLockupLinear } from "src/core/interfaces/ISablierLockupLinear.sol";
import { ISablierLockupTranched } from "src/core/interfaces/ISablierLockupTranched.sol";
import { ISablierBatchLockup } from "src/periphery/interfaces/ISablierBatchLockup.sol";
import { ISablierMerkleFactory } from "src/periphery/interfaces/ISablierMerkleFactory.sol";
import { Base_Test } from "./../Base.t.sol";

contract Precompiles_Test is Base_Test {
    using LibString for address;

    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        CORE
    //////////////////////////////////////////////////////////////////////////*/

    function test_DeployLockupDynamic() external onlyTestOptimizedProfile {
        address actualLockupDynamic = address(precompiles.deployLockupDynamic(users.admin, nftDescriptor));
        address expectedLockupDynamic =
            address(deployOptimizedLockupDynamic(users.admin, nftDescriptor, precompiles.MAX_SEGMENT_COUNT()));
        bytes memory expectedLockupDynamicCode =
            adjustBytecode(expectedLockupDynamic.code, expectedLockupDynamic, actualLockupDynamic);
        assertEq(actualLockupDynamic.code, expectedLockupDynamicCode, "bytecodes mismatch");
    }

    function test_DeployLockupLinear() external onlyTestOptimizedProfile {
        address actualLockupLinear = address(precompiles.deployLockupLinear(users.admin, nftDescriptor));
        address expectedLockupLinear = address(deployOptimizedLockupLinear(users.admin, nftDescriptor));
        bytes memory expectedLockupLinearCode =
            adjustBytecode(expectedLockupLinear.code, expectedLockupLinear, actualLockupLinear);
        assertEq(actualLockupLinear.code, expectedLockupLinearCode, "bytecodes mismatch");
    }

    function test_DeployLockupTranched() external onlyTestOptimizedProfile {
        address actualLockupTranched = address(precompiles.deployLockupTranched(users.admin, nftDescriptor));
        address expectedLockupTranched =
            address(deployOptimizedLockupTranched(users.admin, nftDescriptor, precompiles.MAX_TRANCHE_COUNT()));
        bytes memory expectedLockupTranchedCode =
            adjustBytecode(expectedLockupTranched.code, expectedLockupTranched, actualLockupTranched);
        assertEq(actualLockupTranched.code, expectedLockupTranchedCode, "bytecodes mismatch");
    }

    function test_DeployNFTDescriptor() external onlyTestOptimizedProfile {
        address actualNFTDescriptor = address(precompiles.deployNFTDescriptor());
        address expectedNFTDescriptor = address(deployOptimizedNFTDescriptor());
        assertEq(actualNFTDescriptor.code, expectedNFTDescriptor.code, "bytecodes mismatch");
    }

    function test_DeployCore() external onlyTestOptimizedProfile {
        (
            ILockupNFTDescriptor actualNFTDescriptor,
            ISablierLockupDynamic actualLockupDynamic,
            ISablierLockupLinear actualLockupLinear,
            ISablierLockupTranched actualLockupTranched
        ) = precompiles.deployCore(users.admin);

        (
            ILockupNFTDescriptor expectedNFTDescriptor,
            ISablierLockupDynamic expectedLockupDynamic,
            ISablierLockupLinear expectedLockupLinear,
            ISablierLockupTranched expectedLockupTranched
        ) = deployOptimizedCore(users.admin, precompiles.MAX_SEGMENT_COUNT(), precompiles.MAX_TRANCHE_COUNT());

        bytes memory expectedLockupDynamicCode = adjustBytecode(
            address(expectedLockupDynamic).code, address(expectedLockupDynamic), address(actualLockupDynamic)
        );

        bytes memory expectedLockupLinearCode = adjustBytecode(
            address(expectedLockupLinear).code, address(expectedLockupLinear), address(actualLockupLinear)
        );

        bytes memory expectedLockupTranchedCode = adjustBytecode(
            address(expectedLockupTranched).code, address(expectedLockupTranched), address(actualLockupTranched)
        );

        assertEq(address(actualLockupDynamic).code, expectedLockupDynamicCode, "bytecodes mismatch");
        assertEq(address(actualLockupLinear).code, expectedLockupLinearCode, "bytecodes mismatch");
        assertEq(address(actualLockupTranched).code, expectedLockupTranchedCode, "bytecodes mismatch");
        assertEq(address(actualNFTDescriptor).code, address(expectedNFTDescriptor).code, "bytecodes mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     PERIPHERY
    //////////////////////////////////////////////////////////////////////////*/

    function test_DeployBatchLockup() external onlyTestOptimizedProfile {
        address actualBatchLockup = address(precompiles.deployBatchLockup());
        address expectedBatchLockup = address(deployOptimizedBatchLockup());
        assertEq(actualBatchLockup.code, expectedBatchLockup.code, "bytecodes mismatch");
    }

    function test_DeployMerkleFactory() external onlyTestOptimizedProfile {
        address actualFactory = address(precompiles.deployMerkleFactory(users.admin));
        address expectedFactory = address(deployOptimizedMerkleFactory(users.admin));
        assertEq(actualFactory.code, expectedFactory.code, "bytecodes mismatch");
    }

    function test_DeployPeriphery() external onlyTestOptimizedProfile {
        (ISablierBatchLockup actualBatchLockup, ISablierMerkleFactory actualMerkleFactory) =
            precompiles.deployPeriphery(users.admin);

        (ISablierBatchLockup expectedBatchLockup, ISablierMerkleFactory expectedMerkleFactory) =
            deployOptimizedPeriphery(users.admin);

        assertEq(address(actualBatchLockup).code, address(expectedBatchLockup).code, "bytecodes mismatch");
        assertEq(address(actualMerkleFactory).code, address(expectedMerkleFactory).code, "bytecodes mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The expected bytecode has to be adjusted because {SablierLockup} inherits from {NoDelegateCall}, which
    /// saves the contract's own address in storage.
    function adjustBytecode(
        bytes memory bytecode,
        address expectedAddress,
        address actualAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return vm.parseBytes(
            vm.replace({
                input: vm.toString(bytecode),
                from: expectedAddress.toHexStringNoPrefix(),
                to: actualAddress.toHexStringNoPrefix()
            })
        );
    }
}
