const sharp = require('sharp');
const { PDFDocument } = require('pdf-lib');
const { storage } = require('../config/firebase');
const { trackUsage } = require('../middleware/usageLimiter');
const { FEATURES } = require('../config/constants');
const logger = require('../utils/logger');

exports.imagesToPdf = async (req, res) => {
  try {
    const { images } = req.body; // Array of base64 images
    const { userDoc } = req;

    if (!images?.length) {
      return res.status(400).json({ success: false, error: 'No images provided.' });
    }

    if (images.length > 20) {
      return res.status(400).json({ success: false, error: 'Maximum 20 images allowed.' });
    }

    const pdfDoc = await PDFDocument.create();
    const A4_WIDTH = 595;
    const A4_HEIGHT = 842;

    for (const imageBase64 of images) {
      const imgBuffer = Buffer.from(imageBase64, 'base64');

      // Compress and optimize image
      const optimizedBuffer = await sharp(imgBuffer)
        .resize(A4_WIDTH * 2, A4_HEIGHT * 2, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 85 })
        .toBuffer();

      const metadata = await sharp(optimizedBuffer).metadata();

      let embeddedImage;
      if (metadata.format === 'png') {
        embeddedImage = await pdfDoc.embedPng(optimizedBuffer);
      } else {
        embeddedImage = await pdfDoc.embedJpg(optimizedBuffer);
      }

      const page = pdfDoc.addPage([A4_WIDTH, A4_HEIGHT]);

      // Scale image to fit A4 while maintaining aspect ratio
      const imgAspect = embeddedImage.width / embeddedImage.height;
      const pageAspect = A4_WIDTH / A4_HEIGHT;
      let drawWidth;
      let drawHeight;

      if (imgAspect > pageAspect) {
        drawWidth = A4_WIDTH - 40; // 20px margin each side
        drawHeight = drawWidth / imgAspect;
      } else {
        drawHeight = A4_HEIGHT - 40;
        drawWidth = drawHeight * imgAspect;
      }

      const x = (A4_WIDTH - drawWidth) / 2;
      const y = (A4_HEIGHT - drawHeight) / 2;

      page.drawImage(embeddedImage, { x, y, width: drawWidth, height: drawHeight });
    }

    const pdfBytes = await pdfDoc.save();

    // Upload to storage
    const fileName = `pdfs/${userDoc.id}/${Date.now()}_images.pdf`;
    const file = storage.file(fileName);
    await file.save(Buffer.from(pdfBytes), { contentType: 'application/pdf' });

    const [downloadUrl] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 24 * 60 * 60 * 1000,
    });

    await trackUsage(userDoc.id, FEATURES.IMAGE_TO_PDF, {
      imageCount: images.length,
    });

    res.json({
      success: true,
      data: {
        downloadUrl,
        pageCount: images.length,
        expiresIn: '24 hours',
      },
    });
  } catch (error) {
    logger.error('Image to PDF error:', error);
    res.status(500).json({ success: false, error: 'Failed to convert images to PDF.' });
  }
};
