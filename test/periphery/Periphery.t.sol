// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { SablierMerkleInstant } from "src/periphery/SablierMerkleInstant.sol";
import { SablierMerkleLL } from "src/periphery/SablierMerkleLL.sol";
import { SablierMerkleLT } from "src/periphery/SablierMerkleLT.sol";

import { Base_Test } from "../Base.t.sol";
import { ContractWithoutReceiveEth, ContractWithReceiveEth } from "../mocks/ReceiveEth.sol";

contract Periphery_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ContractWithoutReceiveEth internal contractWithoutReceiveEth;
    ContractWithReceiveEth internal contractWithReceiveEth;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        contractWithoutReceiveEth = new ContractWithoutReceiveEth();
        contractWithReceiveEth = new ContractWithReceiveEth();
        vm.label({ account: address(contractWithoutReceiveEth), newLabel: "Contract Without Receive Eth" });
        vm.label({ account: address(contractWithReceiveEth), newLabel: "Contract With Receive Eth" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   MERKLE-BASE
    //////////////////////////////////////////////////////////////////////////*/

    function computeMerkleInstantAddress(
        address caller,
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(
                caller,
                address(asset_),
                expiration,
                campaignOwner,
                abi.encode(defaults.IPFS_CID()),
                merkleRoot,
                defaults.NAME_BYTES32()
            )
        );
        bytes32 creationBytecodeHash =
            keccak256(getMerkleInstantBytecode(campaignOwner, asset_, merkleRoot, expiration, sablierFee));
        return vm.computeCreate2Address({
            salt: salt,
            initCodeHash: creationBytecodeHash,
            deployer: address(merkleFactory)
        });
    }

    function computeMerkleLLAddress(
        address caller,
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(
                caller,
                address(asset_),
                expiration,
                campaignOwner,
                abi.encode(defaults.IPFS_CID()),
                merkleRoot,
                defaults.NAME_BYTES32(),
                lockupLinear,
                defaults.CANCELABLE(),
                defaults.TRANSFERABLE(),
                abi.encode(defaults.schedule())
            )
        );
        bytes32 creationBytecodeHash =
            keccak256(getMerkleLLBytecode(campaignOwner, asset_, merkleRoot, expiration, sablierFee));
        return vm.computeCreate2Address({
            salt: salt,
            initCodeHash: creationBytecodeHash,
            deployer: address(merkleFactory)
        });
    }

    function computeMerkleLTAddress(
        address caller,
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(
                caller,
                address(asset_),
                expiration,
                campaignOwner,
                abi.encode(defaults.IPFS_CID()),
                merkleRoot,
                defaults.NAME_BYTES32(),
                lockupTranched,
                defaults.CANCELABLE(),
                defaults.TRANSFERABLE(),
                defaults.STREAM_START_TIME_ZERO(),
                abi.encode(defaults.tranchesWithPercentages())
            )
        );
        bytes32 creationBytecodeHash =
            keccak256(getMerkleLTBytecode(campaignOwner, asset_, merkleRoot, expiration, sablierFee));
        return vm.computeCreate2Address({
            salt: salt,
            initCodeHash: creationBytecodeHash,
            deployer: address(merkleFactory)
        });
    }

    function getMerkleInstantBytecode(
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (bytes memory)
    {
        bytes memory constructorArgs =
            abi.encode(defaults.baseParams(campaignOwner, asset_, expiration, merkleRoot), sablierFee);
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierMerkleInstant).creationCode, constructorArgs);
        } else {
            return bytes.concat(
                vm.getCode("out-optimized/SablierMerkleInstant.sol/SablierMerkleInstant.json"), constructorArgs
            );
        }
    }

    function getMerkleLLBytecode(
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (bytes memory)
    {
        bytes memory constructorArgs = abi.encode(
            defaults.baseParams(campaignOwner, asset_, expiration, merkleRoot),
            lockupLinear,
            defaults.CANCELABLE(),
            defaults.TRANSFERABLE(),
            defaults.schedule(),
            sablierFee
        );
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierMerkleLL).creationCode, constructorArgs);
        } else {
            return bytes.concat(vm.getCode("out-optimized/SablierMerkleLL.sol/SablierMerkleLL.json"), constructorArgs);
        }
    }

    function getMerkleLTBytecode(
        address campaignOwner,
        IERC20 asset_,
        bytes32 merkleRoot,
        uint40 expiration,
        uint256 sablierFee
    )
        internal
        view
        returns (bytes memory)
    {
        bytes memory constructorArgs = abi.encode(
            defaults.baseParams(campaignOwner, asset_, expiration, merkleRoot),
            lockupTranched,
            defaults.CANCELABLE(),
            defaults.TRANSFERABLE(),
            defaults.STREAM_START_TIME_ZERO(),
            defaults.tranchesWithPercentages(),
            sablierFee
        );
        if (!isTestOptimizedProfile()) {
            return bytes.concat(type(SablierMerkleLT).creationCode, constructorArgs);
        } else {
            return bytes.concat(vm.getCode("out-optimized/SablierMerkleLT.sol/SablierMerkleLT.json"), constructorArgs);
        }
    }
}
