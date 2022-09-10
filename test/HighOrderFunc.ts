import { expect } from 'chai';
import { ethers } from 'hardhat';

const contractName = 'HighOrderFunc';

describe(contractName, () => {
  it('高階関数を呼び出す', async () => {
    const BN = ethers.BigNumber.from;
    const contract = await (await ethers.getContractFactory(contractName)).deploy();
    await contract.deployed();

    expect(await contract.callHOF(BN(1))).to.equal(false);
    expect(await contract.callHOF(BN(2000))).to.equal(true);
  });
});
