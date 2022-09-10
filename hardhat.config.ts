import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'solidity-coverage';

// eslint-disable-next-line node/no-missing-require
require('./scripts/tasks');

const config: HardhatUserConfig = {
  solidity: '0.8.4',
};

export default config;
