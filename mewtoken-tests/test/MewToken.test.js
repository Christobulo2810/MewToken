const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MewToken", function () {
  let MewToken, mewToken, owner, addr1, addr2;

  beforeEach(async function () {
    MewToken = await ethers.getContractFactory("MewToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    mewToken = await MewToken.deploy();
    await mewToken.waitForDeployment();
  });

  it("Debe asignar el suministro total al propietario", async function () {
    const ownerBalance = await mewToken.balanceOf(owner.address);
    expect(await mewToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Debe permitir la acuñación de tokens", async function () {
    await mewToken.mint(addr1.address, ethers.parseEther("100"));
    expect(await mewToken.balanceOf(addr1.address)).to.equal(ethers.parseEther("100"));
  });

  it("Debe permitir la quema de tokens", async function () {
    await mewToken.mint(owner.address, ethers.parseEther("100"));
    await mewToken.burn(ethers.parseEther("50"));
    expect(await mewToken.balanceOf(owner.address)).to.equal(ethers.parseEther("50"));
  });

  it("Debe permitir transferencias entre cuentas", async function () {
    await mewToken.mint(owner.address, ethers.parseEther("100"));
    await mewToken.transfer(addr1.address, ethers.parseEther("50"));
    expect(await mewToken.balanceOf(addr1.address)).to.equal(ethers.parseEther("50"));
  });

  it("Debe pausar y reanudar correctamente", async function () {
    await mewToken.mint(owner.address, ethers.parseEther("100")); // ✅ Asegurar que hay tokens disponibles
    await mewToken.transfer(addr1.address, ethers.parseEther("50")); // ✅ Darle tokens a addr1

    await mewToken.pause();
    await expect(mewToken.transfer(addr1.address, ethers.parseEther("50")))
      .to.be.revertedWith("Pausable: paused");
  
    await mewToken.unpause();
    await mewToken.transfer(addr2.address, ethers.parseEther("50")); // ✅ Transferencia válida después de reanudar
    expect(await mewToken.balanceOf(addr2.address)).to.equal(ethers.parseEther("50"));
  });
});
