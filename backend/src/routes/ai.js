const express = require('express');
const aiController = require('../controllers/aiController');
const { verifyToken } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validator');
const { aiRateLimiter } = require('../middleware/rateLimiter');
const { checkUsageLimit } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');

const router = express.Router();

router.use(verifyToken);
router.use(aiRateLimiter);

router.post(
  '/grammar',
  checkUsageLimit(FEATURES.AI_GRAMMAR),
  validate(schemas.aiText),
  aiController.correctGrammar,
);

router.post(
  '/summarize',
  checkUsageLimit(FEATURES.AI_SUMMARIZE),
  validate(schemas.aiText),
  aiController.summarize,
);

router.post(
  '/translate',
  checkUsageLimit(FEATURES.AI_TRANSLATE),
  validate(schemas.aiText),
  aiController.translate,
);

router.post(
  '/rewrite',
  checkUsageLimit(FEATURES.AI_REWRITE),
  validate(schemas.aiText),
  aiController.rewrite,
);

router.post(
  '/email',
  checkUsageLimit(FEATURES.EMAIL_GEN),
  validate(schemas.emailGenerate),
  aiController.generateEmail,
);

router.post(
  '/caption',
  checkUsageLimit(FEATURES.CAPTION_GEN),
  validate(schemas.captionGenerate),
  aiController.generateCaption,
);

router.post(
  '/job-message',
  checkUsageLimit(FEATURES.JOB_MESSAGE),
  validate(schemas.jobMessage),
  aiController.generateJobMessage,
);

module.exports = router;
