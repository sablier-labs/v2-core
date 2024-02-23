// SPDX-License-Identifier: BSL 1.1 - Copyright 2024 MetaLayer Labs Ltd.
pragma solidity >=0.8.19;

import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { IERC20Rebasing } from "src/interfaces/blast/IERC20Rebasing.sol";
import { YieldMode } from "src/interfaces/blast/IYield.sol";

import { Errors } from "./Errors.sol";
import { SharesBase } from "./Shares.sol";

/// @dev Credits to https://github.com/blast-io/blast/tree/master/blast-optimism
contract ERC20Rebasing is ERC20, IERC20Rebasing, PRBTest, SharesBase, StdCheats {
    /// @notice Address of the BlastBridge on this network.
    address public immutable BRIDGE;

    /// @notice Mapping that stores the number of shares for each account.
    mapping(address => uint256) private _shares;

    /// @notice Total number of shares distributed.
    uint256 internal _totalShares;

    /// @notice Mapping that stores the number of remainder tokens for each account.
    mapping(address => uint256) private _remainders;

    /// @notice Mapping that stores the number of fixed tokens for each account.
    mapping(address => uint256) private _fixed;

    /// @notice Total number of non-rebasing tokens.
    uint256 internal _totalVoidAndRemainders;

    /// @notice Mapping that stores the configured yield mode for each account.
    mapping(address account => YieldMode) public yieldMode;

    /// @notice A modifier that only allows the bridge to call
    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "ERC20Rebasing: only bridge");
        _;
    }

    constructor(address bridge) ERC20("Rebasing ERC20", "BUSDToken") {
        BRIDGE = bridge;
    }

    /// @notice Get the total number of shares.
    /// @return Total number of shares.
    function count() public view override returns (uint256) {
        return _totalShares;
    }

    /// @notice --- ERC20 Interface ---

    function balanceOf(address account) public view override returns (uint256 value) {
        YieldMode yieldMode_ = yieldMode[account];
        if (yieldMode_ == YieldMode.AUTOMATIC) {
            value = _computeShareValue(_shares[account], _remainders[account]);
        } else {
            value = _fixed[account];
        }
    }

    function totalSupply() public view override returns (uint256) {
        return price * _totalShares + _totalVoidAndRemainders;
    }

    /// @notice Allows the StandardBridge on this network to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function mint(address _to, uint256 _amount) external onlyBridge {
        _deposit(_to, _amount);
    }

    /// @notice Moves `amount` of tokens from `from` to `to`.
    /// @param from   Address of the sender.
    /// @param to     Address of the recipient.
    /// @param amount Amount of tokens to send.
    function _transfer(address from, address to, uint256 amount) internal override {
        _withdraw(from, amount);
        _deposit(to, amount);

        emit Transfer(from, to, amount);
    }

    /// @notice --- Blast Interface ---

    /// @notice Query an CLAIMABLE account's claimable yield.
    /// @param account Address to query the claimable amount.
    /// @return amount Claimable amount.
    function getClaimableAmount(address account) public view returns (uint256 amount) {
        if (yieldMode[account] != YieldMode.CLAIMABLE) {
            revert Errors.NotClaimableAccount();
        }
        uint256 shareValue = _computeShareValue(_shares[account], _remainders[account]);
        return shareValue - _fixed[account];
    }

    /// @notice Query an account's configured yield mode.
    /// @param account Address to query the configuration.
    /// @return Configured yield mode.
    function getConfiguration(address account) public view returns (YieldMode) {
        return yieldMode[account];
    }

    /// @notice Claim yield from a CLAIMABLE account and send to
    ///         a recipient.
    /// @param recipient Address to receive the claimed balance.
    /// @param amount    Amount to claim.
    /// @return Amount claimed.
    function claim(address recipient, uint256 amount) public returns (uint256) {
        address account = msg.sender;
        if (getConfiguration(account) != YieldMode.CLAIMABLE) {
            revert Errors.NotClaimableAccount();
        }

        uint256 shareValue = _computeShareValue(_shares[account], _remainders[account]);

        uint256 claimableAmount = shareValue - _fixed[account];

        if (amount > claimableAmount) {
            revert Errors.InsufficientBalance();
        }

        (uint256 newShares, uint256 newRemainder) = _computeSharesAndRemainder(shareValue - amount);
        _updateBalance(account, newShares, newRemainder, _fixed[account]);
        _deposit(recipient, amount);

        return amount;
    }

    /// @notice Change the yield mode of the caller and update the
    ///         balance to reflect the configuration.
    /// @param yieldMode_ Yield mode to configure
    /// @return Current user balance
    function configure(YieldMode yieldMode_) public returns (uint256) {
        address account = msg.sender;
        YieldMode prevYieldMode = getConfiguration(account);

        uint256 balance;
        if (prevYieldMode == YieldMode.CLAIMABLE) {
            balance = _computeShareValue(_shares[account], _remainders[account]);
        } else {
            balance = balanceOf(account);
        }
        yieldMode[account] = yieldMode_;

        uint256 prevFixed = _fixed[account];
        _setBalance(account, balance, true);

        if (prevYieldMode == YieldMode.VOID) {
            _totalVoidAndRemainders -= prevFixed;
        }

        if (yieldMode_ == YieldMode.VOID) {
            _totalVoidAndRemainders += balance;
        }

        return balanceOf(msg.sender);
    }

    /// @notice Convert nominal value to number of shares with remainder.
    /// @param value Amount to convert to shares (wad).
    /// @return shares Number of shares (wad), remainder Remainder (wad).
    function _computeSharesAndRemainder(uint256 value) internal view returns (uint256 shares, uint256 remainder) {
        if (price == 0) {
            remainder = value;
        } else {
            shares = value / price;
            remainder = value % price;
        }
    }

    /// @notice Compute nominal value from number of shares.
    /// @param shares     Number of shares (wad).
    /// @param remainders Amount of remainder (wad).
    /// @return value (wad).
    function _computeShareValue(uint256 shares, uint256 remainders) internal view returns (uint256) {
        return price * shares + remainders;
    }

    /// @notice Deposit to an account.
    /// @param account Address of the account to deposit to.
    /// @param amount  Amount to deposit to the account.
    function _deposit(address account, uint256 amount) internal {
        uint256 balanceAfter = balanceOf(account) + amount;
        _setBalance(account, balanceAfter, false);

        /// If the user is configured as VOID, then the amount
        /// is added to the total voided funds.
        YieldMode yieldMode_ = getConfiguration(account);
        if (yieldMode_ == YieldMode.VOID) {
            _totalVoidAndRemainders += amount;
        }
    }

    /// @notice Sets the balance of an account according to its yield mode
    ///         configuration.
    /// @param account           Address of the account to set the balance of.
    /// @param amount            Balance to set for the account.
    /// @param resetClaimable    If the account is CLAIMABLE, true if the share
    ///                          balance should be set to the amount. Should only be true when
    ///                          configuring the account.
    function _setBalance(address account, uint256 amount, bool resetClaimable) internal {
        uint256 newShares;
        uint256 newRemainder;
        uint256 newFixed;
        YieldMode yieldMode_ = getConfiguration(account);
        if (yieldMode_ == YieldMode.AUTOMATIC) {
            (newShares, newRemainder) = _computeSharesAndRemainder(amount);
        } else if (yieldMode_ == YieldMode.VOID) {
            newFixed = amount;
        } else if (yieldMode_ == YieldMode.CLAIMABLE) {
            newFixed = amount;
            uint256 shareValue = amount;
            if (!resetClaimable) {
                /// In order to not reset the claimable balance, we have to compute
                /// the user's current share balance and add or subtract the change in
                /// fixed balance before computing the new shares balance parameters.
                shareValue = _computeShareValue(_shares[account], _remainders[account]);
                shareValue = shareValue + amount - _fixed[account];
            }
            (newShares, newRemainder) = _computeSharesAndRemainder(shareValue);
        }

        _updateBalance(account, newShares, newRemainder, newFixed);
    }

    /// @notice Update the balance parameters of an account and appropriately refresh the global sums
    ///         to reflect the change of allocation.
    /// @param account      Address of account to update.
    /// @param newShares    New shares value for account.
    /// @param newRemainder New remainder value for account.
    /// @param newFixed     New fixed value for account.
    function _updateBalance(address account, uint256 newShares, uint256 newRemainder, uint256 newFixed) internal {
        _totalShares = _totalShares + newShares - _shares[account];
        _totalVoidAndRemainders = _totalVoidAndRemainders + newRemainder - _remainders[account];
        _shares[account] = newShares;
        _remainders[account] = newRemainder;
        _fixed[account] = newFixed;
    }

    /// @notice Withdraw from an account.
    /// @param account Address of the account to withdraw from.
    /// @param amount  Amount to withdraw to the account.
    function _withdraw(address account, uint256 amount) internal {
        uint256 balance = balanceOf(account);
        if (amount > balance) {
            revert Errors.InsufficientBalance();
        }

        unchecked {
            _setBalance(account, balance - amount, false);
        }

        /// If the user is configured as VOID, then the amount
        /// is deducted from the total voided funds.
        YieldMode yieldMode_ = getConfiguration(account);
        if (yieldMode_ == YieldMode.VOID) {
            _totalVoidAndRemainders -= amount;
        }
    }
}
