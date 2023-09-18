// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable quotes
pragma solidity >=0.8.19;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { SVGElements } from "./SVGElements.sol";

library NFTSVG {
    using Strings for uint256;

    uint256 internal constant CARD_MARGIN = 16;

    struct SVGParams {
        string accentColor;
        string assetAddress;
        string assetSymbol;
        string duration;
        string progress;
        uint256 progressNumerical;
        string sablierAddress;
        string status;
        string streamingModel;
        string total;
    }

    struct SVGVars {
        string cards;
        uint256 cardsWidth;
        string durationCard;
        uint256 durationWidth;
        uint256 durationXPosition;
        string progressCard;
        uint256 progressWidth;
        uint256 progressXPosition;
        string statusCard;
        uint256 statusWidth;
        uint256 statusXPosition;
        string totalCard;
        uint256 totalWidth;
        uint256 totalXPosition;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory) {
        SVGVars memory vars;

        // Generate the progress card.
        (vars.progressWidth, vars.progressCard) = SVGElements.card({
            cardType: SVGElements.CardType.PROGRESS,
            content: params.progress,
            circle: SVGElements.progressCircle({
                progressNumerical: params.progressNumerical,
                accentColor: params.accentColor
            })
        });

        // Generate the status card.
        (vars.statusWidth, vars.statusCard) =
            SVGElements.card({ cardType: SVGElements.CardType.STATUS, content: params.status });

        // Generate the total card.
        (vars.totalWidth, vars.totalCard) =
            SVGElements.card({ cardType: SVGElements.CardType.TOTAL, content: params.total });

        // Generate the duration card.
        (vars.durationWidth, vars.durationCard) =
            SVGElements.card({ cardType: SVGElements.CardType.DURATION, content: params.duration });

        unchecked {
            // Calculate the width of the row containing the cards and the margins between them.
            vars.cardsWidth =
                vars.totalWidth + vars.durationWidth + vars.progressWidth + vars.statusWidth + CARD_MARGIN * 3;

            // Calculate the positions on the X axis based on the following layout:
            //
            // ___________________________ SVG Width (1000px) ___________________________
            // |     |          |      |        |      |        |      |          |     |
            // | <-> | Progress | 16px | Status | 16px | Total  | 16px | Duration | <-> |
            vars.progressXPosition = (1000 - vars.cardsWidth) / 2;
            vars.statusXPosition = vars.progressXPosition + vars.progressWidth + CARD_MARGIN;
            vars.totalXPosition = vars.statusXPosition + vars.statusWidth + CARD_MARGIN;
            vars.durationXPosition = vars.totalXPosition + vars.totalWidth + CARD_MARGIN;
        }

        // Concatenate all cards.
        vars.cards = string.concat(vars.progressCard, vars.statusCard, vars.totalCard, vars.durationCard);

        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000" viewBox="0 0 1000 1000">',
            SVGElements.BACKGROUND,
            generateDefs(params.accentColor, params.status, vars.cards),
            generateFloatingText(params.sablierAddress, params.streamingModel, params.assetAddress, params.assetSymbol),
            generateHrefs(vars.progressXPosition, vars.statusXPosition, vars.totalXPosition, vars.durationXPosition),
            "</svg>"
        );
    }

    function generateDefs(
        string memory accentColor,
        string memory status,
        string memory cards
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "<defs>",
            SVGElements.GLOW,
            SVGElements.NOISE,
            SVGElements.LOGO,
            SVGElements.FLOATING_TEXT,
            SVGElements.gradients(accentColor),
            SVGElements.hourglass(status),
            cards,
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
            SVGElements.floatingText({
                offset: "-100%",
                text: string.concat(sablierAddress, unicode" • ", "Sablier V2 ", streamingModel)
            }),
            SVGElements.floatingText({
                offset: "0%",
                text: string.concat(sablierAddress, unicode" • ", "Sablier V2 ", streamingModel)
            }),
            SVGElements.floatingText({ offset: "-50%", text: string.concat(assetAddress, unicode" • ", assetSymbol) }),
            SVGElements.floatingText({ offset: "50%", text: string.concat(assetAddress, unicode" • ", assetSymbol) }),
            "</text>"
        );
    }

    function generateHrefs(
        uint256 progressXPosition,
        uint256 statusXPosition,
        uint256 totalXPosition,
        uint256 durationXPosition
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<use href="#Glow" fill-opacity=".9"/>',
            '<use href="#Glow" x="1000" y="1000" fill-opacity=".9"/>',
            '<use href="#Logo" x="170" y="170" transform="scale(.6)"/>'
            '<use href="#Hourglass" x="150" y="90" transform="rotate(10)" transform-origin="500 500"/>',
            '<use href="#Progress" x="',
            progressXPosition.toString(),
            '" y="790"/>',
            '<use href="#Status" x="',
            statusXPosition.toString(),
            '" y="790"/>',
            '<use href="#Total" x="',
            totalXPosition.toString(),
            '" y="790"/>',
            '<use href="#Duration" x="',
            durationXPosition.toString(),
            '" y="790"/>'
        );
    }
}
