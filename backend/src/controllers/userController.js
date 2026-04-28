const { db } = require('../config/firebase');
const logger = require('../utils/logger');

exports.getProfile = async (req, res) => {
  try {
    const { userDoc } = req;

    // Get usage stats for current period
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [aiUsageSnap, cvUsageSnap] = await Promise.all([
      db.collection('usage')
        .where('userId', '==', userDoc.id)
        .where('timestamp', '>=', todayStart)
        .get(),
      db.collection('usage')
        .where('userId', '==', userDoc.id)
        .where('featureUsed', '==', 'cv_generate')
        .where('timestamp', '>=', monthStart)
        .get(),
    ]);

    res.json({
      success: true,
      data: {
        id: userDoc.id,
        name: userDoc.name,
        email: userDoc.email,
        photoUrl: userDoc.photoUrl,
        authProvider: userDoc.authProvider,
        subscriptionType: userDoc.subscriptionType,
        subscriptionExpiry: userDoc.subscriptionExpiry,
        preferredLanguage: userDoc.preferredLanguage,
        todayAiUsage: aiUsageSnap.size,
        monthCvUsage: cvUsageSnap.size,
        createdAt: userDoc.createdAt,
      },
    });
  } catch (error) {
    logger.error('Get profile error:', error);
    res.status(500).json({ success: false, error: 'Failed to get profile.' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { userDoc } = req;
    const updates = { ...req.body, updatedAt: new Date() };

    await db.collection('users').doc(userDoc.id).update(updates);

    res.json({
      success: true,
      data: { ...userDoc, ...updates },
      message: 'Profile updated successfully.',
    });
  } catch (error) {
    logger.error('Update profile error:', error);
    res.status(500).json({ success: false, error: 'Failed to update profile.' });
  }
};

exports.getUsageHistory = async (req, res) => {
  try {
    const { userDoc } = req;
    const { limit: queryLimit = 50, offset = 0 } = req.query;

    const usageSnap = await db.collection('usage')
      .where('userId', '==', userDoc.id)
      .orderBy('timestamp', 'desc')
      .limit(parseInt(queryLimit, 10))
      .offset(parseInt(offset, 10))
      .get();

    const usage = usageSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      data: usage,
    });
  } catch (error) {
    logger.error('Get usage history error:', error);
    res.status(500).json({ success: false, error: 'Failed to get usage history.' });
  }
};
