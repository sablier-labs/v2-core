// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Precompiles } from "precompiles/Precompiles.sol";
import { LibString } from "solady/src/utils/LibString.sol";

import { ILockupNFTDescriptor } from "src/interfaces/ILockupNFTDescriptor.sol";
import { ISablierBatchLockup } from "src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "src/interfaces/ISablierLockup.sol";
import { Base_Test } from "./../Base.t.sol";

contract Precompiles_Test is Base_Test {
    using LibString for address;

    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployBatchLockup() external onlyTestOptimizedProfile {
        address actualBatchLockup = address(precompiles.deployBatchLockup());
        address expectedBatchLockup = address(deployOptimizedBatchLockup());
        assertEq(actualBatchLockup.code, expectedBatchLockup.code, "bytecodes mismatch");
    }

    function test_DeployLockup() external onlyTestOptimizedProfile {
        address actualLockup = address(precompiles.deployLockup(users.admin, nftDescriptor));
        (address helpers, address vestingMath, ISablierLockup expectedLockup) =
            deployOptimizedLockup(users.admin, nftDescriptor, precompiles.MAX_COUNT());

        bytes memory actualLockupCode = adjustActualBytecode(actualLockup.code, helpers, vestingMath);
        bytes memory expectedLockupCode =
            adjustExpectedBytecode(address(expectedLockup).code, address(expectedLockup), actualLockup);

        assertEq(actualLockupCode, expectedLockupCode, "bytecodes mismatch");
    }

    function test_DeployNFTDescriptor() external onlyTestOptimizedProfile {
        address actualNFTDescriptor = address(precompiles.deployNFTDescriptor());
        address expectedNFTDescriptor = address(deployOptimizedNFTDescriptor());
        assertEq(actualNFTDescriptor.code, expectedNFTDescriptor.code, "bytecodes mismatch");
    }

    function test_DeployProtocol() external onlyTestOptimizedProfile {
        (ILockupNFTDescriptor actualNFTDescriptor, ISablierLockup actualLockup, ISablierBatchLockup actualBatchLockup) =
            precompiles.deployProtocol(users.admin);

        (
            ILockupNFTDescriptor expectedNFTDescriptor,
            address helpers,
            address vestingMath,
            ISablierLockup expectedLockup,
            ISablierBatchLockup expectedBatchLockup
        ) = deployOptimizedProtocol(users.admin, precompiles.MAX_COUNT());

        bytes memory actualLockupCode = adjustActualBytecode(address(actualLockup).code, helpers, vestingMath);
        bytes memory expectedLockupCode =
            adjustExpectedBytecode(address(expectedLockup).code, address(expectedLockup), address(actualLockup));

        assertEq(actualLockupCode, expectedLockupCode, "bytecodes mismatch");
        assertEq(address(actualNFTDescriptor).code, address(expectedNFTDescriptor).code, "bytecodes mismatch");
        assertEq(address(actualBatchLockup).code, address(expectedBatchLockup).code, "bytecodes mismatch");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The actual bytecode has to be adjusted because it contains dummy libraries which need to be same as the
    /// libraries used in the expected bytecode.
    function adjustActualBytecode(
        bytes memory actualBytecode,
        address helpers,
        address vestingMath
    )
        internal
        pure
        returns (bytes memory bytecode)
    {
        // TODO: Update these with mainnet addresses. Make sure these match with the addresses in the update-precompiles
        // shell script.
        string memory bytecodeStr = vm.replace({
            input: vm.toString(actualBytecode),
            from: "7715bE116061E014Bb721b46Dc78Dd57C91FDF9b",
            to: vm.replace(vm.toString(helpers), "0x", "")
        });

        bytecodeStr = vm.replace({
            input: bytecodeStr,
            from: "7715bE116061E014Bb721b46Dc78Dd57C91FDF9b",
            to: vm.replace(vm.toString(vestingMath), "0x", "")
        });

        return vm.parseBytes(bytecodeStr);
    }

    /// @dev The expected bytecode has to be adjusted because {SablierLockup} inherits from {NoDelegateCall}, which
    /// saves the contract's own address in storage.
    function adjustExpectedBytecode(
        bytes memory expectedbytecode,
        address expectedAddress,
        address actualAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return vm.parseBytes(
            vm.replace({
                input: vm.toString(expectedbytecode),
                from: expectedAddress.toHexStringNoPrefix(),
                to: actualAddress.toHexStringNoPrefix()
            })
        );
    }
}
