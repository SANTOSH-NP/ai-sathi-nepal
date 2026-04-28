const openaiService = require('../services/openai');
const { trackUsage } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');
const logger = require('../utils/logger');

exports.correctGrammar = async (req, res) => {
  try {
    const { text, targetLanguage } = req.body;
    const result = await openaiService.correctGrammar(text, targetLanguage);

    await trackUsage(req.userDoc.id, FEATURES.AI_GRAMMAR, {
      inputLength: text.length,
      outputLength: result.length,
    });

    res.json({
      success: true,
      data: { original: text, corrected: result },
    });
  } catch (error) {
    logger.error('Grammar correction error:', error);
    res.status(500).json({ success: false, error: 'Grammar correction failed.' });
  }
};

exports.summarize = async (req, res) => {
  try {
    const { text, targetLanguage } = req.body;
    const result = await openaiService.summarizeText(text, targetLanguage);

    await trackUsage(req.userDoc.id, FEATURES.AI_SUMMARIZE, {
      inputLength: text.length,
      outputLength: result.length,
    });

    res.json({
      success: true,
      data: { original: text, summary: result },
    });
  } catch (error) {
    logger.error('Summarization error:', error);
    res.status(500).json({ success: false, error: 'Summarization failed.' });
  }
};

exports.translate = async (req, res) => {
  try {
    const { text, targetLanguage } = req.body;
    const result = await openaiService.translateText(text, targetLanguage);

    await trackUsage(req.userDoc.id, FEATURES.AI_TRANSLATE, {
      inputLength: text.length,
      outputLength: result.length,
      targetLanguage,
    });

    res.json({
      success: true,
      data: { original: text, translated: result, targetLanguage },
    });
  } catch (error) {
    logger.error('Translation error:', error);
    res.status(500).json({ success: false, error: 'Translation failed.' });
  }
};

exports.rewrite = async (req, res) => {
  try {
    const { text, targetLanguage } = req.body;
    const result = await openaiService.rewriteText(text, targetLanguage);

    await trackUsage(req.userDoc.id, FEATURES.AI_REWRITE, {
      inputLength: text.length,
      outputLength: result.length,
    });

    res.json({
      success: true,
      data: { original: text, rewritten: result },
    });
  } catch (error) {
    logger.error('Rewrite error:', error);
    res.status(500).json({ success: false, error: 'Rewriting failed.' });
  }
};

exports.generateEmail = async (req, res) => {
  try {
    const result = await openaiService.generateEmail(req.body);

    await trackUsage(req.userDoc.id, FEATURES.EMAIL_GEN, {
      purpose: req.body.purpose,
    });

    res.json({
      success: true,
      data: { email: result },
    });
  } catch (error) {
    logger.error('Email generation error:', error);
    res.status(500).json({ success: false, error: 'Email generation failed.' });
  }
};

exports.generateCaption = async (req, res) => {
  try {
    const result = await openaiService.generateCaption(req.body);

    await trackUsage(req.userDoc.id, FEATURES.CAPTION_GEN, {
      businessType: req.body.businessType,
      platform: req.body.platform,
    });

    res.json({
      success: true,
      data: { caption: result },
    });
  } catch (error) {
    logger.error('Caption generation error:', error);
    res.status(500).json({ success: false, error: 'Caption generation failed.' });
  }
};

exports.generateJobMessage = async (req, res) => {
  try {
    const result = await openaiService.generateJobMessage(req.body);

    await trackUsage(req.userDoc.id, FEATURES.JOB_MESSAGE, {
      jobTitle: req.body.jobTitle,
      type: req.body.type,
    });

    res.json({
      success: true,
      data: { message: result },
    });
  } catch (error) {
    logger.error('Job message generation error:', error);
    res.status(500).json({ success: false, error: 'Job message generation failed.' });
  }
};
