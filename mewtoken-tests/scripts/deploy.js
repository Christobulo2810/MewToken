const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contract with account:", deployer.address);

    const Token = await hre.ethers.getContractFactory("MewToken");
    const token = await Token.deploy();

    await token.waitForDeployment();

    console.log("MewToken deployed to:", token.target); // ⬅️ Esto debería mostrar la dirección correcta
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
