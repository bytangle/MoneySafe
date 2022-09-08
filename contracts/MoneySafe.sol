// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

import "./IMoneySafe.sol";
import "./TimeUtil.sol";

/**
 * @title MoneySafe
 * @author Edicha Joshua <mredichaj@gmail.com>
 * @notice Save your funds for a period of time and be able to withdraw after the period has elapsed. Fully autonomous
 */

contract MoneySafe is IMoneySafe {
    address private _developer; /// @notice developer's address

    /// @notice accounts
    mapping(address => Account) private _accounts;

    /// @notice deposit history
    mapping(address => DepositDetail[]) private _depositHistory;

    using TimeUtil for uint256; // use TimeUtil to make time calculations

    /**
     * @dev checks if msg.value is 0
     */
    modifier notZeroAmount {
        if(msg.value < 1) revert ZeroException("msg.value cannot be zero");
        _;
    }

    /// @dev ensure `_value` isn't greater than max allowable value for uint256
    modifier valueAllowed(uint256 _value) {
        _ensureValueDoesNotOverflow(_value);
        _;
    }

    /// @dev ensure that msg.sender cannot update his account by trying to re-register
    modifier notYetRegistered {
        Account memory acct = _accounts[msg.sender]; // retrieve account details

        // ensure msg.sender doesn't own an account yet
        if(acct.balance > 0) revert AlreadyRegistered(acct.timeRegistered);

        _; // continue execution
    }

    modifier alreadyRegistered {
        Account memory acct = _accounts[msg.sender]; // retrieve account details

        // ensure msg.sender doesn't own an account yet
        if(acct.balance == 0) revert NotYetRegistered();

        _; // continue execution
    }

    constructor() {
        _developer = msg.sender;
    }

    /**
     * @notice register an account
     * @param _days duration in days
     */
    function register(uint256 _days) public payable notZeroAmount valueAllowed(_days) {

        uint256 t = block.timestamp;

        // add account to _accounts
        _accounts[msg.sender] = Account({
            balance: msg.value,
            duration: _days,
            timeRegistered: t
        });

        // save first deposit to deposits history
        _depositHistory[msg.sender].push(
            DepositDetail({
                amount: msg.value,
                timeDeposited: t
            })
        );

        emit AccountRegistration(msg.sender); // event event
    }

    /**
     * @notice deposit amount into account
     * @dev to use this function, you must be registered and msg.value must not be zero
     */
    function save() public payable alreadyRegistered notZeroAmount {

        _ensureValueDoesNotOverflow(_accounts[msg.sender].balance + msg.value); // overflow check

        _accounts[msg.sender].balance += msg.value; // update balance

        _depositHistory[msg.sender].push(DepositDetail({
            amount: msg.value,
            timeDeposited: block.timestamp
        })); // save deposit to deposit history

        FundDeposit(msg.sender, msg.value); // emit event
    }

    /// @notice retrieve deposit history
    /// @return array of all individual deposit detail
    function getDepositsDetails() public view alreadyRegistered returns (DepositDetail[] memory) {
        return _depositHistory[msg.sender]; /// return deposit history for `msg.sender`
    }

    /// @notice get the time of registration
    /// @return the timestamp in milliseconds
    function timeRegistered() public view alreadyRegistered returns (uint256) {
        return _accounts[msg.sender].timeRegistered;
    }

    /**
     * @notice increase the duration
     * @param _days the number of days to be added
     */
    function increaseDuration(uint256 _days) public alreadyRegistered valueAllowed(_days) {

        _accounts[msg.sender].duration += _days; // increase
        
        emit DurationIncrease(_days, _accounts[msg.sender].duration); // emit event
    }

    /**
     * @notice get the time left before the account can withdraw
     * @return the time left. returns 0 if the time has elapsed else return remaining time in milliseconds
     */
    function timeLeft() public alreadyRegistered view returns (uint256) {
        Account memory acct = _accounts[msg.sender]; // get account
        uint256 actualDurationInMilliseconds = acct.timeRegistered + acct.duration.toMilliSeconds();

        if(block.timestamp > actualDurationInMilliseconds) {
            return 0; // meaning the time has elapsed
        } else {
            return actualDurationInMilliseconds - block.timestamp; // return remaining time
        }
    }

    /// @notice get account balance
    /// @return the current account balance
    function balance() public view returns (uint256) {
        return _accounts[msg.sender].balance; // return balance
    }

    /**
     * @notice withdraw saved funds if duration has elapsed
     * @param _amount amount to withdraw
     * Note: if account owner is withdrawing everything, the account details and the deposit history will be cleared as well to mark an account closure
     */
    function withdraw(uint256 _amount) public alreadyRegistered {
        
        Account memory acct = _accounts[msg.sender]; // get account
        uint256 timeLeft_ = timeLeft(); // get time left

        if(timeLeft_ > 0) {
            revert PrematureWithdrawal(acct.duration, timeLeft_); // there's still time left before the account owner can start withdrawing
        }

        if(acct.balance < _amount) revert InsufficientFunds({_balance: acct.balance, _amountRequested: _amount}); /// revert with error object

        if(_amount == acct.balance) {
            delete _accounts[msg.sender]; // reset everything if account owner is withdrawing everything
            delete _depositHistory[msg.sender]; // clear history
        } else {
            _accounts[msg.sender].balance -= _amount;
        }

        payable(msg.sender).transfer(_amount); // transfer to account owner address

        emit Withdraw(msg.sender, _amount); // emit event

    }
    
    /// @dev used to ensure that `_value` is not greater than the maximum allowable value for the type of uint256
    function _ensureValueDoesNotOverflow(uint256 _value) private {
        require(type(uint256).max > _value);
    }
}