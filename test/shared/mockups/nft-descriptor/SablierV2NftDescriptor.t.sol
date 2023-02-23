// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { ISablierV2Lockup } from "src/interfaces/ISablierV2Lockup.sol";
import { ISablierV2NftDescriptor } from "src/interfaces/ISablierV2NftDescriptor.sol";

contract SablierV2NftDescriptor is ISablierV2NftDescriptor {
    function tokenURI(ISablierV2Lockup lockup, uint256 streamId) external view override returns (string memory uri) {
        lockup.getStartTime(streamId);
        uri = "This is an nft descriptor";
    }
}
