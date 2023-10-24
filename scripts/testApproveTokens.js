const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();
  
    console.log(
    "test account:",
    deployer.address
    );

    const routerAddress = "0xc9b35F137F2C6f1C1DA14B73e71601238213085C";
    const token1address="0x855633649b91F9A6146aeD9CcC18cd617c8e3C3A";
    const token1contract = await ethers.getContractAt("MockToken", token1address);
    const res1 = await token1contract.approve(routerAddress, '0x845951614014880000000');
    console.log("token1 approve res1=", res1);
    const token2address="0xeccef7ccA92edF8a42B314273D96ad75fE485a8a";
    const token2contract = await ethers.getContractAt("MockToken", token2address);
    const res2 = await token2contract.approve(routerAddress, '0x845951614014880000000');
    console.log("token2 approve res2=", res2);

  }
  
  main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });