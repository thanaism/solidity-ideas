import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';

describe('EmptyEntries', () => {
  let contract: Contract;
  it('存在しないキーをmappingから削除してもエラーにならない', async () => {
    contract = await (await ethers.getContractFactory('EmptyEntries')).deploy();
    await contract.deployed();
  });

  it('存在しないエントリの初期値はfalseとなる', async () => {
    const getFoo = await contract.getFoo();
    const getBar = await contract.getBar();
    expect(getFoo).to.equal(true);
    expect(getBar).to.equal(false);
  });
});
