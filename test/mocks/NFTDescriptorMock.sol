// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC721Metadata } from "@openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

import { Errors } from "../../src/libraries/Errors.sol";
import { Lockup } from "../../src/types/DataTypes.sol";
import { SablierV2NFTDescriptor } from "../../src/SablierV2NFTDescriptor.sol";

/// @dev This mock is needed for testing reverts: https://github.com/foundry-rs/foundry/issues/864
contract NFTDescriptorMock is SablierV2NFTDescriptor {
    function mapSymbol_(IERC721Metadata nft) external view returns (string memory) {
        return mapSymbol(nft);
    }

    function stringifyStatus_(Lockup.Status status) external pure returns (string memory) {
        return stringifyStatus(status);
    }
}
