const OpenAI = require('openai');
const logger = require('../utils/logger');

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const SYSTEM_PROMPTS = {
  grammar: `You are a grammar correction assistant. Correct the grammar, spelling, and punctuation of the given text. Return only the corrected text without explanations.`,

  summarize: `You are a text summarization assistant. Summarize the given text concisely while preserving key information. Return only the summary.`,

  translate: `You are a professional translator specializing in Nepali and English. Translate the given text accurately while maintaining the original meaning and tone. Return only the translation.`,

  rewrite: `You are a professional writing assistant. Rewrite the given text to be more professional, clear, and polished. Return only the rewritten text.`,

  email: `You are an email writing assistant. Generate a professional email based on the given parameters. Return only the email content with subject line.`,

  caption: `You are a social media content creator. Generate engaging captions for businesses. Include relevant hashtags. Return only the caption.`,

  jobMessage: `You are a career advisor. Generate professional job application messages. Be concise, impactful, and tailored to the specific role. Return only the message.`,
};

async function correctGrammar(text, targetLanguage = 'en') {
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.grammar },
      { role: 'user', content: `Correct this text (language: ${targetLanguage}):\n\n${text}` },
    ],
    max_tokens: 2000,
    temperature: 0.3,
  });
  return response.choices[0].message.content;
}

async function summarizeText(text, targetLanguage = 'en') {
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.summarize },
      { role: 'user', content: `Summarize this text${targetLanguage === 'ne' ? ' in Nepali' : ''}:\n\n${text}` },
    ],
    max_tokens: 1000,
    temperature: 0.5,
  });
  return response.choices[0].message.content;
}

async function translateText(text, targetLanguage) {
  const langName = targetLanguage === 'ne' ? 'Nepali' : 'English';
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.translate },
      { role: 'user', content: `Translate to ${langName}:\n\n${text}` },
    ],
    max_tokens: 2000,
    temperature: 0.3,
  });
  return response.choices[0].message.content;
}

async function rewriteText(text, targetLanguage = 'en') {
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.rewrite },
      { role: 'user', content: `Rewrite this professionally${targetLanguage === 'ne' ? ' in Nepali' : ''}:\n\n${text}` },
    ],
    max_tokens: 2000,
    temperature: 0.5,
  });
  return response.choices[0].message.content;
}

async function generateEmail({ purpose, tone, recipientName, senderName, keyPoints, language }) {
  const prompt = `Generate a ${tone} email:
Purpose: ${purpose}
${recipientName ? `To: ${recipientName}` : ''}
${senderName ? `From: ${senderName}` : ''}
${keyPoints?.length ? `Key points: ${keyPoints.join(', ')}` : ''}
Language: ${language === 'ne' ? 'Nepali' : 'English'}`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.email },
      { role: 'user', content: prompt },
    ],
    max_tokens: 1500,
    temperature: 0.7,
  });
  return response.choices[0].message.content;
}

async function generateCaption({ businessType, platform, tone, topic, language }) {
  const prompt = `Generate a ${tone} ${platform} caption:
Business: ${businessType}
Topic: ${topic}
Language: ${language === 'ne' ? 'Nepali' : 'English'}`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.caption },
      { role: 'user', content: prompt },
    ],
    max_tokens: 500,
    temperature: 0.8,
  });
  return response.choices[0].message.content;
}

async function generateJobMessage({ jobTitle, companyName, applicantName, keySkills, type, language }) {
  const prompt = `Generate a ${type.replace('_', ' ')}:
Position: ${jobTitle} at ${companyName}
Applicant: ${applicantName}
${keySkills?.length ? `Key Skills: ${keySkills.join(', ')}` : ''}
Language: ${language === 'ne' ? 'Nepali' : 'English'}`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: SYSTEM_PROMPTS.jobMessage },
      { role: 'user', content: prompt },
    ],
    max_tokens: 1500,
    temperature: 0.7,
  });
  return response.choices[0].message.content;
}

module.exports = {
  correctGrammar,
  summarizeText,
  translateText,
  rewriteText,
  generateEmail,
  generateCaption,
  generateJobMessage,
};
