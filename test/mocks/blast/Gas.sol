// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { GasMode, IGas } from "src/interfaces/blast/IGas.sol";

contract Gas is IGas, PRBTest {
    /// @dev Blast.sol --> controls all access to Gas.sol
    address public immutable blastConfigurationContract;

    mapping(address contractAddress => uint256) public claimableGas;
    mapping(address contractAddress => GasMode) public gasMode;

    /// @dev this tracks the timestamp when gas is updated
    uint256 public lastUpdated = block.timestamp;

    /// @notice Allows only the Blast Configuration Contract to call a function
    modifier onlyBlastConfigurationContract() {
        require(msg.sender == blastConfigurationContract, "Caller must be blast configuration contract");
        _;
    }

    constructor() {
        blastConfigurationContract = msg.sender;
    }

    function readGasParams(address contractAddress)
        public
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated_, GasMode gasMode_)
    {
        return (0, claimableGas[contractAddress], lastUpdated, gasMode[contractAddress]);
    }

    /// @dev This function is used to simulate claiming gas.
    function claim(
        address contractAddress,
        address recipient,
        uint256 gasToClaim,
        uint256
    )
        public
        onlyBlastConfigurationContract
        returns (uint256)
    {
        if (gasMode[contractAddress] == GasMode.CLAIMABLE) {
            claimableGas[contractAddress] = claimableGas[contractAddress] - gasToClaim;
            vm.deal(recipient, recipient.balance + gasToClaim);
            return gasToClaim;
        }

        return 0;
    }

    /// @dev This function is used to simulate claiming all gas.
    function claimAll(address contractAddress, address recipient) public returns (uint256) {
        uint256 amount = claimableGas[contractAddress];
        return claim(contractAddress, recipient, amount, 0);
    }

    function claimGasAtMinClaimRate(address contractAddress, address recipient, uint256) public returns (uint256) {
        return claimAll(contractAddress, recipient);
    }

    function claimMax(address contractAddress, address recipient) public returns (uint256) {
        return claimAll(contractAddress, recipient);
    }

    /// @dev This function is used to simulate configuring the gas mode of the `contractAddress`.
    function setGasMode(address contractAddress, GasMode mode) public onlyBlastConfigurationContract {
        gasMode[contractAddress] = mode;
    }

    function setLastUpdated() public onlyBlastConfigurationContract {
        lastUpdated = block.timestamp;
    }
}
