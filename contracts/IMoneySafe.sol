// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IMoneySafe {
    /**
     * @dev emit when fund is saved by an account
     * @param _addr address of the account
     * @param _amt amount saved
     */
    event FundSaved(address indexed _addr, uint256 _amt);
}