import { expect } from 'chai';
import { ethers, network } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { Contract } from 'ethers';

describe('Staking', () => {
  const BN = ethers.BigNumber.from;
  const ETH = ethers.utils.parseEther;

  // eslint-disable-next-line one-var
  let admin: SignerWithAddress,
    userA: SignerWithAddress,
    userB: SignerWithAddress,
    nft: Contract,
    ft: Contract;
  it('NFTのデプロイ', async () => {
    [admin, userA, userB] = await ethers.getSigners();
    const NFT = await ethers.getContractFactory('StakingNFT', admin);
    nft = await (await NFT.deploy('NFT', 'NFT')).deployed();
  });

  it('FTのデプロイ', async () => {
    const FT = await ethers.getContractFactory('StakingFT', admin);
    ft = await (await FT.deploy('FT', 'FT', nft.address, ETH('1'))).deployed();
  });

  it('AにNFTをミント', async () => {
    const tokenId = BN(1);
    const mintNFT = await nft.mint(userA.address, tokenId);
    await mintNFT.wait();
  });

  it('AにFTをミント', async () => {
    const amount = ETH('10');
    const mintFT = await ft.mint(userA.address, amount);
    await mintFT.wait();
  });

  it('100日間ステーキングし残高が増える', async () => {
    // 100 days later
    const secInADay = 86400;
    network.provider.send('evm_increaseTime', [secInADay * 100]);
    network.provider.send('evm_mine');

    const balance = await ft.balanceOf(userA.address);
    expect(balance).to.equal(ETH('110'));
  });

  it('AからBに30ETHをTransferする', async () => {
    const transfer = await ft.connect(userA).transfer(userB.address, ETH('30'));
    await transfer.wait();

    const balanceOfA = await ft.balanceOf(userA.address);
    const balanceOfB = await ft.balanceOf(userB.address);
    expect(balanceOfA).to.equal(ETH('80'));
    expect(balanceOfB).to.equal(ETH('30'));
  });

  it('BにNFTをミントする', async () => {
    const tokenId = BN(2);
    const mintNFT = await nft.mint(userB.address, tokenId);
    await mintNFT.wait();
  });

  it('AとBが40日間ステーキングする', async () => {
    // 40 days later
    const secInADay = 86400;
    network.provider.send('evm_increaseTime', [secInADay * 40]);
    network.provider.send('evm_mine');

    const balanceOfA = await ft.balanceOf(userA.address);
    const balanceOfB = await ft.balanceOf(userB.address);
    expect(balanceOfA).to.equal(ETH('120'));
    expect(balanceOfB).to.equal(ETH('70'));
  });

  it('FTのtotalSupplyが正しく返るか', async () => {
    const totalSupply = await ft.totalSupply();
    expect(totalSupply).to.equal(ETH('190'));
  });

  it('Aから115ETHをburnする', async () => {
    const burn = await ft.connect(userA).burn(ETH('115'));
    await burn.wait();
    const balanceOfA = await ft.balanceOf(userA.address);
    expect(balanceOfA).to.equal(ETH('5'));
    const totalSupply = await ft.totalSupply();
    expect(totalSupply).to.equal(ETH('75'));
  });
});
