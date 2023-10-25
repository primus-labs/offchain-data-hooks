const { ethers } = require("hardhat")
const { getPoolKey } = require("./utils.js")
require('dotenv').config({ path: '.address' })
const {
  POOL_MANAGER,
} = process.env;

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  const SQRT_RATIO_1_TO_1 = "0x1000000000000000000000000";
  const poolKey = getPoolKey();
  const poolManagerContract = await ethers.getContractAt("IPoolManager", POOL_MANAGER);
  const res = await poolManagerContract.initialize(poolKey, SQRT_RATIO_1_TO_1, "0x");
  console.log("PoolManager initialize res=", res);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });