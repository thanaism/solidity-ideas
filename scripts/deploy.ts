import { ethers } from 'hardhat';

const main = async () => {
  const signers = await ethers.getSigners();
  signers.forEach((signer) => console.log(signer.address));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
