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
    const libraryAddress = contractUniswapV4RouterLibrary.target;
    console.log("Contract UniswapV4RouterLibrary  deployed at:", libraryAddress);

    //2.deploy UniswapV4Router
    const UniswapV4Router = await ethers.getContractFactory("UniswapV4Router", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    const routerContract = await UniswapV4Router.deploy(poolManagerAddress);
    const routerAddress = routerContract.target;
    console.log("Contract UniswapV4Router deployed at:", routerAddress);
    
    //3.deploy  UniswapV4Caller
    const UniswapV4Caller = await ethers.getContractFactory("UniswapV4Caller", {
        libraries: {
            UniswapV4RouterLibrary: libraryAddress,
        },
    });
    const contract = await UniswapV4Caller.deploy(routerAddress,poolManagerAddress);
    const callerAddress = contract.target;
    console.log("Contract UniswapV4Caller deployed at:", callerAddress);
    
    //4. token approve
    const token1address="0x32C238b8b5B92a222EBB498A461571059Daa32c6";
    const token1contract = await ethers.getContractAt("MockToken", token1address);
    const res1 = await token1contract.approve(routerAddress, '0x845951614014880000000');
    console.log("token1 approve res1=", res1);
    const token2address="0x700c009F8C27E3030d3d8Bb9a5D99eBDAEEE465C";
    const token2contract = await ethers.getContractAt("MockToken", token2address);
    const res2 = await token2contract.approve(routerAddress, '0x845951614014880000000');
    console.log("token1 approve res2=", res2);

    //5. kyc hook
    const KYCFactory = await ethers.getContractFactory("KYCFactory");
    const contractKYCFactory = await KYCFactory.deploy();
    const contractKYCFactoryAddress = contractKYCFactory.target;
    console.log("Contract KYCFactory deployed at:", contractKYCFactoryAddress);
    
    const KYCFactoryContract = await ethers.getContractAt("KYCFactory", contractKYCFactoryAddress);
    const iEasPrxoy="0xb53F5BcB421B0aE0f0d2a16D3f7531A8d00f63aC";
    const eas="0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
    const schemaKyc="0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9";
    const schemaCountry="0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9";
    const kychooks = KYCFactoryContract.mineDeploy(poolManagerAddress, iEasPrxoy, eas, schemaKyc, schemaCountry);
    console.log('kychooks=', kychooks);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });