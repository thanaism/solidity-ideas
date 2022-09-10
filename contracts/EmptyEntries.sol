//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EmptyEntries {
    mapping(string => bool) map;

    constructor() {
        map['foo'] = true;
        // Delete a NON-existent key from the mapping
        delete map['bar'];
    }

    function getFoo() external view returns (bool) {
        // return EXISTENT key from the mapping
        return map['foo'];
    }

    function getBar() external view returns (bool) {
        // return a NON-existent key from the mapping
        return map['bar'];
    }
}
