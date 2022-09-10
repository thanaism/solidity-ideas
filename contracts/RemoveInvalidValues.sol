// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract RemoveInvalidValues {
    uint256[] arr;

    constructor(uint256[] memory _arr) {
        arr = _arr;
    }

    function getArr() external view returns (uint256[] memory) {
        return arr;
    }

    function removeZeroValues() public returns (uint256[] memory) {
        for (uint256 i = 1; i <= arr.length; i++) {
            if (_isZero(arr[i - 1])) {
                if (!_isZero(arr[arr.length - 1])) {
                    arr[i - 1] = arr[arr.length - 1];
                } else {
                    i--;
                }
                arr.pop();
            }
        }
        return arr;
    }

    function _isZero(uint256 _value) internal pure returns (bool) {
        return _value == 0;
    }
}
