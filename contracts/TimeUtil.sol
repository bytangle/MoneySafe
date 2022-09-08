// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

/**
 * @title Time Util Library
 * @author Edicha Joshua <mredichaj@gmail.com>
 * @dev used with type uint256 to encapsulate conversions
 *
 */
library TimeUtil {

    /**
     * @dev convert a number which represents day(s) to milliseconds
     * @param _self the number to convert to millisecond
     */
    function toMilliSeconds(uint256 _self) internal pure returns (uint256) {
        return _self * 24 * 60 * 60 * 1000;
    }
}