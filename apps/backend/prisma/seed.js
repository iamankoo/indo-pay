const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.upsert({
    where: { mobile: "9876543210" },
    update: {},
    create: {
      id: "usr_demo_001",
      mobile: "9876543210",
      kycStatus: "VERIFIED"
    }
  });

  const bankAccount = await prisma.bankAccount.upsert({
    where: { vpa: "ananya@indopay" },
    update: {},
    create: {
      id: "bank_demo_001",
      userId: user.id,
      maskedAccount: "XXXXXX2145",
      ifsc: "SBIN0000456",
      vpa: "ananya@indopay"
    }
  });

  const merchant = await prisma.merchant.upsert({
    where: { id: "mrc_demo_001" },
    update: {},
    create: {
      id: "mrc_demo_001",
      businessName: "Imphal Campus Cafe",
      ownerMobile: "9898989898",
      city: "Imphal",
      settlementVpa: "merchant@upi",
      kycStatus: "VERIFIED"
    }
  });

  await prisma.cashbackRule.upsert({
    where: { id: "rule_default_001" },
    update: {},
    create: {
      id: "rule_default_001",
      cashbackPercent: 0.11,
      redemptionPercent: 0.016,
      minTxn: 100,
      expiryDays: 30,
      active: true
    }
  });

  const initialTransaction = await prisma.transaction.upsert({
    where: { id: "txn_seed_001" },
    update: {},
    create: {
      id: "txn_seed_001",
      userId: user.id,
      merchantId: merchant.id,
      amount: 1000,
      bankAmount: 1000,
      walletAmount: 0,
      category: "SEED_QR_PAYMENT",
      rail: "UPI",
      status: "SUCCESS",
      providerRef: "seed_provider_ref_001",
      referenceLabel: "Initial seeded payment"
    }
  });

  const walletCredit = await prisma.walletEntry.upsert({
    where: { id: "wallet_seed_credit_001" },
    update: {},
    create: {
      id: "wallet_seed_credit_001",
      userId: user.id,
      txnId: initialTransaction.id,
      type: "CREDIT",
      amount: 110,
      expiresAt: new Date("2026-05-05T00:00:00.000Z"),
      status: "ACTIVE",
      description: "Seed cashback credit"
    }
  });

  await prisma.rewardExpiryJob.upsert({
    where: { walletEntryId: walletCredit.id },
    update: {},
    create: {
      walletEntryId: walletCredit.id,
      scheduledFor: walletCredit.expiresAt,
      status: "PENDING"
    }
  });

  await prisma.accountBalanceSnapshot.create({
    data: {
      userId: user.id,
      bankAccountId: bankAccount.id,
      availableBalance: 48650,
      currentBalance: 48990
    }
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
