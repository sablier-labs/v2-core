// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20Metadata } from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC721Metadata } from "@openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ISablierV2Lockup } from "./interfaces/ISablierV2Lockup.sol";
import { ISablierV2NFTDescriptor } from "./interfaces/ISablierV2NFTDescriptor.sol";
import { Lockup } from "./types/DataTypes.sol";

import { NFTSVG } from "./libraries/NFTSVG.sol";

/// @title SablierV2NFTDescriptor
/// @notice See the documentation in {ISablierV2NFTDescriptor}.
contract SablierV2NFTDescriptor is ISablierV2NFTDescriptor {
    using Strings for address;
    using Strings for uint256;

    /// @inheritdoc ISablierV2NFTDescriptor
    function tokenURI(
        IERC721Metadata sablierContract,
        uint256 streamId
    )
        external
        view
        override
        returns (string memory uri)
    {
        ISablierV2Lockup lockup = ISablierV2Lockup(address(sablierContract));
        IERC20Metadata asset = IERC20Metadata(address(lockup.getAsset(streamId)));

        uint128 streamedAmount = lockup.streamedAmountOf(streamId);
        uint40 startTime = lockup.getStartTime(streamId);
        uint40 endTime = lockup.getEndTime(streamId);

        (uint256 percentageStreamedUint, string memory percentageStreamedString) =
            getPercentageStreamed(lockup.getDepositedAmount(streamId), streamedAmount);

        uri = NFTSVG.generate(
            NFTSVG.GenerateParams({
                colorAccent: getColorAccent(uint256(uint160(address(sablierContract))), streamId),
                percentageStreamedUInt: percentageStreamedUint,
                percentageStreamedString: percentageStreamedString,
                streamedAbbreviation: getStreamedAbbreviation(streamedAmount, asset.decimals()),
                durationInDays: getDurationInDays(startTime, endTime),
                sablierContract: address(sablierContract).toHexString(),
                sablierContractType: getSablierContractType(sablierContract.symbol()),
                asset: address(asset).toHexString(),
                assetSymbol: asset.symbol(),
                recipient: uint256(uint160(lockup.ownerOf(streamId))).toString(),
                sender: uint256(uint160(lockup.getSender(streamId))).toString(),
                status: getStreamStatus(lockup.getStatus(streamId)),
                isDepleted: lockup.getStatus(streamId) == Lockup.Status.DEPLETED
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Generates a unique color accent by hashing together the `streamId` and Sablier contract address.
    function getColorAccent(uint256 sablierContract, uint256 streamId) internal view returns (string memory) {
        uint256 chainID = block.chainid;
        string memory str = (uint256(keccak256(abi.encodePacked(chainID, sablierContract, streamId)))).toString();
        // Extract the first 6 characters.
        bytes memory firstSixCharacters = new bytes(6);
        for (uint256 i = 0; i < 6;) {
            firstSixCharacters[i] = bytes(str)[i];
            unchecked {
                i += 1;
            }
        }
        return string.concat("#", string(firstSixCharacters));
    }

    /// @notice Calculates the duration of the stream in days.
    function getDurationInDays(uint256 startTime, uint256 endTime) internal pure returns (string memory) {
        uint256 durationInSeconds = endTime - startTime;
        uint256 durationInDays = durationInSeconds / 86_400;
        return string.concat(durationInDays.toString(), " days");
    }

    /// @notice Computes the percentage of assets that have been streamed.
    function getPercentageStreamed(
        uint256 depositedAmount,
        uint256 streamedAmount
    )
        internal
        pure
        returns (uint256 percentageStreamedUInt, string memory percentageStreamedString)
    {
        // The percentage is represented with 4 decimal here to enable the accurate display of values such as 13.37%.
        percentageStreamedUInt = streamedAmount * 10_000 / depositedAmount;
        // Exctract the last two decimals.
        uint256 fractionalPart = percentageStreamedUInt % 100;
        // Remove the last two decimals.
        percentageStreamedUInt /= 100;

        percentageStreamedString = fractionalPart == 0
            ? string.concat(percentageStreamedUInt.toString(), ("%"))
            : string.concat(percentageStreamedUInt.toString(), ".", fractionalPart.toString(), "%");
    }

    /// @notice Returns the sablier contract type.
    function getSablierContractType(string memory symbol) internal pure returns (string memory) {
        return keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("SAB-V2-LOCKUP-LIN"))
            ? "Lockup Linear"
            : "Lockup Dynamic";
    }

    /// @notice Returns the stream status.
    function getStreamStatus(Lockup.Status status) internal pure returns (string memory) {
        if (status == Lockup.Status.ACTIVE) {
            return "Active";
        } else if (status == Lockup.Status.CANCELED) {
            return "Canceled";
        } else if (status == Lockup.Status.DEPLETED) {
            return "Depleted";
        }
        return "Null";
    }

    /// @notice Returns an abbreviated representation of a streamed amount with a prefix ">= ".
    /// @dev The abbreviation uses metric suffixes such as "k" for thousands, "m" for millions, "b" for billions,
    /// "t" for trillions, and "q" for quadrillions. For example, if the input is 1,234,567,
    /// the output will be ">= 1.23m".
    /// @param streamedAmount The streamed amount to be abbreviated, expressed in the asset's decimals.
    /// @param decimals The number of decimals of the asset used for streaming.
    /// @return The abbreviated representation of the streamed amount as a string.
    function getStreamedAbbreviation(uint256 streamedAmount, uint256 decimals) internal pure returns (string memory) {
        uint256 streamedAmountNoDecimals = streamedAmount / 10 ** decimals;

        // If the streamed amount is greater than 999 quadrillions, return "> 999q", otherwise the function would revert
        // due to `suffixIndex` greater than 5.
        if (streamedAmountNoDecimals > 999e15) {
            return "> 999.99q";
        }

        if (streamedAmountNoDecimals < 1) {
            return " < 1";
        }

        string[] memory suffixes = new string[](6);
        suffixes[0] = "";
        suffixes[1] = "k";
        suffixes[2] = "m";
        suffixes[3] = "b";
        suffixes[4] = "t";
        suffixes[5] = "q";

        uint256 suffixIndex = 0;
        uint256 fractionalPart;

        while (streamedAmountNoDecimals >= 1000) {
            fractionalPart = streamedAmountNoDecimals % 100;
            streamedAmountNoDecimals /= 1000;
            suffixIndex++;
        }

        string memory prefix = ">= ";
        string memory integerPart = streamedAmountNoDecimals.toString();
        string memory decimalPart = fractionalPart == 0 ? "" : string.concat(".", fractionalPart.toString());
        string memory suffix = suffixes[suffixIndex];

        return string.concat(prefix, integerPart, decimalPart, suffix);
    }
}
