const Joi = require('joi');

const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false, stripUnknown: true });
  if (error) {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      details: error.details.map((d) => d.message),
    });
  }
  next();
};

const schemas = {
  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(8).max(128).required(),
    name: Joi.string().min(2).max(100).required(),
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required(),
  }),

  socialAuth: Joi.object({
    idToken: Joi.string().required(),
  }),

  updateProfile: Joi.object({
    name: Joi.string().min(2).max(100),
    preferredLanguage: Joi.string().valid('en', 'ne'),
    photoUrl: Joi.string().uri(),
  }),

  generateCv: Joi.object({
    templateType: Joi.string().valid('europass', 'ats', 'modern').required(),
    personalInfo: Joi.object({
      fullName: Joi.string().required(),
      email: Joi.string().email().required(),
      phone: Joi.string().required(),
      address: Joi.string(),
      summary: Joi.string().max(500),
      linkedIn: Joi.string().uri().allow(''),
      website: Joi.string().uri().allow(''),
    }).required(),
    education: Joi.array().items(Joi.object({
      institution: Joi.string().required(),
      degree: Joi.string().required(),
      field: Joi.string(),
      startDate: Joi.string().required(),
      endDate: Joi.string().allow(''),
      grade: Joi.string().allow(''),
    })),
    experience: Joi.array().items(Joi.object({
      company: Joi.string().required(),
      position: Joi.string().required(),
      startDate: Joi.string().required(),
      endDate: Joi.string().allow(''),
      description: Joi.string(),
      current: Joi.boolean(),
    })),
    skills: Joi.array().items(Joi.string()),
    languages: Joi.array().items(Joi.object({
      language: Joi.string().required(),
      proficiency: Joi.string().required(),
    })),
    certifications: Joi.array().items(Joi.object({
      name: Joi.string().required(),
      issuer: Joi.string(),
      date: Joi.string(),
    })),
    references: Joi.array().items(Joi.object({
      name: Joi.string().required(),
      position: Joi.string(),
      company: Joi.string(),
      phone: Joi.string(),
      email: Joi.string().email(),
    })),
  }),

  aiText: Joi.object({
    text: Joi.string().min(1).max(5000).required(),
    targetLanguage: Joi.string().valid('en', 'ne'),
  }),

  emailGenerate: Joi.object({
    purpose: Joi.string().required(),
    tone: Joi.string().valid('formal', 'informal', 'professional').default('professional'),
    recipientName: Joi.string(),
    senderName: Joi.string(),
    keyPoints: Joi.array().items(Joi.string()),
    language: Joi.string().valid('en', 'ne').default('en'),
  }),

  captionGenerate: Joi.object({
    businessType: Joi.string().required(),
    platform: Joi.string().valid('facebook', 'instagram', 'linkedin', 'twitter').default('facebook'),
    tone: Joi.string().valid('professional', 'casual', 'witty', 'inspirational').default('professional'),
    topic: Joi.string().required(),
    language: Joi.string().valid('en', 'ne').default('en'),
  }),

  jobMessage: Joi.object({
    jobTitle: Joi.string().required(),
    companyName: Joi.string().required(),
    applicantName: Joi.string().required(),
    keySkills: Joi.array().items(Joi.string()),
    type: Joi.string().valid('cover_letter', 'linkedin_message', 'follow_up').default('cover_letter'),
    language: Joi.string().valid('en', 'ne').default('en'),
  }),

  paymentInit: Joi.object({
    planType: Joi.string().valid('premium_monthly', 'premium_yearly').required(),
    method: Joi.string().valid('khalti', 'esewa', 'stripe').required(),
  }),

  paymentVerify: Joi.object({
    transactionId: Joi.string().required(),
    method: Joi.string().valid('khalti', 'esewa', 'stripe').required(),
    token: Joi.string(),
    amount: Joi.number(),
  }),
};

module.exports = { validate, schemas };
