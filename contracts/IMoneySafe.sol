// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

/**
 * @title MoneySafe interface
 * @author Edicha Joshua <mredichaj@gmail.com>
 */
interface IMoneySafe {
    /**
     * @dev emit when fund is saved by an account
     * @param _addr address of the account
     * @param _amt amount saved
     */
    event FundDeposit(address indexed _addr, uint256 _amt);

    /**
     * @dev emit when fund is withdrawn
     * @param _addr address of the account
     * @param _amt amount withdrawn
     */
    event Withdraw(address indexed _addr, uint256 _amt);

    /**
     * @dev emit when new account is registered
     * @param _addr address of the account
     */
    event AccountRegistration(address indexed _addr);

    /**
     * @dev emit when duration is increased
     * @param _increase the number of days added
     * @param _total new duration
     */
    event DurationIncrease(uint256 _increase, uint256 _total);

    /**
     * @dev used with revert in the case of unauthorized activity
     * @param _addr address that initiated the action
     * @param _msg message describing the attempted action
     */
    error Unauthorized(address _addr, string  _msg);

    /**
     * @dev used with revert when zero is provided for amounts and days
     * @param _msg friendly message
     */
    error ZeroException(string _msg);

    /**
     * @dev used with revert when an owner wants to withdraw before the duration elapse
     * @param _duration the period of saving
     * @param _timeLeft the time left before it elapse
     * @param _msg friendly message
     */
    error PrematureWithdrawal(uint256 _duration, uint256 _timeLeft, string _msg);

    /**
     * @dev used with revert when account already exists
     * @param _timeRegistered the time account was registered
     */
    error AlreadyRegistered(uint256 _timeRegistered);

    /// @dev used with revert when trying to save without first registering
    error NotYetRegistered();

    /**
     * @dev register self and deposit first amount
     * @param _days duration in days
     * Note: should emit {AccountRegistration} event
     */
    function register(uint8 _days) external payable;

    /// @dev save new amount
    /// Note should save deposit details and emit {FundDeposit} event
    function save() external payable;

    /**
     * @dev retrive deposit details
     * @return array of the deposit details
     */
    function getDepositsDetails() external view returns (DepositDetail[] memory);

    /**
     * @dev get the time left before the owner can start withdrawing saved funds
     * @return the time left in milliseconds
     */
    function timeLeft() external view returns (uint256);

    /**
     * @dev get total funds saved
     * @return total funds saved
     */
    function balance() external view returns (uint256);

    /**
     * @dev get the registration detail
     * @return the time registered in milliseconds
     */
    function timeRegistered() external view returns (uint256);

    /**
     * @dev increase duration
     * @param _days total number of days to be added
     * Note: revert if 0 days provided
     */
    function increaseDuration(uint256 _days) external;

    /**
     * @dev withdraw saved funds
     * @dev can only work if the duration has elapsed else revert
     * @param _amount amount to withdraw
     * Note: emit Withdraw event on successful withdrawal
     */
    function withdraw(uint256 _amount) external;

    /// @dev this struct holds details of the savings [the owner's safe]
    struct Account {
        address owner; // address of account owner
        uint256 balance; // in the MoneySafe token
        uint256 duration; // duration in days
        uint256 timeRegistered; // timestamp in milliseconds
        //DepositDetail[] depositDetails;
    }

    /**
     * @dev this struct holds the details of inidividual deposits
     */
    struct DepositDetail {
        uint256 timeDeposited; // timestamp in milliseconds
        uint256 amount; // amount in MoneySafe token
    }
}