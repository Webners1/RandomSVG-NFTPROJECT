require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-deploy');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
require('dotenv').config()
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL;
const MNEMONICS = process.env.MNEMONICS;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork:'hardhat',
  networks:{
    hardhat:{},
     rinkeby:{
       url: RINKEBY_RPC_URL || 'https://eth-rinkeby.alchemyapi.io/v2/taLEpPnjCmIER87tLROTW6GNlvIheNen',
       chainId: 4,
       accounts:{
         mnemonic: MNEMONICS ||'fee shrimp twenty rice middle pelican stool ordinary water labor smile group'
      },
      saveDeployments:true
    }
  },
  etherscan:{
    apiKey: ETHERSCAN_API_KEY || '1TXWV961WH4UZHHYWIIPPVYE775IWM63NH'
  },
  solidity: {
  compilers: [
    {
      version: "0.8.0"
    },
    {
      version: "0.7.0"
    },
    {
      version: "0.6.6"
    },
    {
      version: "0.4.24"
    }
  ]}
};
