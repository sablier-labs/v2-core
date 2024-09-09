// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors as CoreErrors } from "src/core/libraries/Errors.sol";

import { MerkleCampaign_Integration_Shared_Test } from "../../shared/MerkleCampaign.t.sol";

contract SetSablierFee_Integration_Test is MerkleCampaign_Integration_Shared_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        uint256 sablierFee = defaults.SABLIER_FEE();
        resetPrank({ msgSender: users.eve });
        vm.expectRevert(abi.encodeWithSelector(CoreErrors.CallerNotAdmin.selector, users.admin, users.eve));
        merkleFactory.setSablierFee({ fee: sablierFee });
    }

    function test_WhenCallerAdmin() external {
        resetPrank({ msgSender: users.admin });

        // It should emit a {SetSablierFee} event.
        vm.expectEmit({ emitter: address(merkleFactory) });
        emit SetSablierFee({ admin: users.admin, sablierFee: defaults.SABLIER_FEE() });

        merkleFactory.setSablierFee({ fee: defaults.SABLIER_FEE() });

        // It should set the Sablier fee.
        assertEq(merkleFactory.sablierFee(), defaults.SABLIER_FEE(), "sablier fee");
    }
}
