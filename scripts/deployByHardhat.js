const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );
    const  poolManagerAddress = '0x64255ed21366DB43d89736EE48928b890A84E2Cb'
    //1.deploy UniswapV4RouterLibrary
    const UniswapV4RouterLibrary = await ethers.getContractFactory("UniswapV4RouterLibrary");
    const contractUniswapV4RouterLibrary = await UniswapV4RouterLibrary.deploy();
    console.log(contractUniswapV4RouterLibrary)
    const libraryAddress = contractUniswapV4RouterLibrary.address
    console.log("Contract UniswapV4RouterLibrary  deployed at:", libraryAddress);

    //2.deploy UniswapV4Router
    const UniswapV4Router = await ethers.getContractFactory("UniswapV4Router", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    //0x64255ed21366DB43d89736EE48928b890A84E2Cb is poolManager's address
    const routerContract = await UniswapV4Router.deploy(poolManagerAddress);
    const routerAddress = routerContract.address
    console.log("Contract UniswapV4Router deployed at:", routerAddress);
    //3.deploy  UniswapV4Caller
    const UniswapV4Caller = await ethers.getContractFactory("UniswapV4Caller", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    const contract = await UniswapV4Caller.deploy(routerAddress,poolManagerAddress);
    const callerAddress = contract.address
    console.log("Contract UniswapV4Caller deployed at:", callerAddress);
    //4.
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });