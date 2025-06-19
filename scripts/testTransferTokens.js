const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();
  
    console.log(
    "test account:",
    deployer.address
    );

    const receiveAddr = "0x975E046751862b5A0406280DAA3d52Ee5db1AF8C";
    const token1address="0x855633649b91F9A6146aeD9CcC18cd617c8e3C3A";
    const token1contract = await ethers.getContractAt("MockToken", token1address);
    const res1 = await token1contract.transfer(receiveAddr, 1e10);
    console.log("token1 transfer res1=", res1);
    const token2address="0xeccef7ccA92edF8a42B314273D96ad75fE485a8a";
    const token2contract = await ethers.getContractAt("MockToken", token2address);
    const res2 = await token2contract.transfer(receiveAddr, 1e10);
    console.log("token1 transfer res2=", res2);

  }
  
  main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });