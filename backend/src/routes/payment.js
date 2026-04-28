const express = require('express');
const paymentController = require('../controllers/paymentController');
const { verifyToken } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validator');
const { paymentRateLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

// Stripe webhook (must be before verifyToken middleware, uses raw body)
router.post('/stripe/webhook', express.raw({ type: 'application/json' }), paymentController.stripeWebhook);

// All other payment routes require auth
router.use(verifyToken);
router.use(paymentRateLimiter);

router.post('/init', validate(schemas.paymentInit), paymentController.initPayment);
router.post('/khalti/verify', paymentController.verifyKhaltiPayment);
router.post('/esewa/verify', paymentController.verifyEsewaPayment);
router.post('/verify-receipt', paymentController.verifyReceipt);
router.get('/history', paymentController.getPaymentHistory);

module.exports = router;
