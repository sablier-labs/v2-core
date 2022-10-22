// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { SablierV2 } from "@sablier/v2-core/SablierV2.sol";

import { SablierV2UnitTest } from "../SablierV2UnitTest.t.sol";

contract AbstractSablierV2 is SablierV2 {
    constructor() SablierV2() {
        // solhint-disable-previous-line no-empty-blocks
    }

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC721
    function balanceOf(address owner) external pure returns (uint256) {
        owner;
        return 0;
    }

    /// @inheritdoc IERC721
    function getApproved(uint256 tokenId) external pure returns (address) {
        tokenId;
        return address(0);
    }

    /// @inheritdoc ISablierV2
    function getDepositAmount(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function getRecipient(uint256 streamId) public pure override returns (address) {
        streamId;
        return address(0);
    }

    /// @inheritdoc ISablierV2
    function getReturnableAmount(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function getSender(uint256 streamId) public pure override returns (address) {
        streamId;
        return address(0);
    }

    /// @inheritdoc ISablierV2
    function getStartTime(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function getStopTime(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function getWithdrawableAmount(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function getWithdrawnAmount(uint256 streamId) external pure override returns (uint256) {
        streamId;
        return 0;
    }

    /// @inheritdoc ISablierV2
    function isCancelable(uint256 streamId) public pure override returns (bool) {
        streamId;
        return true;
    }

    /// @inheritdoc IERC721
    function isApprovedForAll(address owner, address operator) external pure returns (bool) {
        owner;
        operator;
        return true;
    }

    /// @inheritdoc ISablierV2
    function isApprovedOrOwner(uint256 streamId) public pure override returns (bool) {
        streamId;
        return true;
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external pure returns (address) {
        tokenId;
        return address(0);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        interfaceId;
        return true;
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC721
    function approve(address to, uint256 tokenId) external pure {
        to;
        tokenId;
    }

    /// @inheritdoc IERC721
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external pure {
        from;
        to;
        tokenId;
    }

    /// @inheritdoc IERC721
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external pure {
        from;
        to;
        tokenId;
        data;
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address operator, bool _approved) external pure {
        operator;
        _approved;
    }

    /// @inheritdoc IERC721
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external pure {
        from;
        to;
        tokenId;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _cancel(uint256 streamId) internal pure override {
        streamId;
    }

    function _renounce(uint256 streamId) internal pure override {
        streamId;
    }

    function _withdraw(
        uint256 streamId,
        address to,
        uint256 amount
    ) internal pure override {
        streamId;
        to;
        amount;
    }
}

/// @title AbstractSablierV2UnitTest
/// @author Sablier Labs Ltd.
/// @notice Common contract members needed across Sablier V2 test contracts.
/// @dev Strictly for test purposes.
abstract contract AbstractSablierV2UnitTest is SablierV2UnitTest {
    AbstractSablierV2 internal abstractSablierV2 = new AbstractSablierV2();

    /// @dev A setup function invoked before each test case.
    function setUp() public virtual {
        // Sets all subsequent calls' `msg.sender` to be `sender`.
        vm.startPrank(users.sender);
    }
}
