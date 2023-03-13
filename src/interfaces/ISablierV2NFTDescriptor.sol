// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.18;

import { ISablierV2Lockup } from "./ISablierV2Lockup.sol";

/// @title ISablierV2NFTDescriptor
/// @notice The contract that produces the URI describing the Sablier stream NFTs.
interface ISablierV2NFTDescriptor {
    /// @notice Produces the URI describing a particular stream NFT.
    /// @dev Note This is a data URI with the JSON contents directly inlined.
    /// @param lockup The address of the lockup streaming contract the stream belongs to.
    /// @param streamId The id of the stream for which to produce a description.
    /// @return uri The URI of the ERC721-compliant metadata.
    function tokenURI(ISablierV2Lockup lockup, uint256 streamId) external view returns (string memory uri);
}
