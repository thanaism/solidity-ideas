import { task } from 'hardhat/config';

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  accounts.forEach((account) => console.log(account.address));
});

task('balances', 'Prints the list of balances', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  // eslint-disable-next-line no-restricted-syntax
  for await (const account of accounts) console.log(await account.getBalance());
});
