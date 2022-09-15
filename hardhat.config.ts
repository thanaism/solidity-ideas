import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'solidity-coverage';
import 'hardhat-gas-reporter';

// eslint-disable-next-line node/no-missing-require
require('./scripts/tasks');

const config: HardhatUserConfig = {
  solidity: '0.8.4',
  gasReporter: {
    coinmarketcap: process.env.COIN_MARKET_CAP,
    currency: 'JPY',
    // token: 'MATIC',
    // gasPriceApi: 'https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice',
    token: 'ETH',
    gasPriceApi: 'https://api.etherscan.io/api?module=proxy&action=eth_gasPrice',
  },
};

export default config;
