const { ethers } = require("hardhat")
require('dotenv').config({ path: '.address' })
const { POOL_MANAGER,
    EASPROXY_ADDRESS, EAS_ADDRESS,
    SCHEMA_KYC_BYTES, SCHEMA_COUNTRY_BYTES,
    KYC_FACTORY } = process.env;

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );
    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

    const KYCFactoryContract = await ethers.getContractAt("KYCFactory", KYC_FACTORY);
    try {
        const kychooks = await KYCFactoryContract.mineDeploy(POOL_MANAGER,
            EASPROXY_ADDRESS, EAS_ADDRESS,
            SCHEMA_KYC_BYTES, SCHEMA_COUNTRY_BYTES);
        console.log('kychooks=', kychooks);
    } catch (ex) {
        try {
            const tx = await KYCFactoryContract.mineDeploy.staticCallResult(POOL_MANAGER,
                EASPROXY_ADDRESS, EAS_ADDRESS,
                SCHEMA_KYC_BYTES, SCHEMA_COUNTRY_BYTES);
            console.log("tx=", tx);
        } catch (error) {
            console.log("inovke caught error:\n", error);
        }
    }

    console.log("deployer account balance:", (await ethers.provider.getBalance(deployer.address)).toString());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });