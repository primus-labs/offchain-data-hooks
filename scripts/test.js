const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();
  
    console.log(
    "Deploying contracts with the account:",
    deployer.address
    );
  
    const HOOK_SWAP_FEE_FLAG = 0x400000;
    const HOOK_WITHDRAW_FEE_FLAG = 0x200000;
    const poolKey = {
        currency0: '0x855633649b91F9A6146aeD9CcC18cd617c8e3C3A',
        currency1: '0xeccef7ccA92edF8a42B314273D96ad75fE485a8a',
        fee: HOOK_SWAP_FEE_FLAG | HOOK_WITHDRAW_FEE_FLAG | 3000,
        tickSpacing: 60,
        hooks: '0x288e0a983aB55bBdC8E8BAb9F68133670edf69c4',
    };

    const routerCallerAddress="0x63cA492E014Df0EB682DDFd32B388c06d1086354";
    const routerCallerContract = await ethers.getContractAt("UniswapV4Caller", routerCallerAddress);
    const res = await routerCallerContract.swap(poolKey, deployer.address, deployer.address, poolKey.currency0, 1e9);
    console.log('res=', res);
  }
  
  main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });