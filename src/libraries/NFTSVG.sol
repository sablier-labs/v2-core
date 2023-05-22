// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable quotes
pragma solidity >=0.8.19;

import { Base64 } from "@openzeppelin/utils/Base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { SVGComponents } from "./SVGComponents.sol";

library NFTSVG {
    using Strings for uint256;

    uint256 internal constant CARD_MARGIN = 16;

    struct GenerateParams {
        string accentColor;
        string assetAddress;
        string assetSymbol;
        string durationInDays;
        bool isDepleted;
        uint256 percentageStreamed;
        string percentageStreamedText;
        string recipient;
        string sablierAddress;
        string sender;
        string streamedAmountAbbreviated;
        string status;
        string streamingModel;
    }

    function generate(GenerateParams memory params) internal pure returns (string memory encodedSVG) {
        string memory SVG = generateSVG(
            SVGParams({
                accentColor: params.accentColor,
                assetAddress: params.assetAddress,
                assetSymbol: params.assetSymbol,
                durationInDays: params.durationInDays,
                isDepleted: params.isDepleted,
                percentageStreamed: params.percentageStreamed,
                percentageStreamedText: params.percentageStreamedText,
                sablierAddress: params.sablierAddress,
                status: params.status,
                streamedAmountAbbreviated: params.streamedAmountAbbreviated,
                streamingModel: params.streamingModel
            })
        );

        // TODO: change name and description
        string memory json = string.concat(
            "{",
            '"name":"Sablier V2 NFT",',
            '"description":"This NFT represents a Sablier V2 stream",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(SVG)),
            '",',
            '"attributes":{"recipient":"',
            params.recipient,
            '","sender": "',
            params.sender,
            '"}}'
        );

        encodedSVG = Base64.encode(bytes(string.concat("data:application/json;base64,", json)));
    }

    function generateDefs(
        string memory accentColor,
        bool isDepleted,
        string memory progressCard,
        string memory statusCard,
        string memory streamedCard,
        string memory durationCard
    )
        internal
        pure
        returns (string memory defs)
    {
        defs = string.concat(
            "<defs>",
            SVGComponents.GLOW,
            SVGComponents.NOISE,
            SVGComponents.LOGO,
            SVGComponents.FLOATING_TEXT,
            SVGComponents.gradients(accentColor),
            SVGComponents.hourglass(isDepleted),
            progressCard,
            statusCard,
            streamedCard,
            durationCard,
            "</defs>"
        );
    }

    function generateFloatingText(
        string memory sablierAddress,
        string memory streamingModel,
        string memory assetAddress,
        string memory assetSymbol
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<text text-rendering="optimizeSpeed">',
            SVGComponents.floatingText({
                offset: "-100%",
                text: string.concat(sablierAddress, " - Sablier V2 ", streamingModel)
            }),
            SVGComponents.floatingText({
                offset: "0%",
                text: string.concat(sablierAddress, " - Sablier V2 ", streamingModel)
            }),
            SVGComponents.floatingText({ offset: "-50%", text: string.concat(assetAddress, " - ", assetSymbol) }),
            SVGComponents.floatingText({ offset: "50%", text: string.concat(assetAddress, " - ", assetSymbol) }),
            "</text>"
        );
    }

    function generateHrefs(
        uint256 progressXOffset,
        uint256 statusXOffset,
        uint256 streamedXOffset,
        uint256 durationXOffset
    )
        internal
        pure
        returns (string memory hrefs)
    {
        hrefs = string.concat(
            '<use href="#Glow" fill-opacity=".9"/>',
            '<use href="#Glow" x="1000" y="1000" fill-opacity=".9"/>',
            '<use href="#Logo" x="170" y="170" transform="scale(.6)" />'
            '<use href="#Hourglass" x="150" y="90" transform="rotate(10)" transform-origin="500 500"/>',
            '<use href="#Progress" x="',
            progressXOffset.toString(),
            '" y="790"/>',
            '<use href="#Status" x="',
            statusXOffset.toString(),
            '" y="790"/>',
            '<use href="#Streamed" x="',
            streamedXOffset.toString(),
            '" y="790"/>',
            '<use href="#Duration" x="',
            durationXOffset.toString(),
            '" y="790"/>'
        );
    }

    struct SVGParams {
        string accentColor;
        string assetAddress;
        string assetSymbol;
        string durationInDays;
        bool isDepleted;
        uint256 percentageStreamed;
        string percentageStreamedText;
        string sablierAddress;
        string status;
        string streamedAmountAbbreviated;
        string streamingModel;
    }

    struct SVGVars {
        string durationCard;
        uint256 durationXOffset;
        uint256 durationWidth;
        uint256 progressXOffset;
        string progressCard;
        uint256 progressWidth;
        uint256 rowWidth;
        string statusCard;
        uint256 statusXOffset;
        uint256 statusWidth;
        string streamedCard;
        uint256 streamedXOffset;
        uint256 streamedWidth;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory) {
        SVGVars memory vars;

        // Generate the cards.
        (vars.progressWidth, vars.progressCard) = SVGComponents.card({
            cardType: SVGComponents.CardType.PROGRESS,
            accentColor: params.accentColor,
            value: params.percentageStreamedText,
            progress: params.percentageStreamed
        });
        (vars.statusWidth, vars.statusCard) = SVGComponents.card({
            cardType: SVGComponents.CardType.STATUS,
            accentColor: params.accentColor,
            value: params.status,
            progress: 0
        });
        (vars.streamedWidth, vars.streamedCard) = SVGComponents.card({
            cardType: SVGComponents.CardType.STREAMED,
            accentColor: params.accentColor,
            value: params.streamedAmountAbbreviated,
            progress: 0
        });
        (vars.durationWidth, vars.durationCard) = SVGComponents.card({
            cardType: SVGComponents.CardType.DURATION,
            accentColor: params.accentColor,
            value: params.durationInDays,
            progress: 0
        });

        // Calculate the width of the row with all cards.
        vars.rowWidth = vars.streamedWidth + vars.durationWidth + vars.progressWidth + vars.statusWidth + 20 * 3;

        // Calculate the horizontal offsets for each card.
        vars.progressXOffset = (1015 - vars.rowWidth) / 2;
        vars.statusXOffset = vars.progressXOffset + vars.progressWidth + CARD_MARGIN;
        vars.streamedXOffset = vars.statusXOffset + vars.statusWidth + CARD_MARGIN;
        vars.durationXOffset = vars.streamedXOffset + vars.streamedWidth + CARD_MARGIN;

        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000">',
            SVGComponents.STYLE,
            SVGComponents.BACKGROUND,
            generateDefs(
                params.accentColor,
                params.isDepleted,
                vars.progressCard,
                vars.statusCard,
                vars.streamedCard,
                vars.durationCard
            ),
            generateFloatingText(params.sablierAddress, params.streamingModel, params.assetAddress, params.assetSymbol),
            generateHrefs(vars.progressXOffset, vars.statusXOffset, vars.streamedXOffset, vars.durationXOffset),
            "</svg>"
        );
    }
}
