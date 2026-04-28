const express = require('express');
const authController = require('../controllers/authController');
const { validate, schemas } = require('../middleware/validator');
const { authRateLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

router.use(authRateLimiter);

router.post('/register', validate(schemas.register), authController.register);
router.post('/login', validate(schemas.login), authController.login);
router.post('/google', validate(schemas.socialAuth), authController.googleSignIn);
router.post('/apple', validate(schemas.socialAuth), authController.appleSignIn);
router.post('/guest', authController.guestAccess);
router.post('/refresh', authController.refreshToken);
router.post('/forgot-password', authController.forgotPassword);

module.exports = router;
