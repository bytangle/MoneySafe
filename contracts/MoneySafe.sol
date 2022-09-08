// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

import "./IMoneySafe.sol";

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

    /**
     * @dev checks if msg.value is 0
     * @param _msg descriptive message to used with the error
     */
    modifier notZero(string memory _msg) {
        if(msg.value < 1) revert ZeroException(_msg);
        _;
    }

    /// @dev ensure that msg.sender cannot update his account by trying to re-register
    modifier notYetRegistered {
        Account memory acct = _accounts[msg.sender]; // retrieve account details

        // ensure msg.sender doesn't own an account yet
        if(acct.balance > 0) revert AlreadyRegistered(acct.timeRegistered);

        _;
    }

    constructor() {
        _developer = msg.sender;
    }

    /**
     * @notice register an account
     * @param _days duration in days
     */
    function register(uint256 _days) public payable notZero("You can only register with an initial amount") {
        require(type(uint256).max > _days); // ensure _days isn't greater max allowable value for uint256

        uint256 t = block.timestamp;

        // add account to _accounts
        _accounts[msg.sender] = Account({
            owner: msg.sender,
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
    }
}