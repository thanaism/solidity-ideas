// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract HighOrderFunc {
    function hof(function(uint256) internal pure returns (bool) _handler, uint256 _input)
        internal
        pure
        returns (bool)
    {
        return _handler(_input);
    }

    function handler(uint256 num) internal pure returns (bool) {
        return num > 100;
    }

    function callHOF(uint256 n) external pure returns (bool) {
        return hof(handler, n);
    }
}
