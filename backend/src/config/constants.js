module.exports = {
  SUBSCRIPTION_TYPES: {
    FREE: 'free',
    PREMIUM_MONTHLY: 'premium_monthly',
    PREMIUM_YEARLY: 'premium_yearly',
  },

  PAYMENT_METHODS: {
    KHALTI: 'khalti',
    ESEWA: 'esewa',
    STRIPE: 'stripe',
    APPLE_IAP: 'apple_iap',
    GOOGLE_PLAY: 'google_play',
  },

  PAYMENT_STATUS: {
    PENDING: 'pending',
    COMPLETED: 'completed',
    FAILED: 'failed',
    REFUNDED: 'refunded',
  },

  AUTH_PROVIDERS: {
    GOOGLE: 'google',
    APPLE: 'apple',
    EMAIL: 'email',
    GUEST: 'guest',
  },

  FEATURES: {
    CV_GENERATE: 'cv_generate',
    QR_SCAN: 'qr_scan',
    IMAGE_TO_PDF: 'image_to_pdf',
    AI_GRAMMAR: 'ai_grammar',
    AI_SUMMARIZE: 'ai_summarize',
    AI_TRANSLATE: 'ai_translate',
    AI_REWRITE: 'ai_rewrite',
    EMAIL_GEN: 'email_gen',
    CAPTION_GEN: 'caption_gen',
    JOB_MESSAGE: 'job_message',
  },

  FREE_LIMITS: {
    AI_CALLS_PER_DAY: parseInt(process.env.FREE_AI_CALLS_PER_DAY || '5', 10),
    CV_DOWNLOADS_PER_MONTH: parseInt(process.env.FREE_CV_DOWNLOADS_PER_MONTH || '2', 10),
    IMAGE_TO_PDF_PER_DAY: parseInt(process.env.FREE_IMAGE_TO_PDF_PER_DAY || '3', 10),
  },

  CV_TYPES: {
    EUROPASS: 'europass',
    ATS: 'ats',
    MODERN: 'modern',
  },

  LANGUAGES: {
    ENGLISH: 'en',
    NEPALI: 'ne',
  },
};
