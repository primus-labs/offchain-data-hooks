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
        currency0: '0x32C238b8b5B92a222EBB498A461571059Daa32c6',
        currency1: '0x700c009F8C27E3030d3d8Bb9a5D99eBDAEEE465C',
        fee: HOOK_SWAP_FEE_FLAG | HOOK_WITHDRAW_FEE_FLAG | 3000,
        tickSpacing: 60,
        hooks: '0x28D51025C34cc1023078D5fE16Dd8d6Da81A7BBC',
    };

    const routerCallerAddress="0x287e5d318353DF210D97B0Ea929B75Abc213600F";
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