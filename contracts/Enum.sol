// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

contract Enum {
    enum T {
        hoge,
        fuga,
        piyo
    }

    function hoge() public pure returns (T) {
        return T.hoge;
    }

    function fuga() public pure returns (T) {
        return T.fuga;
    }

    function piyo() public pure returns (T) {
        return T.piyo;
    }
}
