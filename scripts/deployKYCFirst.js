const { ethers } = require("hardhat")
require('dotenv').config({ path: '.address' })
const { POOL_MANAGER } = process.env;

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );
    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());


    // 0. deploy MockToken
    const MockToken = await ethers.getContractFactory("MockToken");
    const token0contract = await MockToken.deploy("PADO MOCK TOKEN 0", "PMT1", "0x845951614014880000000");
    const token1contract = await MockToken.deploy("PADO MOCK TOKEN 1", "PMT2", "0x845951614014880000000");
    var token0address = token0contract.target;
    var token1address = token1contract.target;
    if (token0contract.target > token1contract.target) {
        token0address = token1contract.target;
        token1address = token0contract.target;
    }
    console.log(`TOKEN0=${token0address}`);
    console.log(`TOKEN1=${token1address}`);


    // 1. deploy UniswapV4RouterLibrary
    const UniswapV4RouterLibrary = await ethers.getContractFactory("UniswapV4RouterLibrary");
    const contractUniswapV4RouterLibrary = await UniswapV4RouterLibrary.deploy();
    const libraryAddress = contractUniswapV4RouterLibrary.target;
    // console.log("Contract UniswapV4RouterLibrary  deployed at:", libraryAddress);


    // 2. deploy UniswapV4Router
    const UniswapV4Router = await ethers.getContractFactory("UniswapV4Router", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    const routerContract = await UniswapV4Router.deploy(POOL_MANAGER);
    const routerAddress = routerContract.target;
    // console.log("Contract UniswapV4Router deployed at:", routerAddress);
    console.log(`ROUTER=${routerAddress}`);

    // 3. deploy UniswapV4Caller
    const UniswapV4Caller = await ethers.getContractFactory("UniswapV4Caller", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    const contract = await UniswapV4Caller.deploy(routerAddress, POOL_MANAGER);
    const callerAddress = contract.target;
    // console.log("Contract UniswapV4Caller deployed at:", callerAddress);
    console.log(`CALLER=${callerAddress}`);

    // 4. token approve
    const token0approvecontract = await ethers.getContractAt("MockToken", token0address);
    const res0 = await token0approvecontract.approve(routerAddress, '0x845951614014880000000');
    // console.log("token0 approve res0=", res0);

    const token1approvecontract = await ethers.getContractAt("MockToken", token1address);
    const res1 = await token1approvecontract.approve(routerAddress, '0x845951614014880000000');
    // console.log("token1 approve res1=", res1);

    // 5. kyc hook factory
    const KYCFactory = await ethers.getContractFactory("KYCFactory");
    const contractKYCFactory = await KYCFactory.deploy();
    const contractKYCFactoryAddress = contractKYCFactory.target;
    // console.log("Contract KYCFactory deployed at:", contractKYCFactoryAddress);
    console.log(`KYC_FACTORY=${contractKYCFactoryAddress}`);

    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });