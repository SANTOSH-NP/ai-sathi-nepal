const jwt = require('jsonwebtoken');
const { auth, db } = require('../config/firebase');
const logger = require('../utils/logger');

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Access denied. No token provided.',
      });
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    // Check if user still exists
    const userDoc = await db.collection('users').doc(decoded.uid).get();
    if (!userDoc.exists) {
      return res.status(401).json({
        success: false,
        error: 'User no longer exists.',
      });
    }

    req.userDoc = { id: userDoc.id, ...userDoc.data() };
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: 'Token expired. Please refresh your token.',
        code: 'TOKEN_EXPIRED',
      });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: 'Invalid token.',
      });
    }
    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      error: 'Authentication failed.',
    });
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    const userDoc = await db.collection('users').doc(decoded.uid).get();
    if (userDoc.exists) {
      req.userDoc = { id: userDoc.id, ...userDoc.data() };
    }
  } catch {
    req.user = null;
  }
  next();
};

const requirePremium = (req, res, next) => {
  if (!req.userDoc) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required.',
    });
  }

  const { subscriptionType, subscriptionExpiry } = req.userDoc;
  const isPremium = (subscriptionType === 'premium_monthly' || subscriptionType === 'premium_yearly');
  const isActive = subscriptionExpiry && new Date(subscriptionExpiry._seconds * 1000) > new Date();

  if (!isPremium || !isActive) {
    return res.status(403).json({
      success: false,
      error: 'Premium subscription required.',
      code: 'PREMIUM_REQUIRED',
    });
  }

  next();
};

module.exports = { verifyToken, optionalAuth, requirePremium };
