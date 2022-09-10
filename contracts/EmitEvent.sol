// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EventEmitter {
    event Hello(uint256 indexed indexedTimestamp, uint256 timestamp);

    function hello() public {
        emit Hello(block.timestamp, block.timestamp);
    }
}
