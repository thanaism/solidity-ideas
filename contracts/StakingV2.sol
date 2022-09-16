// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface IStakingNFT {
    function firstTransfer(uint256 tokenId) external view returns (uint256);

    function lastTransfer(uint256 tokenId) external view returns (uint256);

    function getUserTokens(address user) external view returns (uint256[] memory);

    function getTokenIds() external view returns (uint256[] memory);
}

interface IStakingFT {
    function preserveStaking(address to) external;

    function mint(address to, uint256 amount) external;
}

contract StakableFT is ERC20, Ownable {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    address private nft;
    uint256 private daily;
    uint256 private totalSupplyAdjustment;
    mapping(address => uint256) adjustment;

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function preserveStaking(address account) external onlyOwner {
        require(account != address(0), 'ERC20: mint to the zero address');
        uint256 amount = _alpha(account);
        unchecked {
            _balances[account] += amount;
        }
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function setDaily(uint256 _amount) external onlyOwner {
        daily = _amount;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 _amount
    ) ERC20(name, symbol) {
        nft = msg.sender;
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
        uint256 alpha = _alpha(account);
        return _balances[account] + alpha - adjustment[account];
    }

    function _alpha(address account) internal view returns (uint256) {
        uint256 alpha = 0;
        uint256[] memory tokens = IStakingNFT(nft).getUserTokens(account);
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 lastTransfer = IStakingNFT(nft).lastTransfer(tokens[i]);
            uint256 duration = (block.timestamp - lastTransfer) / (1 days);
            alpha += duration * daily;
        }
        return alpha;
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

contract OriginalNFT is ERC721, Ownable {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }
}

contract StakableNFT is ERC721, Ownable {
    mapping(uint256 => uint256) public firstTransfer;
    mapping(uint256 => uint256) public lastTransfer;
    mapping(address => uint256[]) private userTokens;
    uint256[] private tokenIds;
    address public original;
    address public ft;

    constructor(
        string memory name,
        string memory symbol,
        address _original,
        string memory ftName,
        string memory ftSymbol,
        uint256 daily
    ) ERC721(name, symbol) {
        original = _original;
        ft = address(new StakableFT(ftName, ftSymbol, daily));
    }

    /*
    TODO: If burn is enabled, the tokenIds array must be adjusted at burn time
    */

    function _mint(address to, uint256 tokenId) internal override {
        super._mint(to, tokenId);
        firstTransfer[tokenId] = block.timestamp;
        tokenIds.push(tokenId);
    }

    function publicMint(uint256[] calldata _tokenIds) external {
        require(
            IERC721(original).balanceOf(msg.sender) > 0,
            'Must be a holder of original NFT collection'
        );
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (IERC721(original).ownerOf(_tokenIds[i]) == msg.sender && !_exists(_tokenIds[i])) {
                _mint(msg.sender, _tokenIds[i]);
            }
        }
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function mintFT(address to, uint256 amount) external onlyOwner {
        IStakingFT(ft).mint(to, amount);
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
        if (from != address(0)) IStakingFT(ft).preserveStaking(from);

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
