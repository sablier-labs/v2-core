// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { uUNIT } from "@prb/math/src/UD2x18.sol";

import { Adminable } from "../core/abstracts/Adminable.sol";
import { ISablierLockupLinear } from "../core/interfaces/ISablierLockupLinear.sol";
import { ISablierLockupTranched } from "../core/interfaces/ISablierLockupTranched.sol";

import { ISablierMerkleBase } from "./interfaces/ISablierMerkleBase.sol";
import { ISablierMerkleFactory } from "./interfaces/ISablierMerkleFactory.sol";
import { ISablierMerkleInstant } from "./interfaces/ISablierMerkleInstant.sol";
import { ISablierMerkleLL } from "./interfaces/ISablierMerkleLL.sol";
import { ISablierMerkleLT } from "./interfaces/ISablierMerkleLT.sol";
import { SablierMerkleInstant } from "./SablierMerkleInstant.sol";
import { SablierMerkleLL } from "./SablierMerkleLL.sol";
import { SablierMerkleLT } from "./SablierMerkleLT.sol";
import { MerkleBase, MerkleFactory, MerkleLL, MerkleLT } from "./types/DataTypes.sol";

/// @title SablierMerkleFactory
/// @notice See the documentation in {ISablierMerkleFactory}.
contract SablierMerkleFactory is
    ISablierMerkleFactory, // 2 inherited components
    Adminable // 1 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierMerkleFactory
    uint256 public defaultSablierFee;

    /// @dev A mapping of custom Sablier fees by user.
    mapping(address campaignCreator => MerkleFactory.SablierFee) private _sablierFeeByUser;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Emits a {TransferAdmin} event.
    /// @param initialAdmin The address of the initial contract admin.
    constructor(address initialAdmin) {
        admin = initialAdmin;
        emit TransferAdmin({ oldAdmin: address(0), newAdmin: initialAdmin });
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierMerkleFactory
    function isPercentagesSum100(MerkleLT.TrancheWithPercentage[] calldata tranches)
        external
        pure
        override
        returns (bool result)
    {
        uint64 totalPercentage;
        for (uint256 i = 0; i < tranches.length; ++i) {
            totalPercentage += tranches[i].unlockPercentage.unwrap();
        }
        return totalPercentage == uUNIT;
    }

    /// @inheritdoc ISablierMerkleFactory
    function sablierFeeByUser(address campaignCreator)
        external
        view
        override
        returns (MerkleFactory.SablierFee memory)
    {
        return _sablierFeeByUser[campaignCreator];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         ADMIN-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierMerkleFactory
    function resetSablierFeeByUser(address campaignCreator) external override onlyAdmin {
        delete _sablierFeeByUser[campaignCreator];

        // Log the reset.
        emit ResetSablierFeeFor({ admin: msg.sender, user: campaignCreator });
    }

    /// @inheritdoc ISablierMerkleFactory
    function setDefaultSablierFee(uint256 defaultFee) external override onlyAdmin {
        // Effect: update the default Sablier fee.
        defaultSablierFee = defaultFee;

        emit SetDefaultSablierFee(msg.sender, defaultFee);
    }

    /// @inheritdoc ISablierMerkleFactory
    function setSablierFeeByUser(address campaignCreator, uint256 fee) external override onlyAdmin {
        MerkleFactory.SablierFee storage feeByUser = _sablierFeeByUser[campaignCreator];

        // If user does not belong to the custom fee list.
        if (!feeByUser.enabled) feeByUser.enabled = true;

        // Effect: update the Sablier fee for the given campaign creator.
        feeByUser.fee = fee;

        // Log the update.
        emit UpdateSablierFeeFor({ admin: msg.sender, user: campaignCreator, sablierFee: fee });
    }

    /// @inheritdoc ISablierMerkleFactory
    function withdrawFees(address payable to, ISablierMerkleBase merkleLockup) external override onlyAdmin {
        // Effect: call `withdrawFees` on the MerkleLockup contract.
        uint256 fees = merkleLockup.withdrawFees(to);

        // Log the withdrawal.
        emit WithdrawSablierFees({ admin: msg.sender, merkleLockup: merkleLockup, to: to, sablierFees: fees });
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierMerkleFactory
    function createMerkleInstant(
        MerkleBase.ConstructorParams memory baseParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (ISablierMerkleInstant merkleInstant)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name))
            )
        );

        // Fetch the Sablier fee for the user, or use the default fee.
        uint256 sablierFee =
            _sablierFeeByUser[msg.sender].enabled ? _sablierFeeByUser[msg.sender].fee : defaultSablierFee;

        // Deploy the MerkleInstant contract with CREATE2.
        merkleInstant = new SablierMerkleInstant{ salt: salt }(baseParams, sablierFee);

        // Log the creation of the MerkleInstant contract, including some metadata that is not stored on-chain.
        emit CreateMerkleInstant(merkleInstant, baseParams, aggregateAmount, recipientCount);
    }

    /// @inheritdoc ISablierMerkleFactory
    function createMerkleLL(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupLinear lockupLinear,
        bool cancelable,
        bool transferable,
        MerkleLL.Schedule memory schedule,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (ISablierMerkleLL merkleLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                lockupLinear,
                cancelable,
                transferable,
                abi.encode(schedule)
            )
        );

        // Fetch the Sablier fee for the user, or use the default fee.
        uint256 sablierFee =
            _sablierFeeByUser[msg.sender].enabled ? _sablierFeeByUser[msg.sender].fee : defaultSablierFee;

        // Deploy the MerkleLL contract with CREATE2.
        merkleLL =
            new SablierMerkleLL{ salt: salt }(baseParams, lockupLinear, cancelable, transferable, schedule, sablierFee);

        // Log the creation of the MerkleLL contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLL(
            merkleLL, baseParams, lockupLinear, cancelable, transferable, schedule, aggregateAmount, recipientCount
        );
    }

    /// @inheritdoc ISablierMerkleFactory
    function createMerkleLT(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupTranched lockupTranched,
        bool cancelable,
        bool transferable,
        uint40 streamStartTime,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (ISablierMerkleLT merkleLT)
    {
        // Calculate the sum of percentages and durations across all tranches.
        uint256 count = tranchesWithPercentages.length;
        uint256 totalDuration;
        for (uint256 i = 0; i < count; ++i) {
            unchecked {
                // Safe to use `unchecked` because its only used in the event.
                totalDuration += tranchesWithPercentages[i].duration;
            }
        }

        // Deploy the MerkleLT contract.
        merkleLT = _deployMerkleLT(
            baseParams, lockupTranched, cancelable, transferable, streamStartTime, tranchesWithPercentages
        );

        // Log the creation of the MerkleLT contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLT(
            merkleLT,
            baseParams,
            lockupTranched,
            cancelable,
            transferable,
            streamStartTime,
            tranchesWithPercentages,
            totalDuration,
            aggregateAmount,
            recipientCount
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new MerkleLT contract with CREATE2.
    /// @dev We need a separate function to prevent the stack too deep error.
    function _deployMerkleLT(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupTranched lockupTranched,
        bool cancelable,
        bool transferable,
        uint40 streamStartTime,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages
    )
        internal
        returns (ISablierMerkleLT merkleLT)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                lockupTranched,
                cancelable,
                transferable,
                streamStartTime,
                abi.encode(tranchesWithPercentages)
            )
        );

        // Fetch the Sablier fee for the user, or use the default fee.
        uint256 sablierFee =
            _sablierFeeByUser[msg.sender].enabled ? _sablierFeeByUser[msg.sender].fee : defaultSablierFee;

        // Deploy the MerkleLT contract with CREATE2.
        merkleLT = new SablierMerkleLT{ salt: salt }(
            baseParams, lockupTranched, cancelable, transferable, streamStartTime, tranchesWithPercentages, sablierFee
        );
    }
}
