const express = require('express');
const cvController = require('../controllers/cvController');
const { verifyToken } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validator');
const { checkUsageLimit } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');

const router = express.Router();

router.use(verifyToken);

router.get('/templates', cvController.getTemplates);
router.post(
  '/generate',
  checkUsageLimit(FEATURES.CV_GENERATE),
  validate(schemas.generateCv),
  cvController.generateCv,
);
router.get('/download/:id', cvController.downloadCv);

module.exports = router;
