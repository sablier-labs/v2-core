// SPDX-License-Identifier: UNLICENSED
// solhint-disable no-inline-assembly
pragma solidity >=0.8.22 <0.9.0;

import { CommonBase } from "forge-std/src/Base.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { stdJson } from "forge-std/src/StdJson.sol";

import { ILockupNFTDescriptor } from "../../src/interfaces/ILockupNFTDescriptor.sol";
import { ISablierBatchLockup } from "../../src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "../../src/interfaces/ISablierLockup.sol";

abstract contract DeployOptimized is StdCheats, CommonBase {
    using stdJson for string;

    /// @dev Deploys {SablierBatchLockup} from an optimized source compiled with `--via-ir`.
    function deployOptimizedBatchLockup() internal returns (ISablierBatchLockup) {
        return ISablierBatchLockup(deployCode("out-optimized/SablierBatchLockup.sol/SablierBatchLockup.json"));
    }

    /// @dev Deploys the optimized {Helpers} and {VestingMath} libraries.
    function deployOptimizedLibraries() internal returns (address helpers, address vestingMath) {
        // Deploy public libraries.
        helpers = deployCode("out-optimized/Helpers.sol/Helpers.json");
        vestingMath = deployCode("out-optimized/VestingMath.sol/VestingMath.json");
    }

    /// @dev Deploys {SablierLockup} from an optimized source compiled with `--via-ir`.
    function deployOptimizedLockup(
        address initialAdmin,
        ILockupNFTDescriptor nftDescriptor_,
        uint256 maxCount
    )
        internal
        returns (ISablierLockup lockup)
    {
        // Deploy the libraries.
        (address helpers, address vestingMath) = deployOptimizedLibraries();

        // Get the bytecode from {SablierLockup} artifact.
        string memory artifactJson = vm.readFile("out-optimized/SablierLockup.sol/SablierLockup.json");
        string memory rawBytecode = artifactJson.readString(".bytecode.object");

        // The placeholder `__$<value>$__` is a unique marker generated during compilation to represent where the
        // address of the library will be inserted.
        // By replacing this placeholder, we "link" the library address into the contract's bytecode.
        rawBytecode = vm.replace({
            input: rawBytecode,
            from: "__$70ac0b9f44f1ad43af70526685fc041161$__",
            to: vm.replace(vm.toString(helpers), "0x", "")
        });
        rawBytecode = vm.replace({
            input: rawBytecode,
            from: "__$a5f83f921acff269341ef3c300f67f6dd4$__",
            to: vm.replace(vm.toString(vestingMath), "0x", "")
        });

        // Generate the creation bytecode with the constructor arguments.
        bytes memory createBytecode =
            bytes.concat(vm.parseBytes(rawBytecode), abi.encode(initialAdmin, nftDescriptor_, maxCount));
        assembly {
            // Deploy the Lockup contract.
            lockup := create(0, add(createBytecode, 0x20), mload(createBytecode))
        }

        require(address(lockup) != address(0), "Lockup deployment failed.");

        return ISablierLockup(lockup);
    }

    /// @dev Deploys {LockupNFTDescriptor} from an optimized source compiled with `--via-ir`.
    function deployOptimizedNFTDescriptor() internal returns (ILockupNFTDescriptor) {
        return ILockupNFTDescriptor(deployCode("out-optimized/LockupNFTDescriptor.sol/LockupNFTDescriptor.json"));
    }

    /// @notice Deploys all contracts from an optimized source compiled with `--via-ir` in the following order:
    ///
    /// 1. {LockupNFTDescriptor}
    /// 2. {SablierLockup}
    /// 3. {SablierBatchLockup}
    function deployOptimizedProtocol(
        address initialAdmin,
        uint256 maxCount
    )
        internal
        returns (ILockupNFTDescriptor nftDescriptor_, ISablierLockup lockup_, ISablierBatchLockup batchLockup_)
    {
        nftDescriptor_ = deployOptimizedNFTDescriptor();
        lockup_ = deployOptimizedLockup(initialAdmin, nftDescriptor_, maxCount);
        batchLockup_ = deployOptimizedBatchLockup();
    }
}
