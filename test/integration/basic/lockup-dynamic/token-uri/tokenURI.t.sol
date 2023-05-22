// SPDX-License-Identifier: UNLICENSED
// solhint-disable no-console
pragma solidity >=0.8.19 <0.9.0;

import { ud } from "@prb/math/UD60x18.sol";
import { console2 } from "forge-std/console2.sol";

import { Broker, LockupDynamic } from "src/types/DataTypes.sol";

import { Dynamic_Integration_Basic_Test } from "../Dynamic.t.sol";

contract TokenURI_Integration_Test is Dynamic_Integration_Basic_Test {
    Broker internal broker = Broker({ account: users.broker, fee: ud(0) });
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        Dynamic_Integration_Basic_Test.setUp();

        changePrank({ msgSender: users.sender });
        defaultStreamId = createDefaultStream();

        // Fund the sender with 10 quadrillions DAI.
        deal({ token: address(dai), to: users.sender, give: 10e15 * 1e18 });
    }

    function test_RevertWhen_NFTDoesNotExist() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert("ERC721: invalid token ID");
        lockup.tokenURI({ tokenId: nullStreamId });
    }

    modifier whenNFTExists() {
        _;
    }

    function test_TokenURI_Dynamic_ProgressBoxZero() external view whenNFTExists {
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_ProgressBoxQuarter() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 4 });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_ProgressBoxWithDecimals() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 2 - 1 });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_ProgressBoxFull() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StatusBoxPending() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() - 1 });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StatusBoxStreaming() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 4 });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StatusBoxSettled() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StatusBoxCanceled() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 4 });
        dynamic.cancel(defaultStreamId);
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StatusBoxDepleted() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        dynamic.withdraw(defaultStreamId, users.recipient, defaults.DEPOSIT_AMOUNT());
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxLessThanOne() external view whenNFTExists {
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxLessThanTen() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + 400 seconds });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxTens() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + 800 seconds });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxHundreds() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + 1000 seconds });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxThousands() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() });
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxMillions() external whenNFTExists {
        uint256 streamId = createStreamWithTotalAmount(1_234_566 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxBillions() external whenNFTExists {
        uint256 streamId = createStreamWithTotalAmount(100e9 * 1e18);
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 2 });
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxTrillions() external whenNFTExists {
        uint256 streamId = createStreamWithTotalAmount(100e12 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_StreamedBoxQuadrillions() external whenNFTExists {
        uint256 streamId = createStreamWithTotalAmount(10e15 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_DurationBoxLessThanOne() external view whenNFTExists {
        console2.log("URI:", dynamic.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Dynamic_DurationBoxTenDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 864_000);
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_DurationBoxOneHundredDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 8_640_000);
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_DurationBoxOneThousandDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 86_400_000);
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_DurationBoxTenThousandsDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 864_000_000);
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    modifier setProtocolFeeToZero() {
        changePrank({ msgSender: users.admin });
        comptroller.setProtocolFee({ asset: dai, newProtocolFee: ud(0) });
        changePrank({ msgSender: users.sender });
        _;
    }

    function test_TokenURI_Dynamic_WideBoxes() external whenNFTExists setProtocolFeeToZero {
        uint40 endTime = defaults.START_TIME() + 864_000_000;
        uint128 totalAmount = 123_456_789_123e18 * 2;

        LockupDynamic.CreateWithMilestones memory params = defaults.createWithMilestones();

        uint256 segmentsCount = params.segments.length;
        params.segments[segmentsCount - 1].milestone = endTime;
        params.segments[0].amount = totalAmount / 2;
        params.segments[1].amount = totalAmount / 2;
        params.totalAmount = totalAmount;
        params.broker = broker;

        uint256 streamId = dynamic.createWithMilestones(params);

        vm.warp({ timestamp: endTime - (864_000_000 / 2) - 1 });
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    function test_TokenURI_Dynamic_DifferentColorAccent() external whenNFTExists {
        for (uint256 i = 0; i < 7; ++i) {
            createStreamWithTotalAmount(10_000e18);
        }

        uint256 streamId = createStreamWithTotalAmount(10_000e18);
        console2.log("URI:", dynamic.tokenURI(streamId));
    }

    /// @dev We are not using the create default function because it would be harder to calculate the segments amount
    /// and the total amount with the protocol fee set to 0.1% and a broker fee set to 0.3%.
    function createStreamWithTotalAmount(uint128 totalAmount)
        internal
        setProtocolFeeToZero
        returns (uint256 streamId)
    {
        LockupDynamic.CreateWithMilestones memory params = defaults.createWithMilestones();
        params.broker = broker;
        params.totalAmount = totalAmount;
        params.segments[0].amount = totalAmount / 2;
        params.segments[1].amount = totalAmount / 2;

        streamId = dynamic.createWithMilestones(params);
    }
}
