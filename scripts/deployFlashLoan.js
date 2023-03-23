const hre = require("hardhat");

async function main() {
    const DEXimitation = await hre.ethers.getContractFactory("DEXimitation");
    const dexImitation = await DEXimitation.deploy();
    await dexImitation.deployed();

    const FlashLoan = await hre.ethers.getContractFactory("FlashLoan");
    const flashLoan = await FlashLoan.deploy("0x0496275d34753A48320CA58103d5220d394FF77F", dexImitation.address);

    await flashLoan.deployed();
    console.log("Flash Loan contract depoyed: ", flashLoan.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});