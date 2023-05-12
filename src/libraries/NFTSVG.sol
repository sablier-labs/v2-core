// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Base64 } from "@openzeppelin/utils/Base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { SVGComponents } from "./SVGComponents.sol";

library NFTSVG {
    using Strings for uint256;

    struct GenerateParams {
        string colorAccent;
        string percentageStreamedString;
        uint256 percentageStreamedUInt;
        string streamedAbbreviation;
        string durationInDays;
        string sablierContract;
        string sablierContractType;
        string asset;
        string assetSymbol;
        string recipient;
        string sender;
        string status;
        bool isDepleted;
    }

    struct GenerateVars {
        string progressElement;
        uint256 progressWidth;
        uint256 progressLeftOffset;
        string statusElement;
        uint256 statusLeftOffset;
        uint256 statusWidth;
        string streamedElement;
        uint256 streamedLeftOffset;
        uint256 streamedWidth;
        string durationElement;
        uint256 durationWidth;
        uint256 durationLeftOffset;
        uint256 row;
    }

    function generate(GenerateParams memory params) internal pure returns (string memory) {
        GenerateVars memory vars;

        (vars.progressElement, vars.progressWidth) = SVGComponents.box(
            SVGComponents.BoxType.PROGRESS,
            params.colorAccent,
            params.percentageStreamedString,
            params.percentageStreamedUInt
        );

        (vars.statusElement, vars.statusWidth) =
            SVGComponents.box(SVGComponents.BoxType.STATUS, params.colorAccent, params.status, 0);

        (vars.streamedElement, vars.streamedWidth) =
            SVGComponents.box(SVGComponents.BoxType.STREAMED, params.colorAccent, params.streamedAbbreviation, 0);

        (vars.durationElement, vars.durationWidth) =
            SVGComponents.box(SVGComponents.BoxType.DURATION, params.colorAccent, params.durationInDays, 0);

        vars.row = vars.streamedWidth + vars.durationWidth + vars.progressWidth + vars.statusWidth + 20 * 3;

        vars.progressLeftOffset = (1000 - vars.row) / 2;
        vars.statusLeftOffset = vars.progressLeftOffset + vars.progressWidth + 20;
        vars.streamedLeftOffset = vars.statusLeftOffset + vars.statusWidth + 20;
        vars.durationLeftOffset = vars.streamedLeftOffset + vars.streamedWidth + 20;

        return Base64.encode(
            bytes(
                string.concat(
                    "data:application/json;base64,",
                    generateJSON(
                        JSONParams({
                            colorAccent: params.colorAccent,
                            progressElement: vars.progressElement,
                            progressLeftOffset: vars.progressLeftOffset.toString(),
                            statusElement: vars.statusElement,
                            statusLeftOffset: vars.statusLeftOffset.toString(),
                            streamedElement: vars.streamedElement,
                            streamedLeftOffset: vars.streamedLeftOffset.toString(),
                            durationElement: vars.durationElement,
                            durationLeftOffset: vars.durationLeftOffset.toString(),
                            sablierContract: params.sablierContract,
                            sablierContractType: params.sablierContractType,
                            asset: params.asset,
                            assetSymbol: params.assetSymbol,
                            recipient: params.recipient,
                            sender: params.sender,
                            isDepleted: params.isDepleted
                        })
                    )
                )
            )
        );
    }

    struct JSONParams {
        string colorAccent;
        string progressElement;
        string progressLeftOffset;
        string statusElement;
        string statusLeftOffset;
        string streamedElement;
        string streamedLeftOffset;
        string durationElement;
        string durationLeftOffset;
        string sablierContract;
        string sablierContractType;
        string asset;
        string assetSymbol;
        string recipient;
        string sender;
        bool isDepleted;
    }

    function generateJSON(JSONParams memory params) internal pure returns (string memory) {
        string memory finalSVG = generateSVG(
            SVGParams({
                colorAccent: params.colorAccent,
                progressElement: params.progressElement,
                progressLeftOffset: params.progressLeftOffset,
                statusElement: params.statusElement,
                statusLeftOffset: params.statusLeftOffset,
                streamedElement: params.streamedElement,
                streamedLeftOffset: params.streamedLeftOffset,
                durationElement: params.durationElement,
                durationLeftOffset: params.durationLeftOffset,
                sablierContract: params.sablierContract,
                sablierContractType: params.sablierContractType,
                asset: params.asset,
                assetSymbol: params.assetSymbol,
                isDepleted: params.isDepleted
            })
        );

        // TO DO: change name and description
        return string.concat(
            "{",
            '"name":"Sablier V2 NFT",',
            '"description":"This NFT represents a stream in SablierV2",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSVG)),
            '",',
            '"attributes":{"recipient":"',
            params.recipient,
            '","sender":"',
            params.sender,
            '"}}'
        );
    }

    struct SVGParams {
        string colorAccent;
        string progressElement;
        string progressLeftOffset;
        string statusElement;
        string statusLeftOffset;
        string streamedElement;
        string streamedLeftOffset;
        string durationElement;
        string durationLeftOffset;
        string sablierContract;
        string sablierContractType;
        string asset;
        string assetSymbol;
        bool isDepleted;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory) {
        return string.concat(
            '<svg height="1000" width="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">',
            generateDefs(
                params.colorAccent,
                params.progressElement,
                params.statusElement,
                params.streamedElement,
                params.durationElement,
                params.isDepleted
            ),
            SVGComponents.BACKGROUND,
            generateText(params.sablierContract, params.sablierContractType, params.asset, params.assetSymbol),
            generateHref(
                params.progressLeftOffset, params.statusLeftOffset, params.streamedLeftOffset, params.durationLeftOffset
            ),
            "</svg>"
        );
    }

    function generateDefs(
        string memory colorAccent,
        string memory progressElement,
        string memory statusElement,
        string memory streamedElement,
        string memory durationElement,
        bool isDepleted
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "<defs>",
            SVGComponents.styles(colorAccent),
            SVGComponents.LIGHT,
            SVGComponents.hourglass(isDepleted),
            SVGComponents.LOGO,
            progressElement,
            statusElement,
            streamedElement,
            durationElement,
            "</defs>"
        );
    }

    function generateHref(
        string memory progressLeftOffset,
        string memory statusLeftOffset,
        string memory streamedLeftOffset,
        string memory durationLeftOffset
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<use href="#hourglass" x="150" y="90" transform="rotate(10)" transform-origin="500 500"/>',
            '<use href="#Progress" x="',
            progressLeftOffset,
            '" y="790"/><use href="#Status" x="',
            statusLeftOffset,
            '" y="790"/><use href="#Streamed" x="',
            streamedLeftOffset,
            '" y="790"/><use href="#Duration" x="',
            durationLeftOffset,
            '" y="790"/>'
        );
    }

    function generateText(
        string memory sablierContract,
        string memory sablierContractType,
        string memory asset,
        string memory assetSymbol
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<text text-rendering="optimizeSpeed">',
            SVGComponents.words("-100%", string.concat(sablierContract, " - Sablier ", sablierContractType)),
            SVGComponents.words("0%", string.concat(sablierContract, " - Sablier ", sablierContractType)),
            SVGComponents.words("-50%", string.concat(asset, " - ", assetSymbol)),
            SVGComponents.words("50%", string.concat(asset, " - ", assetSymbol)),
            "</text>"
        );
    }
}
