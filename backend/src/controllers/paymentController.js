const paymentService = require('../services/payment');
const { db } = require('../config/firebase');
const logger = require('../utils/logger');

exports.initPayment = async (req, res) => {
  try {
    const { planType, method } = req.body;
    const userId = req.userDoc.id;
    let result;

    switch (method) {
      case 'khalti':
        result = await paymentService.initKhaltiPayment(userId, planType);
        break;
      case 'esewa':
        result = await paymentService.initEsewaPayment(userId, planType);
        break;
      case 'stripe':
        result = await paymentService.createStripePaymentIntent(userId, planType);
        break;
      default:
        return res.status(400).json({ success: false, error: 'Invalid payment method.' });
    }

    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error('Init payment error:', error);
    res.status(500).json({ success: false, error: 'Payment initialization failed.' });
  }
};

exports.verifyKhaltiPayment = async (req, res) => {
  try {
    const { transactionId } = req.body;
    const userId = req.userDoc.id;

    const verification = await paymentService.verifyKhaltiPayment(transactionId);

    if (verification.status === 'Completed') {
      // Find the payment record
      const paymentsSnap = await db.collection('payments')
        .where('transactionId', '==', transactionId)
        .where('userId', '==', userId)
        .limit(1)
        .get();

      if (paymentsSnap.empty) {
        return res.status(404).json({ success: false, error: 'Payment record not found.' });
      }

      const paymentDoc = paymentsSnap.docs[0];
      const paymentData = paymentDoc.data();

      await paymentService.activateSubscription(
        userId,
        paymentData.planType,
        paymentDoc.id,
        'khalti',
        transactionId,
      );

      return res.json({
        success: true,
        data: { message: 'Payment verified and subscription activated.' },
      });
    }

    res.status(400).json({
      success: false,
      error: 'Payment not completed.',
      status: verification.status,
    });
  } catch (error) {
    logger.error('Khalti verification error:', error);
    res.status(500).json({ success: false, error: 'Payment verification failed.' });
  }
};

exports.verifyEsewaPayment = async (req, res) => {
  try {
    const { transactionId, amount } = req.body;
    const userId = req.userDoc.id;

    const paymentsSnap = await db.collection('payments')
      .where('userId', '==', userId)
      .where('status', '==', 'pending')
      .where('method', '==', 'esewa')
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();

    if (paymentsSnap.empty) {
      return res.status(404).json({ success: false, error: 'Payment record not found.' });
    }

    const paymentDoc = paymentsSnap.docs[0];
    const paymentData = paymentDoc.data();

    const verification = await paymentService.verifyEsewaPayment(
      paymentDoc.id,
      transactionId,
      amount || paymentData.amount,
    );

    if (verification.status === 'COMPLETE') {
      await paymentService.activateSubscription(
        userId,
        paymentData.planType,
        paymentDoc.id,
        'esewa',
        transactionId,
      );

      return res.json({
        success: true,
        data: { message: 'Payment verified and subscription activated.' },
      });
    }

    res.status(400).json({ success: false, error: 'Payment not completed.' });
  } catch (error) {
    logger.error('eSewa verification error:', error);
    res.status(500).json({ success: false, error: 'Payment verification failed.' });
  }
};

exports.stripeWebhook = async (req, res) => {
  try {
    const sig = req.headers['stripe-signature'];
    const Stripe = require('stripe');
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

    const event = stripe.webhooks.constructEvent(
      req.rawBody || req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET,
    );

    await paymentService.handleStripeWebhook(event);

    res.json({ received: true });
  } catch (error) {
    logger.error('Stripe webhook error:', error);
    res.status(400).json({ error: 'Webhook error.' });
  }
};

exports.verifyReceipt = async (req, res) => {
  try {
    const { platform, receiptData, purchaseToken, productId } = req.body;
    const userId = req.userDoc.id;
    let result;

    if (platform === 'ios') {
      result = await paymentService.verifyAppleReceipt(receiptData, userId);
    } else if (platform === 'android') {
      result = await paymentService.verifyGooglePlayPurchase(purchaseToken, productId, userId);
    } else {
      return res.status(400).json({ success: false, error: 'Invalid platform.' });
    }

    if (result.valid) {
      return res.json({
        success: true,
        data: { message: 'Receipt verified and subscription activated.', planType: result.planType },
      });
    }

    res.status(400).json({ success: false, error: 'Invalid receipt.' });
  } catch (error) {
    logger.error('Receipt verification error:', error);
    res.status(500).json({ success: false, error: 'Receipt verification failed.' });
  }
};

exports.getPaymentHistory = async (req, res) => {
  try {
    const userId = req.userDoc.id;
    const { limit: queryLimit = 20 } = req.query;

    const paymentsSnap = await db.collection('payments')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(queryLimit, 10))
      .get();

    const payments = paymentsSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      data: payments,
    });
  } catch (error) {
    logger.error('Payment history error:', error);
    res.status(500).json({ success: false, error: 'Failed to get payment history.' });
  }
};
