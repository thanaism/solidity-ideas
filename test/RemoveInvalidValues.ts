import { expect } from 'chai';
import { ethers } from 'hardhat';

const contractName = 'RemoveInvalidValues';

describe(contractName, () => {
  it('渡した配列からゼロが削除される', async () => {
    const BN = ethers.BigNumber.from;
    const arr = [1, 2, 0, 3, 4, 0, 5, 6, 0, 7, 8, 0, 9, 0].map(BN);
    const contract = await (await ethers.getContractFactory(contractName)).deploy(arr);
    await contract.deployed();
    await (await contract.removeZeroValues()).wait();
    const result = await (await contract.getArr()).map(BN);
    expect(result).to.eql([1, 2, 9, 3, 4, 8, 5, 6, 7].map(BN));
  });

  it('すべてがゼロの配列を渡しても正しく処理される', async () => {
    const BN = ethers.BigNumber.from;
    const arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].map(BN);
    const contract = await (await ethers.getContractFactory(contractName)).deploy(arr);
    await contract.deployed();
    await (await contract.removeZeroValues()).wait();
    const result = await (await contract.getArr()).map(BN);
    expect(result).to.eql([]);
  });

  it('ゼロのない配列を渡しても正しく処理される', async () => {
    const BN = ethers.BigNumber.from;
    const arr = [1, 2, 3, 4, 5, 6, 7, 8].map(BN);
    const contract = await (await ethers.getContractFactory(contractName)).deploy(arr);
    await contract.deployed();
    await (await contract.removeZeroValues()).wait();
    const result = await (await contract.getArr()).map(BN);
    expect(result).to.eql(arr);
  });
});
