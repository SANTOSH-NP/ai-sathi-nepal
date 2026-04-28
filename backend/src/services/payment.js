const axios = require('axios');
const Stripe = require('stripe');
const { db } = require('../config/firebase');
const { PAYMENT_STATUS, SUBSCRIPTION_TYPES } = require('../config/constants');
const logger = require('../utils/logger');

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Plan pricing
const PLANS = {
  premium_monthly: {
    priceNPR: parseInt(process.env.PREMIUM_MONTHLY_PRICE_NPR || '299', 10),
    priceUSD: parseFloat(process.env.PREMIUM_MONTHLY_PRICE_USD || '2.99'),
    durationDays: 30,
  },
  premium_yearly: {
    priceNPR: parseInt(process.env.PREMIUM_YEARLY_PRICE_NPR || '2499', 10),
    priceUSD: parseFloat(process.env.PREMIUM_YEARLY_PRICE_USD || '24.99'),
    durationDays: 365,
  },
};

// ─── Khalti ─────────────────────────────────────────────

async function initKhaltiPayment(userId, planType) {
  const plan = PLANS[planType];
  const paymentRef = db.collection('payments').doc();

  await paymentRef.set({
    userId,
    amount: plan.priceNPR,
    currency: 'NPR',
    method: 'khalti',
    status: PAYMENT_STATUS.PENDING,
    planType,
    createdAt: new Date(),
  });

  const response = await axios.post(
    `${process.env.KHALTI_API_URL}/epayment/initiate/`,
    {
      return_url: `${process.env.BACKEND_URL || 'https://api.aisathinepal.com'}/api/v1/payment/khalti/callback`,
      website_url: 'https://aisathinepal.com',
      amount: plan.priceNPR * 100, // Khalti uses paisa
      purchase_order_id: paymentRef.id,
      purchase_order_name: `AI Sathi Nepal - ${planType}`,
    },
    {
      headers: { Authorization: `Key ${process.env.KHALTI_SECRET_KEY}` },
    },
  );

  await paymentRef.update({ transactionId: response.data.pidx });

  return {
    paymentId: paymentRef.id,
    paymentUrl: response.data.payment_url,
    pidx: response.data.pidx,
  };
}

async function verifyKhaltiPayment(pidx) {
  const response = await axios.post(
    `${process.env.KHALTI_API_URL}/epayment/lookup/`,
    { pidx },
    {
      headers: { Authorization: `Key ${process.env.KHALTI_SECRET_KEY}` },
    },
  );

  return response.data;
}

// ─── eSewa ──────────────────────────────────────────────

async function initEsewaPayment(userId, planType) {
  const plan = PLANS[planType];
  const paymentRef = db.collection('payments').doc();

  await paymentRef.set({
    userId,
    amount: plan.priceNPR,
    currency: 'NPR',
    method: 'esewa',
    status: PAYMENT_STATUS.PENDING,
    planType,
    createdAt: new Date(),
  });

  // eSewa payment parameters
  const params = {
    amt: plan.priceNPR,
    psc: 0,
    pdc: 0,
    txAmt: 0,
    tAmt: plan.priceNPR,
    pid: paymentRef.id,
    scd: process.env.ESEWA_MERCHANT_ID,
    su: `${process.env.BACKEND_URL || 'https://api.aisathinepal.com'}/api/v1/payment/esewa/callback?paymentId=${paymentRef.id}`,
    fu: `${process.env.BACKEND_URL || 'https://api.aisathinepal.com'}/api/v1/payment/esewa/failure`,
  };

  return {
    paymentId: paymentRef.id,
    esewaParams: params,
    esewaUrl: process.env.ESEWA_API_URL,
  };
}

async function verifyEsewaPayment(paymentId, referenceId, amount) {
  const response = await axios.get(
    `${process.env.ESEWA_API_URL}/api/epay/transaction/status/`,
    {
      params: {
        product_code: process.env.ESEWA_MERCHANT_ID,
        total_amount: amount,
        transaction_uuid: referenceId,
      },
    },
  );

  return response.data;
}

// ─── Stripe ─────────────────────────────────────────────

