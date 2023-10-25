const { ethers } = require("hardhat")
const { getPoolKey } = require("./utils.js")
require('dotenv').config({ path: '.address' })
const {
  CALLER
} = process.env;

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  const poolKey = getPoolKey();
  const routerCallerContract = await ethers.getContractAt("UniswapV4Caller", CALLER);
  const res = await routerCallerContract.swap(poolKey, deployer.address, deployer.address, poolKey.currency0, 1e9);
  console.log('res=', res);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });