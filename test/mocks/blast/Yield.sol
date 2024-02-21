// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { IYield, YieldMode } from "src/interfaces/blast/IYield.sol";

contract Yield is IYield, PRBTest {
    /// @dev Blast.sol --> controls all access to Yield.sol
    address public immutable blastConfigurationContract;

    mapping(address contractAddress => uint256) public claimableYield;
    mapping(address contractAddress => YieldMode) public yieldMode;

    /// @notice Allows only the Blast Configuration Contract to call a function
    modifier onlyBlastConfigurationContract() {
        require(msg.sender == blastConfigurationContract, "Caller must be blast configuration contract");
        _;
    }

    constructor() {
        blastConfigurationContract = msg.sender;
    }

    function getClaimableAmount(address contractAddress) public view returns (uint256 amount) {
        return claimableYield[contractAddress];
    }

    function getConfiguration(address contractAddress) public view returns (uint8) {
        return uint8(yieldMode[contractAddress]);
    }

    /// @dev This function is used to simulate claiming yield. It updates the `claimableYield` and sends the desired
    /// amount to the recipient.
    function claim(
        address contractAddress,
        address recipientOfYield,
        uint256 desiredAmount
    )
        public
        onlyBlastConfigurationContract
        returns (uint256)
    {
        if (yieldMode[contractAddress] == YieldMode.CLAIMABLE) {
            claimableYield[contractAddress] = claimableYield[contractAddress] - desiredAmount;
            vm.deal(recipientOfYield, recipientOfYield.balance + desiredAmount);
            return desiredAmount;
        }
        return 0;
    }

    /// @dev This function is used to simulate configuring the yield mode of the `contractAddress`.
    function configure(address contractAddress, uint8 flags) public onlyBlastConfigurationContract returns (uint256) {
        yieldMode[contractAddress] = YieldMode(flags);
        return flags;
    }
}
