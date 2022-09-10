// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface IStakingNFT {
    function firstTransfer(uint256 tokenId) external view returns (uint256);

    function lastTransfer(uint256 tokenId) external view returns (uint256);

    function getUserTokens(address user) external view returns (uint256[] memory);

    function getTokenIds() external view returns (uint256[] memory);
}

contract StakingFT is ERC20, Ownable {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    address private nft;
    uint256 private daily;
    uint256 private totalSupplyAdjustment;
    mapping(address => uint256) adjustment;

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function setNFT(address _address) external onlyOwner {
        nft = _address;
    }

    function setDaily(uint256 _amount) external onlyOwner {
        daily = _amount;
    }

    constructor(
        string memory name,
        string memory symbol,
        address _address,
        uint256 _amount
    ) ERC20(name, symbol) {
        nft = _address;
        daily = _amount;
    }

    function totalSupply() public view virtual override returns (uint256) {
        uint256 alpha = 0;
        uint256[] memory tokenIds = IStakingNFT(nft).getTokenIds();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 duration = (block.timestamp - IStakingNFT(nft).firstTransfer(tokenIds[i])) /
                (1 days);
            alpha += duration * daily;
        }
        return _totalSupply + alpha - totalSupplyAdjustment;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        uint256 alpha = 0;
        uint256[] memory tokens = IStakingNFT(nft).getUserTokens(account);
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 lastTransfer = IStakingNFT(nft).lastTransfer(tokens[i]);
            uint256 duration = (block.timestamp - lastTransfer) / (1 days);
            alpha += duration * daily;
        }
        return _balances[account] + alpha - adjustment[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), 'ERC20: transfer from the zero address');
        require(to != address(0), 'ERC20: transfer to the zero address');

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        require(fromBalance >= amount, 'ERC20: transfer amount exceeds balance');
        unchecked {
            if (_balances[from] <= amount) {
                adjustment[from] += amount - _balances[from];
                _balances[from] = 0;
            } else {
                _balances[from] -= amount;
            }
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), 'ERC20: mint to the zero address');

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), 'ERC20: burn from the zero address');

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
        unchecked {
            if (_balances[account] <= amount) {
                adjustment[account] += amount - _balances[account];
                _balances[account] = 0;
            } else {
                _balances[account] -= amount;
            }
            if (_totalSupply <= amount) {
                totalSupplyAdjustment = amount - _totalSupply;
                _totalSupply = 0;
            } else {
                _totalSupply -= amount;
            }
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
}

contract StakingNFT is ERC721, Ownable {
    mapping(uint256 => uint256) public firstTransfer;
    mapping(uint256 => uint256) public lastTransfer;
    mapping(address => uint256[]) private userTokens;
    uint256[] private tokenIds;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /*
    TODO: If burn is enabled, the tokenIds array must be adjusted at burn time
    */

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
        firstTransfer[tokenId] = block.timestamp;
        tokenIds.push(tokenId);
    }

    function getUserTokens(address user) external view returns (uint256[] memory) {
        return userTokens[user];
    }

    function getTokenIds() external view returns (uint256[] memory) {
        return tokenIds;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        for (uint256 i = 0; i < userTokens[from].length; i++) {
            if (userTokens[from][i] == tokenId) {
                if (i != userTokens[from].length - 1)
                    userTokens[from][i] = userTokens[from][userTokens[from].length - 1];
                userTokens[from].pop();
                break;
            }
        }

        userTokens[to].push(tokenId);
        lastTransfer[tokenId] = block.timestamp;
    }
}
