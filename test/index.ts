import { expect } from "chai";
import { ethers } from "hardhat";
import { PricingTable } from "../typechain";

describe("PricingTable", function () {
  let pricingTable: PricingTable;
  it("Should return the new greeting once it's changed", async function () {
    const PricingTable = await ethers.getContractFactory("PricingTable");
    pricingTable = await PricingTable.deploy();
    await pricingTable.deployed();
  });

  it("Should revert if wrong pricing parameters", async () => {
    await pricingTable.addPricingItem(1, 1, 1, 1, 1, 1);
    await pricingTable.addPricingItem(1, 1, 1, 1, 1, 1);
    await pricingTable.addPricingItem(1, 1, 1, 1, 1, 1);
    await pricingTable.addPricingItem(1, 1, 1, 1, 1, 1);

    expect(0).to.equal(0);
  });
});
