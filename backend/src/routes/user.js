const express = require('express');
const userController = require('../controllers/userController');
const { verifyToken } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validator');

const router = express.Router();

router.use(verifyToken);

router.get('/profile', userController.getProfile);
router.put('/profile', validate(schemas.updateProfile), userController.updateProfile);
router.get('/usage', userController.getUsageHistory);

module.exports = router;
