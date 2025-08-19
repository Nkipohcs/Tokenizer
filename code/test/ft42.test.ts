import { expect } from "chai";
import { ethers } from "hardhat";
import { FT42Token } from "../typechain-types";

describe("FT42Token", function () {
  const DEC = 18n;
  const ONE = 10n ** DEC;
  const INIT = 1_000_000n * ONE;
  const CAP  = 10_000_000n * ONE;

  async function deploy() {
    const [owner, u1, u2] = await ethers.getSigners();
    const FT42 = await ethers.getContractFactory("FT42Token");
    const token = (await FT42.deploy(owner.address, INIT, CAP)) as unknown as FT42Token;
    await token.waitForDeployment();
    return { owner, u1, u2, token };
  }

  it("has correct name/symbol/decimals", async () => {
    const { token } = await deploy();
    expect(await token.name()).to.eq("FortyTwo Token");
    expect(await token.symbol()).to.eq("FT42");
    expect(await token.decimals()).to.eq(18);
  });

  it("mints initial supply to owner", async () => {
    const { owner, token } = await deploy();
    expect(await token.totalSupply()).to.eq(INIT);
    expect(await token.balanceOf(owner.address)).to.eq(INIT);
  });

  it("owner can mint within cap; non-owner cannot", async () => {
    const { owner, u1, token } = await deploy();
    await expect(token.connect(u1).mint(u1.address, ONE)).to.be.reverted;
    await expect(token.connect(owner).mint(u1.address, ONE)).to.emit(token, "Transfer");
    expect(await token.totalSupply()).to.eq(INIT + ONE);
  });

  it("cannot exceed cap", async () => {
    const { owner, token } = await deploy();
    const remaining = CAP - INIT;
    await expect(token.connect(owner).mint(owner.address, remaining)).to.emit(token, "Transfer");
    await expect(token.connect(owner).mint(owner.address, 1)).to.be.reverted; // capped
  });

  it("pauses transfers", async () => {
    const { owner, u1, u2, token } = await deploy();
    await token.connect(owner).transfer(u1.address, 100n * ONE);
    await token.connect(owner).pause();
    await expect(token.connect(u1).transfer(u2.address, ONE)).to.be.reverted;
    await token.connect(owner).unpause();
    await expect(token.connect(u1).transfer(u2.address, ONE)).to.emit(token, "Transfer");
  });

  it("burn works", async () => {
    const { owner, token } = await deploy();
    const s0 = await token.totalSupply();
    await token.connect(owner).burn(5n * ONE);
    expect(await token.totalSupply()).to.eq(s0 - 5n * ONE);
  });

  it("rescue cannot pull FT42 itself", async () => {
    const { owner, token } = await deploy();
    await expect(token.connect(owner).rescueERC20(await token.getAddress(), owner.address, 1)).to.be.reverted;
  });
});
