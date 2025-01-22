// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { CommonBase } from "forge-std/src/Base.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { ILockupNFTDescriptor } from "../../src/interfaces/ILockupNFTDescriptor.sol";
import { ISablierBatchLockup } from "../../src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "../../src/interfaces/ISablierLockup.sol";

abstract contract DeployOptimized is StdCheats, CommonBase {
    /// @dev Deploys {SablierBatchLockup} from an optimized source compiled with `--via-ir`.
    function deployOptimizedBatchLockup() internal returns (ISablierBatchLockup) {
        return ISablierBatchLockup(deployCode("out-optimized/SablierBatchLockup.sol/SablierBatchLockup.json"));
    }

    /// @dev Deploys the optimized {Helpers} and {VestingMath} libraries, and replace libraries placeholders in
    /// {SablierLockup} artifact.
    function deployOptimizedLibraries() internal {
        // Deploy public libraries.
        address helpers = deployCode("out-optimized/Helpers.sol/Helpers.json");
        address vestingMath = deployCode("out-optimized/VestingMath.sol/VestingMath.json");

        // Read {SablierLockup} artifact.
        string memory artifact = vm.readFile("out-optimized/SablierLockup.sol/SablierLockup.json");

        // Replace libraries placeholders.
        artifact = vm.replace({
            input: artifact,
            from: "__$70ac0b9f44f1ad43af70526685fc041161$__",
            to: vm.replace(vm.toString(helpers), "0x", "")
        });
        artifact = vm.replace({
            input: artifact,
            from: "__$a5f83f921acff269341ef3c300f67f6dd4$__",
            to: vm.replace(vm.toString(vestingMath), "0x", "")
        });

        // Write the updated artifact.
        vm.writeFile("out-optimized/SablierLockup.sol/SablierLockup.json", artifact);
    }

    /// @dev Deploys {SablierLockup} from an optimized source compiled with `--via-ir`.
    function deployOptimizedLockup(
        address initialAdmin,
        ILockupNFTDescriptor nftDescriptor_,
        uint256 maxCount
    )
        internal
        returns (ISablierLockup)
    {
        // Deploy the libraries.
        deployOptimizedLibraries();

        // Deploy the Lockup contract.
        return ISablierLockup(
            deployCode(
                "out-optimized/SablierLockup.sol/SablierLockup.json",
                abi.encode(initialAdmin, address(nftDescriptor_), maxCount)
            )
        );
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