async function createStripePaymentIntent(userId, planType) {
  const plan = PLANS[planType];
  const paymentRef = db.collection('payments').doc();

  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(plan.priceUSD * 100), // Stripe uses cents
    currency: 'usd',
    metadata: {
      userId,
      planType,
      paymentId: paymentRef.id,
    },
  });

  await paymentRef.set({
    userId,
    amount: plan.priceUSD,
    currency: 'USD',
    method: 'stripe',
    status: PAYMENT_STATUS.PENDING,
    planType,
    transactionId: paymentIntent.id,
    createdAt: new Date(),
  });

  return {
    paymentId: paymentRef.id,
    clientSecret: paymentIntent.client_secret,
    publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
  };
}

async function handleStripeWebhook(event) {
  if (event.type === 'payment_intent.succeeded') {
    const { userId, planType, paymentId } = event.data.object.metadata;
    await activateSubscription(userId, planType, paymentId, 'stripe', event.data.object.id);
  }
}

// ─── Subscription Management ────────────────────────────

async function activateSubscription(userId, planType, paymentId, method, transactionId) {
  const plan = PLANS[planType];
  const now = new Date();
  const expiry = new Date(now.getTime() + plan.durationDays * 24 * 60 * 60 * 1000);

  const batch = db.batch();

  // Update payment status
  const paymentRef = db.collection('payments').doc(paymentId);
  batch.update(paymentRef, {
    status: PAYMENT_STATUS.COMPLETED,
    transactionId,
    verifiedAt: now,
  });

  // Update user subscription
  const userRef = db.collection('users').doc(userId);
  batch.update(userRef, {
    subscriptionType: planType,
    subscriptionExpiry: expiry,
    updatedAt: now,
  });

  await batch.commit();

  logger.info(`Subscription activated: user=${userId}, plan=${planType}, expires=${expiry.toISOString()}`);

  return { subscriptionType: planType, expiry };
}

// ─── IAP Receipt Verification ───────────────────────────

async function verifyAppleReceipt(receiptData, userId) {
  // Apple receipt verification
  const response = await axios.post(
    'https://buy.itunes.apple.com/verifyReceipt',
    {
      'receipt-data': receiptData,
      password: process.env.APPLE_SHARED_SECRET,
    },
  );

  if (response.data.status === 0) {
    const latestReceipt = response.data.latest_receipt_info?.[0];
    if (latestReceipt) {
      const planType = latestReceipt.product_id.includes('yearly')
        ? SUBSCRIPTION_TYPES.PREMIUM_YEARLY
        : SUBSCRIPTION_TYPES.PREMIUM_MONTHLY;

      const paymentRef = db.collection('payments').doc();
      await paymentRef.set({
        userId,
        method: 'apple_iap',
        status: PAYMENT_STATUS.COMPLETED,
        planType,
        transactionId: latestReceipt.transaction_id,
        createdAt: new Date(),
        verifiedAt: new Date(),
      });

      await activateSubscription(userId, planType, paymentRef.id, 'apple_iap', latestReceipt.transaction_id);
      return { valid: true, planType };
    }
  }

  return { valid: false };
}

async function verifyGooglePlayPurchase(purchaseToken, productId, userId) {
  // Google Play purchase verification would use googleapis
  // This is a placeholder for the actual implementation
  logger.info(`Verifying Google Play purchase: user=${userId}, product=${productId}`);

  const planType = productId.includes('yearly')
    ? SUBSCRIPTION_TYPES.PREMIUM_YEARLY
    : SUBSCRIPTION_TYPES.PREMIUM_MONTHLY;

  const paymentRef = db.collection('payments').doc();
  await paymentRef.set({
    userId,
    method: 'google_play',
    status: PAYMENT_STATUS.COMPLETED,
    planType,
    transactionId: purchaseToken,
    createdAt: new Date(),
    verifiedAt: new Date(),
  });

  await activateSubscription(userId, planType, paymentRef.id, 'google_play', purchaseToken);
  return { valid: true, planType };
}

module.exports = {
  initKhaltiPayment,
  verifyKhaltiPayment,
  initEsewaPayment,
  verifyEsewaPayment,
  createStripePaymentIntent,
  handleStripeWebhook,
  activateSubscription,
  verifyAppleReceipt,
  verifyGooglePlayPurchase,
  PLANS,
};
