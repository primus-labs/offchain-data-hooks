const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await ethers.getSigners();
  
    console.log(
    "test account:",
    deployer.address
    );

    const routerAddress = "0xE6ae84584D424f0cf21Dd727150ce9C1aB5962a9";
    const token1address="0x146F8F5622BA97D62dAd8C9aD6C2011cEc524922";
    const token1contract = await ethers.getContractAt("MockToken", token1address);
    const res1 = await token1contract.approve(routerAddress, '0x845951614014880000000');
    console.log("token1 approve res1=", res1);
    const token2address="0xb61872f098D5E2B76b8333fbadaed41C02124DE7";
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