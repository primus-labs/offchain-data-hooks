const { ethers } = require("hardhat")

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );
    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

    const PoolManager = await ethers.getContractFactory("PoolManager");
    const poolManagerContract = await PoolManager.deploy(500000);
    console.log(`POOL_MANAGER=${poolManagerContract.target}`);

    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });