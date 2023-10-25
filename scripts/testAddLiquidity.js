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
  const resadd = await routerCallerContract.addLiquidity(poolKey, deployer.address, -60, 60, "0x8ac7230489e80000");
  console.log('resadd=', resadd);
  const resadd1 = await routerCallerContract.addLiquidity(poolKey, deployer.address, -120, 120, "0x8ac7230489e80000");
  console.log('resadd1=', resadd1);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });