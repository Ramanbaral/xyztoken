
const hre = require("hardhat");

async function main() {
  const contract = await hre.ethers.getContractFactory("XYZToken");
  const tokenContract = await contract.deploy();

  await tokenContract.deployed();

  console.log("Contract deployed to:", tokenContract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
