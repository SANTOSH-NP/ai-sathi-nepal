const express = require('express');
const toolsController = require('../controllers/toolsController');
const { verifyToken } = require('../middleware/auth');
const { checkUsageLimit } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');

const router = express.Router();

router.use(verifyToken);

router.post(
  '/image-to-pdf',
  checkUsageLimit(FEATURES.IMAGE_TO_PDF),
  toolsController.imagesToPdf,
);

module.exports = router;
