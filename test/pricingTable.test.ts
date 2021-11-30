import { expect } from "chai";
import { ethers } from "hardhat";
import { Offers, PricingTable } from "../typechain";
import { getTimestamp, increaseTime, ONE_DAY } from "./helpers";

describe("PricingTable", function () {
  let pricingTable: PricingTable;
  let offers: Offers;
  let timestamp: number;
  before(async () => {
    timestamp = await getTimestamp();
    console.log(timestamp);
  });

  it("Should return the new greeting once it's changed", async function () {
    const PricingTable = await ethers.getContractFactory("PricingTable");
    pricingTable = await PricingTable.deploy();
    await pricingTable.deployed();
  });

  it("Should add 606A pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x606A", 20, 60, 90, 65, 12, 5000, 10000)
      .then((tx) => tx.wait());
  });

  it("Should add 01A2 pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x01A2", 1, 1, 1, 1, 1, 1, 1)
      .then((tx) => tx.wait());
  });

  it("Should add 57A2 pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x57A2", 60, 90, 9000, 375, 105, 8000000, 10000000)
      .then((tx) => tx.wait());
  });

  it("Should add 41A2 pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x41A2", 60, 89, 9000, 700, 173, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should add 643A pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x643A", 30, 59, 9000, 375, 70, 8000100, 10000000)
      .then((tx) => tx.wait());
  });

  it("Should add 684B pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x684B", 90, 119, 9000, 400, 20, 8000100, 10000000)
      .then((tx) => tx.wait());
  });

  it("Should add 624B pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x624B", 20, 29, 9000, 400, 50, 8000100, 10000000)
      .then((tx) => tx.wait());
  });

  it("Should add 647A pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x647A", 60, 89, 9000, 700, 173, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should add 668B pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x668B", 90, 119, 9000, 750, 200, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should add 689C pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x689C", 120, 180, 9000, 800, 227, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should add 629C pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x629C", 30, 59, 9000, 800, 160, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should return a pricingItem", async () => {
    const pricingItem = await pricingTable.getPricingItem("0x01a2");

    expect(pricingItem.minTenure).to.equal(1);
    expect(pricingItem.maxTenure).to.equal(1);
    expect(pricingItem.maxAdvancedRatio).to.equal(1);
    expect(pricingItem.minDiscountFee).to.equal(1);
    expect(pricingItem.minFactoringFee).to.equal(1);
    expect(pricingItem.minAmount).to.equal(1);
    expect(pricingItem.maxAmount).to.equal(1);
  });

  it("Should remove a pricingItem", async () => {
    await pricingTable.removePricingItem("0x01a2");
  });

  it("Should remove 0 if pricingItem has been deleted", async () => {
    const pricingItem = await pricingTable.getPricingItem("0x01a2");
    expect(pricingItem.minTenure).to.equal(0);
    expect(pricingItem.maxTenure).to.equal(0);
    expect(pricingItem.maxAdvancedRatio).to.equal(0);
    expect(pricingItem.minDiscountFee).to.equal(0);
    expect(pricingItem.minFactoringFee).to.equal(0);
    expect(pricingItem.minAmount).to.equal(0);
  });

  it("Should deploy Offer Contract", async () => {
    const Offers = await ethers.getContractFactory("Offers");
    offers = await Offers.deploy(pricingTable.address);
    await offers.deployed();

    await offers.createOffer("0x606a", {
      advanceFee: 90,
      discountFee: 75,
      factoringFee: 20,
      gracePeriod: 1,
      availableAmount: 9000,
      invoiceAmount: 9000,
      tenure: 60,
      // tokenAddress: "0x2e3c1bAe5D365D1dcd0EaC91B00d54518717Ee06",
    });

    // console.log((await offers.Offers(1)).toString());

    const date = Math.floor(Date.now() / 1000);
    await offers.reserveRefund(1, date + 60 * 60, 2);
  });

  it("Should create Offer(2) scenario 1 grade A with Invoice == Available", async (offerId: number = 2) => {
    await offers.createOffer("0x57A2", {
      advanceFee: 8800,
      discountFee: 390,
      factoringFee: 135,
      gracePeriod: 1,
      availableAmount: 8934578,
      invoiceAmount: 8934578,
      tenure: 79,
    });

    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("7862428");
    expect(offer.reserve).to.equal("1072150");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(1);
    expect(offer.params.tenure).to.equal(79);
    expect(offer.params.factoringFee).to.equal(135);
    expect(offer.params.discountFee).to.equal(390);
    expect(offer.params.advanceFee).to.equal(8800);
    expect(offer.params.invoiceAmount).to.equal("8934578");
    expect(offer.params.availableAmount).to.equal("8934578");
  });

  it("Should reserveRefund for Offer(2) scenario 1 grade A with Invoice == Available", async (offerId: number = 2) => {
    await offers.reserveRefund(offerId, timestamp, 0);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp);
    expect(offer.refunded.lateFee).to.equal(0);
    expect(offer.refunded.numberOfLateDays).to.equal(0);
    expect(offer.refunded.totalCalculatedFees).to.equal("186983");
    expect(offer.refunded.netAmount).to.equal("885167");
    expect(offer.refunded.rewards).to.equal("0");
  });

  it("Should create Offer(3) scenario 2 grade A with Invoice == Available", async (offerId: number = 3) => {
    await offers.createOffer("0x643A", {
      advanceFee: 8500,
      discountFee: 375,
      factoringFee: 80,
      gracePeriod: 1,
      availableAmount: 8934578,
      invoiceAmount: 8934578,
      tenure: 45,
    });

    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("7594391");
    expect(offer.reserve).to.equal("1340187");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(1);
    expect(offer.params.tenure).to.equal(45);
    expect(offer.params.factoringFee).to.equal(80);
    expect(offer.params.discountFee).to.equal(375);
    expect(offer.params.advanceFee).to.equal(8500);
    expect(offer.params.invoiceAmount).to.equal("8934578");
    expect(offer.params.availableAmount).to.equal("8934578");
  });

  it("Should reserveRefund for Offer(3) scenario 2 grade A with Invoice == Available", async (offerId: number = 3) => {
    await offers.reserveRefund(offerId, timestamp, 0);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp);
    expect(offer.refunded.lateFee).to.equal(0);
    expect(offer.refunded.numberOfLateDays).to.equal(0);
    expect(offer.refunded.totalCalculatedFees).to.equal("106587");
    expect(offer.refunded.netAmount).to.equal("1233600");
    expect(offer.refunded.rewards).to.equal("0");
  });

  it("Should create Offer(4) scenario 3 grade B with Invoice == Available", async (offerId: number = 4) => {
    await offers.createOffer("0x684B", {
      advanceFee: 7000,
      discountFee: 445,
      factoringFee: 256,
      gracePeriod: 1,
      availableAmount: 8934578,
      invoiceAmount: 8934578,
      tenure: 100,
    });

    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("6254204");
    expect(offer.reserve).to.equal("2680374");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(1);
    expect(offer.params.tenure).to.equal(100);
    expect(offer.params.factoringFee).to.equal(256);
    expect(offer.params.discountFee).to.equal(445);
    expect(offer.params.advanceFee).to.equal(7000);
    expect(offer.params.invoiceAmount).to.equal("8934578");
    expect(offer.params.availableAmount).to.equal("8934578");
  });

  it("Should reserveRefund Offer(4) scenario 3 grade B with Invoice == Available", async (offerId: number = 4) => {
    await offers.reserveRefund(offerId, timestamp, 0);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp);
    expect(offer.refunded.lateFee).to.equal(0);
    expect(offer.refunded.numberOfLateDays).to.equal(0);
    expect(offer.refunded.totalCalculatedFees).to.equal("304974");
    expect(offer.refunded.netAmount).to.equal("2375400");
    expect(offer.refunded.rewards).to.equal("0");
  });

  it("Should fail creating Offer(5) scenario 4 grade B with Invoice == Available", async () => {
    await expect(
      offers.createOffer("0x624B", {
        advanceFee: 7200,
        discountFee: 430,
        factoringFee: 40,
        gracePeriod: 1,
        availableAmount: 8934578,
        invoiceAmount: 8934578,
        tenure: 22,
      })
    ).to.be.revertedWith("InvalidFactoringFee(40, 50)");
  });

  it("Should create Offer(5) scenario 1 grade B with Invoice != Available", async (offerId: number = 5) => {
    await offers.createOffer("0x647A", {
      advanceFee: 8000,
      discountFee: 750,
      factoringFee: 180,
      gracePeriod: 2,
      invoiceAmount: 1000000,
      availableAmount: 900000,
      tenure: 60,
    });

    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("720000");
    expect(offer.reserve).to.equal("280000");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(2);
    expect(offer.params.tenure).to.equal(60);
    expect(offer.params.factoringFee).to.equal(180);
    expect(offer.params.discountFee).to.equal(750);
    expect(offer.params.advanceFee).to.equal(8000);
    expect(offer.params.invoiceAmount).to.equal("1000000");
    expect(offer.params.availableAmount).to.equal("900000");
  });

  it("Should reserveRefund for Offer(5) scenario 1 grade B with Invoice != Available", async (offerId: number = 5) => {
    const now = timestamp;

    await increaseTime(ONE_DAY * 8);
    await offers.reserveRefund(offerId, now, 2750);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp);
    expect(offer.refunded.lateFee).to.equal(2750);
    expect(offer.refunded.numberOfLateDays).to.equal(8);
    expect(offer.refunded.totalCalculatedFees).to.equal("31215");
    expect(offer.refunded.netAmount).to.equal("248785");
    expect(offer.refunded.rewards).to.equal("0");
  });

  it("Should create Offer(6) scenario 2 grade B with Invoice != Available", async (offerId: number = 6) => {
    await offers.createOffer("0x668B", {
      advanceFee: 8900,
      discountFee: 800,
      factoringFee: 253,
      gracePeriod: 6,
      invoiceAmount: 1000000,
      availableAmount: 900000,
      tenure: 95,
    });
    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("801000");
    expect(offer.reserve).to.equal("199000");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(6);
    expect(offer.params.tenure).to.equal(95);
    expect(offer.params.factoringFee).to.equal(253);
    expect(offer.params.discountFee).to.equal(800);
    expect(offer.params.advanceFee).to.equal(8900);
    expect(offer.params.invoiceAmount).to.equal("1000000");
    expect(offer.params.availableAmount).to.equal("900000");
  });

  it("Should reserveRefund for Offer(6) scenario 1 grade B with Invoice != Available", async (offerId: number = 6) => {
    await offers.reserveRefund(offerId, timestamp + ONE_DAY * 10, 2750);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp + ONE_DAY * 10);
    expect(offer.refunded.lateFee).to.equal(2750);
    expect(offer.refunded.numberOfLateDays).to.equal(0);
    expect(offer.refunded.totalCalculatedFees).to.equal("41978");
    expect(offer.refunded.netAmount).to.equal("157022");
    expect(offer.refunded.rewards).to.equal("0");
  });

  it("Should fail create Offer(7) scenario 3 grade C with Invoice != Available", async () => {
    await expect(
      offers.createOffer("0x689C", {
        advanceFee: 7200,
        discountFee: 730,
        factoringFee: 227,
        gracePeriod: 5,
        invoiceAmount: 1000000,
        availableAmount: 900000,
        tenure: 120,
      })
    ).to.be.revertedWith("InvalidDiscountFee(730, 800)");
  });

  it("Should create Offer(7) scenario 4 grade C with Invoice != Available", async (offerId: number = 7) => {
    await offers.createOffer("0x629C", {
      advanceFee: 9000,
      discountFee: 820,
      factoringFee: 195,
      gracePeriod: 9,
      invoiceAmount: 1000000,
      availableAmount: 900000,
      tenure: 30,
    });

    const offer = await offers.Offers(offerId);
    expect(offer.advancedAmount).to.equal("810000");
    expect(offer.reserve).to.equal("190000");
    expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

    expect(offer.params.gracePeriod).to.equal(9);
    expect(offer.params.tenure).to.equal(30);
    expect(offer.params.factoringFee).to.equal(195);
    expect(offer.params.discountFee).to.equal(820);
    expect(offer.params.advanceFee).to.equal(9000);
    expect(offer.params.invoiceAmount).to.equal("1000000");
    expect(offer.params.availableAmount).to.equal("900000");
  });

  it("Should reserveRefund for Offer(7) scenario 4 grade C with Invoice != Available", async (offerId: number = 7) => {
    await offers.reserveRefund(offerId, timestamp + 9 * ONE_DAY, 2750);
    const offer = await offers.Offers(offerId);
    expect(offer.refunded.dueDate).to.equal(timestamp + 9 * ONE_DAY);
    expect(offer.refunded.lateFee).to.equal(2750);
    expect(offer.refunded.numberOfLateDays).to.equal(0);
    expect(offer.refunded.totalCalculatedFees).to.equal("24959");
    expect(offer.refunded.netAmount).to.equal("165041");
    expect(offer.refunded.rewards).to.equal("0");
  });
});
