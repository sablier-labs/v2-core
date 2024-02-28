// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC20Rebasing, YieldMode } from "../../../src/interfaces/blast/IERC20Rebasing.sol";

/// @dev The following mock contract is inspired from Blast repository
/// https://github.com/blast-io/blast/blob/master/blast-optimism/packages/contracts-bedrock/src/L2/ERC20Rebasing.sol
/// https://github.com/blast-io/blast/blob/master/blast-optimism/packages/contracts-bedrock/src/L2/Shares.sol
/// https://github.com/blast-io/blast/blob/master/blast-optimism/packages/contracts-bedrock/src/L2/USDB.sol
contract ERC20RebasingMock is ERC20("ERC20Rebasing Mock", "REB-MOCK"), IERC20Rebasing {
    mapping(address => uint256) private _claimable;
    mapping(address => YieldMode) private _yieldMode;

    function addValue(uint256 value) external { }

    function bridge() external view returns (address) { }

    function getClaimableAmount(address account) public view override returns (uint256 amount) {
        require(getConfiguration(account) == YieldMode.CLAIMABLE, "ERC20RebasingMock: not claimable account");

        return _claimable[account];
    }

    function getConfiguration(address account) public view override returns (YieldMode) {
        return _yieldMode[account];
    }

    function claim(address recipient, uint256 amount) public override returns (uint256 claimed) {
        require(recipient != address(0), "ERC20RebasingMock: claim to the zero address");
        require(getConfiguration(msg.sender) == YieldMode.CLAIMABLE, "ERC20RebasingMock: not claimable account");
        require(_claimable[msg.sender] >= amount, "ERC20RebasingMock: insufficient balance");

        _claimable[msg.sender] -= amount;
        _mint(recipient, amount);

        return amount;
    }

    function configure(YieldMode yieldMode) public override returns (uint256) {
        _yieldMode[msg.sender] = yieldMode;
        return balanceOf(msg.sender);
    }

    function mint(address _to, uint256 _amount) external { }

    function price() external view returns (uint256) { }

    function REPORTER() public view returns (address) { }

    // Test helper function
    function setClaimableAmount(address account, uint256 amount) public {
        _claimable[account] = amount;
    }

    function symbol() public view override returns (string memory) { }
}
