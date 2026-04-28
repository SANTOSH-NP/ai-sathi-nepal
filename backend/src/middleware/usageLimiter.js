const { db } = require('../config/firebase');
const { FREE_LIMITS, FEATURES } = require('../config/constants');
const logger = require('../utils/logger');

const AI_FEATURES = [
  FEATURES.AI_GRAMMAR, FEATURES.AI_SUMMARIZE,
  FEATURES.AI_TRANSLATE, FEATURES.AI_REWRITE,
  FEATURES.EMAIL_GEN, FEATURES.CAPTION_GEN, FEATURES.JOB_MESSAGE,
];

const checkUsageLimit = (featureType) => async (req, res, next) => {
  try {
    const { userDoc } = req;

    // Premium users have unlimited access
    if (userDoc.subscriptionType === 'premium_monthly' || userDoc.subscriptionType === 'premium_yearly') {
      const expiry = userDoc.subscriptionExpiry;
      if (expiry && new Date(expiry._seconds * 1000) > new Date()) {
        return next();
      }
    }

    const now = new Date();
    let limit;
    let windowStart;

    if (AI_FEATURES.includes(featureType)) {
      limit = FREE_LIMITS.AI_CALLS_PER_DAY;
      windowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else if (featureType === FEATURES.CV_GENERATE) {
      limit = FREE_LIMITS.CV_DOWNLOADS_PER_MONTH;
      windowStart = new Date(now.getFullYear(), now.getMonth(), 1);
    } else if (featureType === FEATURES.IMAGE_TO_PDF) {
      limit = FREE_LIMITS.IMAGE_TO_PDF_PER_DAY;
      windowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else {
      return next();
    }

    const usageSnapshot = await db.collection('usage')
      .where('userId', '==', userDoc.id)
      .where('featureUsed', '==', featureType)
      .where('timestamp', '>=', windowStart)
      .get();

    if (usageSnapshot.size >= limit) {
      return res.status(429).json({
        success: false,
        error: 'Usage limit reached. Upgrade to Premium for unlimited access.',
        code: 'USAGE_LIMIT_REACHED',
        currentUsage: usageSnapshot.size,
        limit,
      });
    }

    req.currentUsage = usageSnapshot.size;
    next();
  } catch (error) {
    logger.error('Usage limiter error:', error);
    next();
  }
};

const trackUsage = async (userId, featureUsed, metadata = {}) => {
  try {
    await db.collection('usage').add({
      userId,
      featureUsed,
      timestamp: new Date(),
      ...metadata,
    });
  } catch (error) {
    logger.error('Track usage error:', error);
  }
};

module.exports = { checkUsageLimit, trackUsage };
