class AppConstants {
  AppConstants._();

  static const String appName = 'AI Sathi Nepal';
  static const String appVersion = '1.0.0';

  // AdMob IDs (replace with production IDs)
  static const String adMobBannerId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String adMobInterstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String adMobRewardedId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  // Subscription product IDs
  static const String premiumMonthlyProductId = 'ai_sathi_premium_monthly';
  static const String premiumYearlyProductId = 'ai_sathi_premium_yearly';

  // Free tier limits
  static const int freeAiCallsPerDay = 5;
  static const int freeCvDownloadsPerMonth = 2;
  static const int freeImageToPdfPerDay = 3;

  // Pricing
  static const int premiumMonthlyPriceNPR = 299;
  static const int premiumYearlyPriceNPR = 2499;
  static const double premiumMonthlyPriceUSD = 2.99;
  static const double premiumYearlyPriceUSD = 24.99;
}
