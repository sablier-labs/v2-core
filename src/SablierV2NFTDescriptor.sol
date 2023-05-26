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
import { SVGElements } from "./libraries/SVGElements.sol";

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
    function tokenURI(IERC721Metadata nft, uint256 streamId) external view override returns (string memory uri) {
        ISablierV2Lockup lockup = ISablierV2Lockup(address(nft));
        IERC20Metadata asset = IERC20Metadata(address(lockup.getAsset(streamId)));

        // Retrieve the stream's data.
        uint128 streamedAmount = lockup.streamedAmountOf(streamId);
        Lockup.Status status = lockup.statusOf(streamId);

        // Calculate how much of the deposit amount has been streamed so far, as a percentage.
        uint256 streamedPercentage = calculateStreamedPercentage(streamedAmount, lockup.getDepositedAmount(streamId));

        uri = NFTSVG.generate(
            NFTSVG.GenerateParams({
                accentColor: generateAccentColor(address(nft), streamId),
                assetAddress: address(asset).toHexString(),
                assetSymbol: safeAssetSymbol(address(asset)),
                duration: calculateDurationInDays(lockup.getStartTime(streamId), lockup.getEndTime(streamId)),
                nftAddress: address(nft).toHexString(),
                progress: stringifyPercentage(streamedPercentage),
                progressNumerical: streamedPercentage,
                recipient: lockup.getRecipient(streamId).toHexString(),
                sender: lockup.getSender(streamId).toHexString(),
                streamed: abbreviateAmount(streamedAmount, safeAssetDecimals(address(asset))),
                streamingModel: mapSymbol(nft),
                status: stringifyStatus(status)
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Produces an abbreviated representation of the provided amount, rounded down and prefixed with ">= ".
    /// @dev The abbreviation uses these suffixes:
    /// - "K" for thousands
    /// - "M" for millions
    /// - "B" for billions,
    /// - "T" for trillions
    /// For example, if the input is 1,234,567, the output is ">= 1.23M".
    /// @param amount The amount to abbreviate, denoted in units of `decimals`.
    /// @param decimals The number of decimals to assume when abbreviating the amount.
    /// @return abbreviation The abbreviated representation of the provided amount, as a string.
    function abbreviateAmount(uint256 amount, uint256 decimals) internal pure returns (string memory) {
        uint256 truncatedAmount;
        unchecked {
            truncatedAmount = decimals == 0 ? amount : amount / 10 ** decimals;
        }

        // Return dummy values when the amount is either very small or very big.
        if (truncatedAmount < 1) {
            return string.concat(SVGElements.SIGN_LT, " 1");
        } else if (truncatedAmount >= 1e15) {
            return string.concat(SVGElements.SIGN_GT, " 999.99T");
        }

        string[5] memory suffixes = ["", "K", "M", "B", "T"];
        uint256 fractionalAmount;
        uint256 suffixIndex = 0;

        // Truncate repeatedly until the amount is less than 1000.
        unchecked {
            while (truncatedAmount >= 1000) {
                fractionalAmount = (truncatedAmount / 10) % 100; // keep the first two digits after the decimal point
                truncatedAmount /= 1000;
                suffixIndex += 1;
            }
        }

        // Concatenate the calculated parts to form the final string.
        string memory prefix = string.concat(SVGElements.SIGN_GE, " ");
        string memory wholePart = truncatedAmount.toString();
        string memory fractionalPart = fractionalAmount == 0 ? "" : string.concat(".", fractionalAmount.toString());
        return string.concat(prefix, wholePart, fractionalPart, suffixes[suffixIndex]);
    }

    /// @notice Calculates the stream's duration in days, rounding down.
    function calculateDurationInDays(uint256 startTime, uint256 endTime) internal pure returns (string memory) {
        uint256 durationInDays;
        unchecked {
            durationInDays = (endTime - startTime) / 1 days;
        }

        // Return dummy values when the duration is either very small or very big.
        if (durationInDays == 0) {
            return string.concat(SVGElements.SIGN_LT, " 1 Day");
        } else if (durationInDays > 9999) {
            return string.concat(SVGElements.SIGN_GT, " 9999 Days");
        }

        string memory suffix = durationInDays == 1 ? " Day" : " Days";
        return string.concat(durationInDays.toString(), suffix);
    }

    /// @notice Calculates how much of the deposited amount has been streamed so far, as a percentage with 4 implied
    /// decimals.
    function calculateStreamedPercentage(
        uint128 streamedAmount,
        uint128 depositedAmount
    )
        internal
        pure
        returns (uint256)
    {
        // This cannot overflow because both inputs are uint128s, and zero deposit amounts are not allowed in Sablier.
        unchecked {
            return streamedAmount * 10_000 / depositedAmount;
        }
    }

    /// @notice Generates a pseudo-random HSL color by hashing together the `chainid`, the `nft` contract address,
    /// and the `streamId`. This will be used as the accent color for the SVG.
    function generateAccentColor(address nft, uint256 streamId) internal view returns (string memory) {
        // The chain id is part of the hash so that the generated color is different across chains.
        uint256 chainId = block.chainid;

        // Hash the parameters to generate a pseudo-random bit field, which will be used as entropy.
        // | Hue     | Saturation | Lightness | -> Roles
        // | [31:16] | [15:8]     | [7:0]     | -> Bit positions
        uint32 bitField = uint32(uint256(keccak256(abi.encodePacked(chainId, nft, streamId))));

        unchecked {
            // The hue is a degree on a color wheel, so its range is [0, 360).
            // Shifting 16 bits to the right means using the bits at positions [31:16].
            uint256 hue = (bitField >> 16) % 360;

            // The saturation is a percentage where 0% is grayscale and 100% is the full color.
            // Shifting 8 bits to the risk and applying an 8-bit mask means using the bits at positions [15:8].
            uint256 saturation = ((bitField >> 8) & 0xFF) % 101;

            // The lightness is typically a percentage between 0% (black) and 100% (white), but here the range
            // is bounded to [20,100] to avoid very dark colors.
            // Applying an 8-bit mask means using the bits at positions [7:0].
            uint256 lightness = (bitField & 0xFF) % 80 + 20;

            // Finally, concatenate the HSL values to form an SVG color string.
            return string.concat("hsl(", hue.toString(), ",", saturation.toString(), "%,", lightness.toString(), "%)");
        }
    }

    /// @notice Maps ERC-721 symbol to human-readable streaming models.
    /// @dev Reverts if the symbol is unknown.
    function mapSymbol(IERC721Metadata nft) internal view returns (string memory) {
        string memory symbol = nft.symbol();
        if (symbol.equal("SAB-V2-LOCKUP-LIN")) {
            return "Lockup Linear";
        } else if (symbol.equal("SAB-V2-LOCKUP-DYN")) {
            return "Lockup Dynamic";
        } else {
            revert Errors.SablierV2NFTDescriptor_UnknownNFT(nft, symbol);
        }
    }

    /// @notice Retrieves the asset's decimals safely, defaulting to "0" if an error occurs.
    /// @dev Performs a low-level call to handle assets in which the decimals are not implemented.
    function safeAssetDecimals(address asset) internal view returns (uint8 decimals) {
        (bool success, bytes memory returnData) =
            asset.staticcall(abi.encodeWithSelector(IERC20Metadata.decimals.selector));
        if (success && returnData.length == 32) {
            decimals = abi.decode(returnData, (uint8));
        }
    }

    /// @notice Retrieves the asset's symbol safely, defaulting to a hard-coded value if an error occurs.
    /// @dev Performs a low-level call to handle assets in which the symbol is not implemented or it is a bytes32
    /// instead of a string.
    function safeAssetSymbol(address asset) internal view returns (string memory) {
        (bool success, bytes memory symbol) = asset.staticcall(abi.encodeWithSelector(IERC20Metadata.symbol.selector));

        // Non-empty strings have a length greater than 64, and bytes32 has length 32.
        if (!success || symbol.length <= 64) {
            return "ERC20";
        }

        return abi.decode(symbol, (string));
    }

    /// @notice Converts the provided percentage to a string.
    function stringifyPercentage(uint256 percentage) internal pure returns (string memory) {
        // Extract the last two decimals.
        uint256 fractionalAmount = percentage % 100;

        // Remove the last two decimals.
        string memory wholePart = (percentage / 100).toString();

        // Omit the fractional part if it is zero.
        if (fractionalAmount == 0) {
            return string.concat(wholePart, ("%"));
        }
        // Add a leading zero if the fractional part is less than 10, e.g. 0.01%.
        else if (fractionalAmount < 10) {
            return string.concat(wholePart, ".0", fractionalAmount.toString(), "%");
        }
        // Concatenate the whole and fractional parts.
        else {
            return string.concat(wholePart, ".", fractionalAmount.toString(), "%");
        }
    }

    /// @notice Retrieves the stream's status as a string.
    function stringifyStatus(Lockup.Status status) internal pure returns (string memory) {
        if (status == Lockup.Status.DEPLETED) {
            return "Depleted";
        } else if (status == Lockup.Status.CANCELED) {
            return "Canceled";
        } else if (status == Lockup.Status.STREAMING) {
            return "Streaming";
        } else if (status == Lockup.Status.SETTLED) {
            return "Settled";
        } else {
            return "Pending";
        }
    }
}
