const { ethers } = require("hardhat")

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    const sr = "0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519";// for test, doesn't matter
    const MockEAS = await ethers.getContractFactory("MockEAS");
    const eascontract = await MockEAS.deploy(sr);

    const MockEASProxy = await ethers.getContractFactory("MockEASProxy");
    const easproxycontract = await MockEASProxy.deploy();

    console.log(`EAS_ADDRESS=${eascontract.target}`);
    console.log(`EASPROXY_ADDRESS=${easproxycontract.target}`);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });