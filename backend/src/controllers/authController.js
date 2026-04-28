const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { auth, db } = require('../config/firebase');
const { AUTH_PROVIDERS, SUBSCRIPTION_TYPES, FREE_LIMITS } = require('../config/constants');
const logger = require('../utils/logger');

function generateTokens(user) {
  const accessToken = jwt.sign(
    { uid: user.id, email: user.email, role: user.role || 'user' },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' },
  );

  const refreshToken = jwt.sign(
    { uid: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' },
  );

  return { accessToken, refreshToken };
}

async function findOrCreateUser(uid, data) {
  const userRef = db.collection('users').doc(uid);
  const userDoc = await userRef.get();

  if (userDoc.exists) {
    await userRef.update({ updatedAt: new Date() });
    return { id: userDoc.id, ...userDoc.data() };
  }

  const newUser = {
    id: uid,
    name: data.name || '',
    email: data.email || '',
    photoUrl: data.photoUrl || '',
    authProvider: data.authProvider,
    subscriptionType: SUBSCRIPTION_TYPES.FREE,
    subscriptionExpiry: null,
    usageLimits: {
      aiCalls: FREE_LIMITS.AI_CALLS_PER_DAY,
      cvDownloads: FREE_LIMITS.CV_DOWNLOADS_PER_MONTH,
      imageToPdf: FREE_LIMITS.IMAGE_TO_PDF_PER_DAY,
    },
    preferredLanguage: 'en',
    deviceIds: [],
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  await userRef.set(newUser);
  return newUser;
}

exports.register = async (req, res) => {
  try {
    const { email, password, name } = req.body;

    const firebaseUser = await auth.createUser({
      email,
      password,
      displayName: name,
      emailVerified: false,
    });

    // Send email verification
    const verificationLink = await auth.generateEmailVerificationLink(email);
    logger.info(`Verification link generated for ${email}`);

    const user = await findOrCreateUser(firebaseUser.uid, {
      name,
      email,
      authProvider: AUTH_PROVIDERS.EMAIL,
    });

    const tokens = generateTokens(user);

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          subscriptionType: user.subscriptionType,
        },
        ...tokens,
        verificationLink,
      },
    });
  } catch (error) {
    logger.error('Registration error:', error);
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({
        success: false,
        error: 'Email already registered.',
      });
    }
    res.status(500).json({
      success: false,
      error: 'Registration failed.',
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Verify with Firebase - we get user by email first
    const firebaseUser = await auth.getUserByEmail(email);

    // For email/password auth, the client should use Firebase SDK
    // Here we just verify the user exists and generate our JWT
    const user = await findOrCreateUser(firebaseUser.uid, {
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      authProvider: AUTH_PROVIDERS.EMAIL,
    });

    const tokens = generateTokens(user);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          subscriptionType: user.subscriptionType,
          photoUrl: user.photoUrl,
        },
        ...tokens,
      },
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(401).json({
      success: false,
      error: 'Invalid credentials.',
    });
  }
};

exports.googleSignIn = async (req, res) => {
  try {
    const { idToken } = req.body;

    const decodedToken = await auth.verifyIdToken(idToken);
    const firebaseUser = await auth.getUser(decodedToken.uid);

    const user = await findOrCreateUser(firebaseUser.uid, {
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      photoUrl: firebaseUser.photoURL,
      authProvider: AUTH_PROVIDERS.GOOGLE,
    });

    const tokens = generateTokens(user);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          subscriptionType: user.subscriptionType,
          photoUrl: user.photoUrl,
        },
        ...tokens,
      },
    });
  } catch (error) {
    logger.error('Google sign-in error:', error);
    res.status(401).json({
      success: false,
      error: 'Google authentication failed.',
    });
  }
};

exports.appleSignIn = async (req, res) => {
  try {
    const { idToken } = req.body;

    const decodedToken = await auth.verifyIdToken(idToken);
    const firebaseUser = await auth.getUser(decodedToken.uid);

    const user = await findOrCreateUser(firebaseUser.uid, {
      name: firebaseUser.displayName || 'Apple User',
      email: firebaseUser.email,
      authProvider: AUTH_PROVIDERS.APPLE,
    });

    const tokens = generateTokens(user);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          subscriptionType: user.subscriptionType,
        },
        ...tokens,
      },
    });
  } catch (error) {
    logger.error('Apple sign-in error:', error);
    res.status(401).json({
      success: false,
      error: 'Apple authentication failed.',
    });
  }
};

exports.guestAccess = async (req, res) => {
  try {
    const guestId = `guest_${uuidv4()}`;

    const user = await findOrCreateUser(guestId, {
      name: 'Guest User',
      email: '',
      authProvider: AUTH_PROVIDERS.GUEST,
    });

    const tokens = generateTokens(user);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          subscriptionType: user.subscriptionType,
          isGuest: true,
        },
        ...tokens,
      },
    });
  } catch (error) {
    logger.error('Guest access error:', error);
    res.status(500).json({
      success: false,
      error: 'Guest access failed.',
    });
  }
};

exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: 'Refresh token required.',
      });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const userDoc = await db.collection('users').doc(decoded.uid).get();

    if (!userDoc.exists) {
      return res.status(401).json({
        success: false,
        error: 'User not found.',
      });
    }

    const user = { id: userDoc.id, ...userDoc.data() };
    const tokens = generateTokens(user);

    res.json({
      success: true,
      data: tokens,
    });
  } catch (error) {
    logger.error('Token refresh error:', error);
    res.status(401).json({
      success: false,
      error: 'Invalid refresh token.',
    });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const resetLink = await auth.generatePasswordResetLink(email);

    logger.info(`Password reset link generated for ${email}`);

    res.json({
      success: true,
      message: 'Password reset link sent to your email.',
      resetLink,
    });
  } catch (error) {
    logger.error('Forgot password error:', error);
    // Don't reveal if email exists
    res.json({
      success: true,
      message: 'If the email exists, a reset link has been sent.',
    });
  }
};
