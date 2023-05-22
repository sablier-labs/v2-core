// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20Metadata } from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC721Metadata } from "@openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { ISablierV2Lockup } from "./interfaces/ISablierV2Lockup.sol";
import { ISablierV2NFTDescriptor } from "./interfaces/ISablierV2NFTDescriptor.sol";
import { Lockup } from "./types/DataTypes.sol";

import { Errors } from "./libraries/Errors.sol";
import { NFTSVG } from "./libraries/NFTSVG.sol";
import { SVGComponents } from "./libraries/SVGComponents.sol";

/// @title SablierV2NFTDescriptor
/// @notice See the documentation in {ISablierV2NFTDescriptor}.
contract SablierV2NFTDescriptor is ISablierV2NFTDescriptor {
    using Strings for address;
    using Strings for string;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

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

        // Retrieve the stream's data.
        uint128 streamedAmount = lockup.streamedAmountOf(streamId);
        uint40 startTime = lockup.getStartTime(streamId);
        uint40 endTime = lockup.getEndTime(streamId);
        Lockup.Status status = lockup.statusOf(streamId);

        // Calculate how much of the deposit amount has been streamed so far, as a percentage.
        (uint256 percentageStreamedUint, string memory percentageStreamedText) =
            getPercentageStreamed(lockup.getDepositedAmount(streamId), streamedAmount);

        uri = NFTSVG.generate(
            NFTSVG.GenerateParams({
                assetAddress: address(asset).toHexString(),
                assetSymbol: asset.symbol(),
                accentColor: getAccentColor(address(sablierContract), streamId),
                durationInDays: getDurationInDays(startTime, endTime),
                isDepleted: status == Lockup.Status.DEPLETED,
                percentageStreamed: percentageStreamedUint,
                percentageStreamedText: percentageStreamedText,
                recipient: lockup.ownerOf(streamId).toHexString(),
                sablierAddress: address(sablierContract).toHexString(),
                streamingModel: getStreamingModel(sablierContract),
                sender: lockup.getSender(streamId).toHexString(),
                streamedAmountAbbreviated: abbreviateStreamedAmount(streamedAmount, asset.decimals()),
                status: getStatus(status)
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns an abbreviated representation of a streamed amount with a prefix ">= ".
    /// @dev The abbreviation uses metric suffixes:
    /// - "K" for thousands
    /// - "M" for millions
    /// - "B" for billions,
    /// - "T" for trillions
    /// For example, if the input is 1,234,567, the output is ">= 1.23M"..
    /// @param streamedAmount The streamed amount to abbreviate, denoted in units of the asset's decimals.
    /// @param decimals The number of decimals of the streaming asset.
    /// @return abbreviation The abbreviated representation of the streamed amount, as a string.
    function abbreviateStreamedAmount(
        uint256 streamedAmount,
        uint256 decimals
    )
        internal
        pure
        returns (string memory abbreviation)
    {
        uint256 truncatedAmount;
        unchecked {
            truncatedAmount = decimals == 0 ? streamedAmount : streamedAmount / 10 ** decimals;
        }

        // Return dummy texts when the amount is either too small or too large to fit in the layout of the SVG.
        if (truncatedAmount < 1) {
            return string.concat(SVGComponents.SIGN_LT, " 1");
        } else if (truncatedAmount > 999e12) {
            return string.concat(SVGComponents.SIGN_GT, " 999T");
        }

        string[] memory suffixes = new string[](5);
        suffixes[0] = "";
        suffixes[1] = "K"; // thousands
        suffixes[2] = "M"; // millions
        suffixes[3] = "B"; // billions
        suffixes[4] = "T"; // trillions

        uint256 fractionalAmount;
        uint256 suffixIndex = 0;

        // Truncate repeatedly until the amount is less than 1000.
        unchecked {
            while (truncatedAmount >= 1000) {
                fractionalAmount = (truncatedAmount / 10) % 100; // get the first two digits after decimal
                truncatedAmount /= 1000;
                suffixIndex += 1;
            }
        }

        string memory prefix = string.concat(SVGComponents.SIGN_GTE, " ");
        string memory wholePart = truncatedAmount.toString();
        string memory fractionalPart = fractionalAmount == 0 ? "" : string.concat(".", fractionalAmount.toString());
        string memory suffix = suffixes[suffixIndex];

        abbreviation = string.concat(prefix, wholePart, fractionalPart, suffix);
    }

    /// @notice Generates a pseudo-random color accent by hashing together the `chainid`, the Sablier contract address,
    /// and the `streamId`.
    function getAccentColor(address sablierContract, uint256 streamId) internal view returns (string memory) {
        uint256 chainId = block.chainid;

        // Generate a pseudo-random color.
        uint256 color = uint256(keccak256(abi.encodePacked(chainId, sablierContract, streamId)));

        // Extract hue, saturation, and lightness channels from the color.
        uint256 hue = (color >> 16) % 360; // from 0 to 360 inclusive
        uint256 saturation = ((color >> 8) & 0xFF) % 101; // from 0 to 100 inclusive
        uint256 lightness = (color & 0xFF) % 101; // from 0 to 100 inclusive

        // The start of the new lightness range (minimum value for the new lightness).
        uint256 start = 20;

        // The divisor for modulo calculation `100 - start`.
        uint256 clock = 80;

        // Calculate the new lightness value.
        // While the initial value was in the range (0, 100), the new value is in the range (start, 100).
        // This is how very dark colors are excluded from the generated color set.
        unchecked {
            lightness = lightness % clock + start;
        }

        // Represent the colors using HSL mode (Hue, Saturation, and Lightness).
        return string.concat("hsl(", hue.toString(), ", ", saturation.toString(), "%, ", lightness.toString(), "%)");
    }

    /// @notice Calculates the duration of the stream in days.
    function getDurationInDays(uint256 startTime, uint256 endTime) internal pure returns (string memory duration) {
        uint256 durationInDays;
        unchecked {
            durationInDays = (endTime - startTime) / 86_400;
        }

        if (durationInDays == 0) {
            return string.concat(SVGComponents.SIGN_LT, " 1 day");
        } else if (durationInDays > 9999) {
            return string.concat(SVGComponents.SIGN_GT, " 9999 days");
        }

        string memory suffix = durationInDays == 1 ? " day" : " days";
        duration = string.concat(durationInDays.toString(), suffix);
    }

    /// @notice Calculates how much of the deposit amount has been streamed so far, as a percentage.
    function getPercentageStreamed(
        uint256 depositedAmount,
        uint256 streamedAmount
    )
        internal
        pure
        returns (uint256 percentageStreamed, string memory percentageStreamedText)
    {
        // The percentage is represented with 4 decimals to enable the rendering of values like 13.37%.
        percentageStreamed = streamedAmount * 10_000 / depositedAmount;

        // Extract the last two decimals.
        uint256 fractionalPart = percentageStreamed % 100;

        // Remove the last two decimals.
        percentageStreamed /= 100;

        percentageStreamedText = fractionalPart == 0
            ? string.concat(percentageStreamed.toString(), ("%"))
            : string.concat(percentageStreamed.toString(), ".", fractionalPart.toString(), "%");
    }

    /// @notice Retrieves the stream's status as a string.
    function getStatus(Lockup.Status status) internal pure returns (string memory) {
        if (status == Lockup.Status.DEPLETED) {
            return "Depleted";
        } else if (status == Lockup.Status.CANCELED) {
            return "Canceled";
        } else if (status == Lockup.Status.SETTLED) {
            return "Settled";
        } else if (status == Lockup.Status.STREAMING) {
            return "Streaming";
        } else {
            return "Pending";
        }
    }

    /// @notice Retrieves the streaming model as a string.
    /// @dev Reverts on unknown symbols.
    function getStreamingModel(IERC721Metadata sablierContract) internal view returns (string memory model) {
        string memory symbol = sablierContract.symbol();
        if (symbol.equal("SAB-V2-LOCKUP-LIN")) {
            model = "Lockup Linear";
        } else if (symbol.equal("SAB-V2-LOCKUP-DYN")) {
            model = "Lockup Dynamic";
        } else {
            revert Errors.SablierV2NFTDescriptor_InvalidContract(address(sablierContract));
        }
    }
}
