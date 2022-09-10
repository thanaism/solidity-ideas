import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('Enum', () => {
  it('Enumの各項目には0からの連番が割り振られている', async () => {
    const Contract = await ethers.getContractFactory('Enum');
    const contract = await Contract.deploy();
    await contract.deployed();

    const hoge = await contract.hoge();
    const fuga = await contract.fuga();
    const piyo = await contract.piyo();
    expect([hoge, fuga, piyo]).to.eql([0, 1, 2]);
  });
});
