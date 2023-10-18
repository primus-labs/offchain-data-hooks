require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
        url: `https://sepolia.infura.io/v3/b6bf7d3508c941499b10025c0776eaf8`,
        accounts: [`${process.env.PRIVATE_KEY}`]
    },
    arbitrumone: {
      url: `https://arb1.arbitrum.io/rpc`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    polygon: {
      url: `https://polygon-rpc.com/`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  },
  paths: {
    sources: "./src",
  },
};
