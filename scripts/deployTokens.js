const { ethers } = require("hardhat")

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
  "Deploying contracts with the account:",
  deployer.address
  );

  //console.log("Account balance:", (await deployer.getBalance()).toString());

  const MockToken = await ethers.getContractFactory("MockToken");
  const contract = await MockToken.deploy("PADO MOCK TOKEN 0","PMT1","0x845951614014880000000");
  console.log("Contract Mock Token1 deployed at:", contract.target);

  const contract2 = await MockToken.deploy("PADO MOCK TOKEN 1","PMT2","0x845951614014880000000");
  console.log("Contract Mock Token2 deployed at:", contract2.target);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});