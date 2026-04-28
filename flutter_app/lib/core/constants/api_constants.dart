class ApiConstants {
  ApiConstants._();

  // Change this to your production URL
  static const String baseUrl = 'https://api.aisathinepal.com/api/v1';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String guestAuth = '/auth/guest';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';

  // User
  static const String profile = '/user/profile';
  static const String usage = '/user/usage';

  // CV
  static const String cvTemplates = '/cv/templates';
  static const String cvGenerate = '/cv/generate';
  static const String cvDownload = '/cv/download';

  // AI Tools
  static const String aiGrammar = '/ai/grammar';
  static const String aiSummarize = '/ai/summarize';
  static const String aiTranslate = '/ai/translate';
  static const String aiRewrite = '/ai/rewrite';
  static const String aiEmail = '/ai/email';
  static const String aiCaption = '/ai/caption';
  static const String aiJobMessage = '/ai/job-message';

  // Payment
  static const String paymentInit = '/payment/init';
  static const String khaltiVerify = '/payment/khalti/verify';
  static const String esewaVerify = '/payment/esewa/verify';
  static const String verifyReceipt = '/payment/verify-receipt';
  static const String paymentHistory = '/payment/history';

  // Tools
  static const String imageToPdf = '/tools/image-to-pdf';
}
