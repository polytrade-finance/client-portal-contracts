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

  it("Should add a pricing Item", async () => {
    const tx = await pricingTable
      .addPricingItem(1, 1, 1, 1, 1, 1)
      .then((tx) => tx.wait());
    const pricingId = parseInt(tx.logs[0].data);
    expect(pricingId).to.equal(1);
  });

  it("Should add second pricing Item", async () => {
    const tx = await pricingTable
      .addPricingItem(1, 1, 1, 1, 1, 1)
      .then((tx) => tx.wait());
    const pricingId = parseInt(tx.logs[0].data);
    expect(pricingId).to.equal(2);
  });

  it("Should return a pricingItem", async () => {
    const pricingItem = await pricingTable.getPricingItem(1);

    expect(pricingItem.minTenure).to.equal(1);
    expect(pricingItem.maxTenure).to.equal(1);
    expect(pricingItem.maxAdvancedRatio).to.equal(1);
    expect(pricingItem.minDiscountRange).to.equal(1);
    expect(pricingItem.minFactoringFee).to.equal(1);
    expect(pricingItem.minAmount).to.equal(1);
  });

  it("Should remove a pricingItem", async () => {
    await pricingTable.removePricingItem(1);
  });

  it("Should remove 0 if pricingItem has been deleted", async () => {
    const pricingItem = await pricingTable.getPricingItem(1);
    expect(pricingItem.minTenure).to.equal(0);
    expect(pricingItem.maxTenure).to.equal(0);
    expect(pricingItem.maxAdvancedRatio).to.equal(0);
    expect(pricingItem.minDiscountRange).to.equal(0);
    expect(pricingItem.minFactoringFee).to.equal(0);
    expect(pricingItem.minAmount).to.equal(0);
  });
});
