const { db, storage } = require('../config/firebase');
const { trackUsage } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');
const { generateCvHtml, htmlToPdf } = require('../services/cvGenerator');
const logger = require('../utils/logger');

exports.getTemplates = async (req, res) => {
  try {
    const templatesSnap = await db.collection('cvTemplates').get();
    const templates = templatesSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      htmlTemplate: undefined, // Don't send template HTML to client
    }));

    res.json({
      success: true,
      data: templates,
    });
  } catch (error) {
    logger.error('Get templates error:', error);
    res.status(500).json({ success: false, error: 'Failed to get templates.' });
  }
};

exports.generateCv = async (req, res) => {
  try {
    const { userDoc } = req;
    const { templateType, personalInfo, education, experience, skills, languages, certifications, references } = req.body;

    // Generate CV HTML
    const html = generateCvHtml(templateType, {
      personalInfo,
      education: education || [],
      experience: experience || [],
      skills: skills || [],
      languages: languages || [],
      certifications: certifications || [],
      references: references || [],
    });

    // Convert to PDF
    const pdfBuffer = await htmlToPdf(html);

    // Upload to Firebase Storage
    const fileName = `cvs/${userDoc.id}/${Date.now()}_${templateType}.pdf`;
    const file = storage.file(fileName);
    await file.save(pdfBuffer, { contentType: 'application/pdf' });

    // Get signed URL (valid for 24 hours)
    const [downloadUrl] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 24 * 60 * 60 * 1000,
    });

    // Track usage
    await trackUsage(userDoc.id, FEATURES.CV_GENERATE, { templateType });

    res.json({
      success: true,
      data: {
        downloadUrl,
        templateType,
        expiresIn: '24 hours',
      },
    });
  } catch (error) {
    logger.error('Generate CV error:', error);
    res.status(500).json({ success: false, error: 'Failed to generate CV.' });
  }
};

exports.downloadCv = async (req, res) => {
  try {
    const { id } = req.params;
    const { userDoc } = req;

    const file = storage.file(`cvs/${userDoc.id}/${id}`);
    const [exists] = await file.exists();

    if (!exists) {
      return res.status(404).json({ success: false, error: 'CV not found.' });
    }

    const [downloadUrl] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 60 * 60 * 1000, // 1 hour
    });

    res.json({
      success: true,
      data: { downloadUrl },
    });
  } catch (error) {
    logger.error('Download CV error:', error);
    res.status(500).json({ success: false, error: 'Failed to download CV.' });
  }
};
