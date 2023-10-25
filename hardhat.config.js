require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
    },
    allowUnlimitedContractSize: true,
  },

  networks: {
    hardhat: {},
    anvil: {
      url: `http://localhost:8545`,
      accounts: [`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`]
    },
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
