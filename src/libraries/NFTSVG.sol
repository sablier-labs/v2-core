// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Base64 } from "@openzeppelin/utils/base64.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";

import { SVGComponents } from "./SVGComponents.sol";

library NFTSVG {
    using Strings for uint256;

    struct GenerateParams {
        string sablierContract;
        string asset;
        string assetSymbol;
        string sablierContractType;
        string percentageStreamedString;
        uint256 percentageStreamedUInt;
        string durationInDays;
        string colorAccent;
        string recipient;
        string sender;
    }

    struct GenerateVars {
        string curveElement;
        uint256 curveWidth;
        string progressElement;
        uint256 progressWidth;
        string durationElement;
        uint256 durationWidth;
        uint256 row;
        uint256 progressLeft;
        uint256 curveLeft;
        uint256 durationLeft;
    }

    function generate(GenerateParams memory params) internal pure returns (string memory) {
        GenerateVars memory vars;
        (vars.curveElement, vars.curveWidth) =
            SVGComponents.box(SVGComponents.BoxType.CURVE, params.sablierContractType, params.colorAccent, 0);

        (vars.progressElement, vars.progressWidth) = SVGComponents.box(
            SVGComponents.BoxType.PROGRESS,
            params.percentageStreamedString,
            params.colorAccent,
            params.percentageStreamedUInt
        );

        (vars.durationElement, vars.durationWidth) =
            SVGComponents.box(SVGComponents.BoxType.DURATION, params.durationInDays, params.colorAccent, 0);

        vars.row = vars.curveWidth + vars.progressWidth + vars.durationWidth + 20 * 2;

        vars.progressLeft = (1000 - vars.row) / 2;
        vars.curveLeft = vars.progressLeft + vars.progressWidth + 20;
        vars.durationLeft = vars.curveLeft + vars.curveWidth + 20;

        return Base64.encode(
            bytes(
                string.concat(
                    "data:application/json;base64,",
                    generateJSON(
                        JSONParams({
                            generateVars: vars,
                            colorAccent: params.colorAccent,
                            sablierContract: params.sablierContract,
                            asset: params.asset,
                            assetSymbol: params.assetSymbol,
                            recipient: params.recipient,
                            sender: params.sender
                        })
                    )
                )
            )
        );
    }

    struct JSONParams {
        GenerateVars generateVars;
        string colorAccent;
        string sablierContract;
        string asset;
        string assetSymbol;
        string recipient;
        string sender;
    }

    function generateJSON(JSONParams memory params) internal pure returns (string memory) {
        string memory finalSVG = generateSVG(
            SVGParams({
                colorAccent: params.colorAccent,
                curveElement: params.generateVars.curveElement,
                progressElement: params.generateVars.progressElement,
                durationElement: params.generateVars.durationElement,
                sablierContract: params.sablierContract,
                asset: params.asset,
                assetSymbol: params.assetSymbol,
                progressLeft: params.generateVars.progressLeft.toString(),
                curveLeft: params.generateVars.curveLeft.toString(),
                durationLeft: params.generateVars.durationLeft.toString()
            })
        );

        // TO DO: change name and description
        return string.concat(
            "{",
            '"name": "Sablier V2 NFT",',
            '"description": This NFT represents a stream in SablierV2,',
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(finalSVG)),
            '"attributes": recipient: ',
            params.recipient,
            "sender: ",
            params.sender,
            "}"
        );
    }

    struct SVGParams {
        string colorAccent;
        string curveElement;
        string progressElement;
        string durationElement;
        string sablierContract;
        string asset;
        string assetSymbol;
        string progressLeft;
        string curveLeft;
        string durationLeft;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory) {
        return string.concat(
            '<svg height="1000" width="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg"> ',
            generateDefs(params.colorAccent, params.curveElement, params.progressElement, params.durationElement),
            SVGComponents.BACKGROUND,
            generateText(params.sablierContract, params.asset, params.assetSymbol),
            generateHref(params.progressLeft, params.curveLeft, params.durationLeft),
            "</svg>"
        );
    }

    function generateDefs(
        string memory colorAccent,
        string memory curveElement,
        string memory progressElement,
        string memory durationElement
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "<defs>",
            SVGComponents.styles(colorAccent),
            SVGComponents.LIGHT,
            SVGComponents.HOURGLASS,
            SVGComponents.LOGO,
            curveElement,
            progressElement,
            durationElement,
            "</defs>"
        );
    }

    function generateHref(
        string memory progressLeft,
        string memory curveLeft,
        string memory durationLeft
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<use href="#hourglass" x="150" y="90" transform="rotate(10)" transform-origin="500 500" /> <use href="#progress" x="',
            progressLeft,
            '" y="800" /> <use href="#curve" x="',
            curveLeft,
            '" y="800" /> <use href="#duration" x="',
            durationLeft,
            '" y="800" />'
        );
    }

    function generateText(
        string memory sablierContract,
        string memory asset,
        string memory assetSymbol
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            '<text text-rendering="optimizeSpeed"> ',
            SVGComponents.words("-100%", string.concat(sablierContract, " - Sablier")),
            SVGComponents.words("0%", string.concat(sablierContract, " - Sablier")),
            SVGComponents.words("-50%", string.concat(asset, " - ", assetSymbol)),
            SVGComponents.words("50%", string.concat(asset, " - ", assetSymbol)),
            "</text>"
        );
    }
}
