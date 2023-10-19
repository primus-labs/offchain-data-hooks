const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );
    
    const poolManagerAddress = '0x64255ed21366DB43d89736EE48928b890A84E2Cb'
    const contractKYCFactoryAddress = "0x376A6b8CEA5021bDcEb6b346dA5C2e7aED177f1d";
    const KYCFactoryContract = await ethers.getContractAt("KYCFactory", contractKYCFactoryAddress);
    const iEasPrxoy="0xb53F5BcB421B0aE0f0d2a16D3f7531A8d00f63aC";
    const eas="0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
    const schemaKyc="0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9";
    const schemaCountry="0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9";
    try {
        const kychooks = await KYCFactoryContract.mineDeploy(poolManagerAddress, iEasPrxoy, eas, schemaKyc, schemaCountry);
        console.log('kychooks=', kychooks);
    } catch (ex) {
        try {
            const tx = await KYCFactoryContract.mineDeploy.staticCallResult(poolManagerAddress, iEasPrxoy, eas, schemaKyc, schemaCountry);
            console.log("tx=", tx);
        } catch (error) {
          console.log("inovke caught error:\n", error);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });