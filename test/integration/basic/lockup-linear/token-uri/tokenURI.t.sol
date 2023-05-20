// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

// solhint-disable
import { console2 } from "forge-std/console2.sol";

import { LockupLinear } from "src/types/DataTypes.sol";

import { Linear_Integration_Basic_Test } from "../Linear.t.sol";

contract TokenURI_Linear_Integration_Basic_Test is Linear_Integration_Basic_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        Linear_Integration_Basic_Test.setUp();

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

    function test_TokenURI_Linear_ProgressBoxZero() external view whenNFTExists {
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_ProgressBoxQuarter() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_ProgressBoxWithDecimals() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 2 - 1 });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_ProgressBoxFull() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StatusBoxPending() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() - 1 });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StatusBoxStreaming() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StatusBoxSettled() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StatusBoxCanceled() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() });
        linear.cancel(defaultStreamId);
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StatusBoxDepleted() external whenNFTExists {
        vm.warp({ timestamp: defaults.END_TIME() });
        linear.withdraw(defaultStreamId, users.recipient, defaults.DEPOSIT_AMOUNT());
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StreamedBoxLessThanOne() external view whenNFTExists {
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StreamedBoxLessThanTen() external whenNFTExists {
        uint40 cliffTime = defaults.START_TIME();
        uint256 streamId = createDefaultStreamWithCliffTime(cliffTime);
        vm.warp({ timestamp: cliffTime + 5 });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxTens() external whenNFTExists {
        uint40 cliffTime = defaults.START_TIME();
        uint256 streamId = createDefaultStreamWithCliffTime(cliffTime);
        vm.warp({ timestamp: cliffTime + 15 });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxHundreds() external whenNFTExists {
        uint40 cliffTime = defaults.START_TIME();
        uint256 streamId = createDefaultStreamWithCliffTime(cliffTime);
        vm.warp({ timestamp: cliffTime + 200 });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxThousands() external whenNFTExists {
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() });
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_StreamedBoxMillions() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithTotalAmount(1_244_567 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxBillions() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithTotalAmount(100e9 * 1e18);
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 2 });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxTrillions() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithTotalAmount(100e12 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_StreamedBoxQuadrillions() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithTotalAmount(10e15 * 1e18);
        vm.warp({ timestamp: defaults.END_TIME() });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_DurationBoxLessThanOne() external view whenNFTExists {
        console2.log("URI:", linear.tokenURI(defaultStreamId));
    }

    function test_TokenURI_Linear_DurationBoxTenDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 864_000);
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_DurationBoxOneHundredDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 8_640_000);
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_DurationBoxOneThousandDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 86_400_000);
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_DurationBoxTenThousandsDays() external whenNFTExists {
        uint256 streamId = createDefaultStreamWithEndTime(defaults.START_TIME() + 864_000_000);
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_WideBoxes() external whenNFTExists {
        uint40 endTime = defaults.START_TIME() + 864_000_000;
        uint128 totalAmount = 123_456_789_123e18 * 2;

        LockupLinear.CreateWithRange memory params = defaults.createWithRange();
        params.range.end = endTime;
        params.totalAmount = totalAmount;
        uint256 streamId = linear.createWithRange(params);

        vm.warp({ timestamp: endTime - (864_000_000 / 2) - 1 });
        console2.log("URI:", linear.tokenURI(streamId));
    }

    function test_TokenURI_Linear_DifferentColorAccent() external whenNFTExists {
        for (uint256 i = 0; i < 7; ++i) {
            createDefaultStream();
        }

        uint256 streamId = createDefaultStream();
        console2.log("URI:", linear.tokenURI(streamId));
    }
}
