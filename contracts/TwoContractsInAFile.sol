// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC777/ERC777.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract First is ERC777, Ownable {
    constructor(uint256 initialSupply, address[] memory defaultOperators)
        ERC777('First', 'First', defaultOperators)
    {
        _mint(msg.sender, initialSupply, '', '');
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount, '', '');
    }
}

abstract contract IFirst {
    function balanceOf(address _address) public virtual returns (uint256);
}

contract Second {
    address private _first;
    event Called(string indexed msg);

    constructor(address _address) {
        _first = _address;
    }

    function call(address account) external {
        require(IFirst(_first).balanceOf(account) >= 100);
        emit Called('success');
    }
}
