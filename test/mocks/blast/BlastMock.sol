// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { GasMode, YieldMode } from "../../../src/interfaces/blast/IBlast.sol";

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
        YIELD.configure(msg.sender, yieldMode);
    }

    function getConfig(address contractAddress)
        public
        view
        returns (YieldMode yieldMode, GasMode gasMode, address governor)
    {
        yieldMode = YIELD.getYieldMode(contractAddress);
        gasMode = GAS.getGasMode(contractAddress);
        governor = governorMap[contractAddress];
    }
}

contract GasMock {
    mapping(address => GasMode) internal _gasMode;

    function setGasMode(address contractAddress, GasMode gasMode) public {
        _gasMode[contractAddress] = gasMode;
    }

    function getGasMode(address contractAddress) public view returns (GasMode) {
        return _gasMode[contractAddress];
    }
}

contract YieldMock {
    mapping(address => YieldMode) internal _yieldMode;

    function configure(address contractAddress, YieldMode yieldMode) public {
        _yieldMode[contractAddress] = yieldMode;
    }

    function getYieldMode(address contractAddress) public view returns (YieldMode) {
        return _yieldMode[contractAddress];
    }
}
