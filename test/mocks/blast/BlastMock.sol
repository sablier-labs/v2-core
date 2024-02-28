// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { GasMode, YieldMode } from "../../../src/interfaces/blast/IBlast.sol";

/// @dev https://github.com/blast-io/blast/blob/master/blast-optimism/packages/contracts-bedrock/src/L2/Blast.sol
contract BlastMock {
    GasMock public immutable GAS;
    YieldMock public immutable YIELD;

    mapping(address => address) public governorMap;

    constructor() {
        GAS = new GasMock();
        YIELD = new YieldMock();
    }

    function configure(YieldMode yieldMode, GasMode gasMode, address governor) public {
        governorMap[msg.sender] = governor;
        GAS.setGasMode(msg.sender, gasMode);
        YIELD.configure(msg.sender, uint8(yieldMode));
    }

    function readYieldConfiguration(address contractAddress) public view returns (uint8) {
        return YIELD.getConfiguration(contractAddress);
    }

    function readGasParams(address contractAddress) public view returns (uint256, uint256, uint256, GasMode) {
        return GAS.readGasParams(contractAddress);
    }
}

contract GasMock {
    address public immutable BLAST_MOCK;

    mapping(address => GasMode) internal _gasMode;

    modifier onlyBlastMock() {
        require(msg.sender == BLAST_MOCK, "Caller must be blast mock contract");
        _;
    }

    constructor() {
        BLAST_MOCK = msg.sender;
    }

    function readGasParams(address contractAddress) public view returns (uint256, uint256, uint256, GasMode) {
        return (0, 0, 0, _gasMode[contractAddress]);
    }

    function setGasMode(address contractAddress, GasMode gasMode) public onlyBlastMock {
        _gasMode[contractAddress] = gasMode;
    }
}

contract YieldMock {
    address public immutable BLAST_MOCK;

    mapping(address => YieldMode) internal _yieldMode;

    modifier onlyBlastMock() {
        require(msg.sender == BLAST_MOCK, "Caller must be blast mock contract");
        _;
    }

    constructor() {
        BLAST_MOCK = msg.sender;
    }

    function getConfiguration(address contractAddress) public view returns (uint8) {
        return uint8(_yieldMode[contractAddress]);
    }

    function configure(address contractAddress, uint8 flag) public onlyBlastMock returns (uint256) {
        _yieldMode[contractAddress] = YieldMode(flag);
        return flag;
    }
}
