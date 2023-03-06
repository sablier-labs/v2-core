// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Lockup_Shared_Test } from "../../../../shared/lockup/Lockup.t.sol";
import { Unit_Test } from "../../../Unit.t.sol";

abstract contract TokenURI_Unit_Test is Unit_Test, Lockup_Shared_Test {
    function setUp() public virtual override(Unit_Test, Lockup_Shared_Test) {}

    /// @dev it should return the descriptor URI.
    function test_TokenURI_StreamNull() external {
        uint256 nullStreamId = 1729;
        string memory actualTokenURI = lockup.tokenURI({ tokenId: nullStreamId });
        string memory expectedTokenURI;
        if (
            keccak256(abi.encodePacked((lockup.name()))) ==
            keccak256(abi.encodePacked(("Sablier V2 Lockup Linear NFT")))
        ) {
            expectedTokenURI = string("This is the NFT descriptor of the Sablier V2 Lockup Linear");
        } else if (
            keccak256(abi.encodePacked((lockup.name()))) == keccak256(abi.encodePacked(("Sablier V2 Lockup Pro NFT")))
        ) {
            expectedTokenURI = string("This is the NFT descriptor of the Sablier V2 Lockup Pro");
        }
        assertEq(actualTokenURI, expectedTokenURI, "tokenURI");
    }

    modifier streamNonNull() {
        _;
    }

    /// @dev it should return the descriptor URI.
    function test_TokenURI() external streamNonNull {
        uint256 streamId = createDefaultStream();
        string memory actualTokenURI = lockup.tokenURI({ tokenId: streamId });
        string memory expectedTokenURI;
        if (
            keccak256(abi.encodePacked((lockup.name()))) ==
            keccak256(abi.encodePacked(("Sablier V2 Lockup Linear NFT")))
        ) {
            expectedTokenURI = string("This is the NFT descriptor of the Sablier V2 Lockup Linear");
        } else if (
            keccak256(abi.encodePacked((lockup.name()))) == keccak256(abi.encodePacked(("Sablier V2 Lockup Pro NFT")))
        ) {
            expectedTokenURI = string("This is the NFT descriptor of the Sablier V2 Lockup Pro");
        }
        assertEq(actualTokenURI, expectedTokenURI, "tokenURI");
    }
}
