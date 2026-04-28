import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'AI Sathi Nepal',
      'home': 'Home',
      'tools': 'Tools',
      'profile': 'Profile',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Full Name',
      'sign_in_google': 'Sign in with Google',
      'sign_in_apple': 'Sign in with Apple',
      'guest_mode': 'Continue as Guest',
      'cv_builder': 'CV Builder',
      'qr_scanner': 'QR Scanner',
      'image_to_pdf': 'Image to PDF',
      'ai_tools': 'AI Tools',
      'daily_tools': 'Daily Tools',
      'grammar_check': 'Grammar Check',
      'summarize': 'Summarize',
      'translate': 'Translate',
      'rewrite': 'Rewrite',
      'email_generator': 'Email Generator',
      'caption_generator': 'Caption Generator',
      'job_message': 'Job Application',
      'subscription': 'Subscription',
      'premium': 'Premium',
      'free_plan': 'Free Plan',
      'upgrade': 'Upgrade to Premium',
      'settings': 'Settings',
      'logout': 'Logout',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'download': 'Download',
      'share': 'Share',
      'copy': 'Copy',
      'generate': 'Generate',
      'processing': 'Processing...',
      'usage_limit': 'Usage limit reached. Upgrade to Premium!',
    },
    'ne': {
      'app_name': 'एआई साथी नेपाल',
      'home': 'गृहपृष्ठ',
      'tools': 'उपकरणहरू',
      'profile': 'प्रोफाइल',
      'login': 'लगइन',
      'register': 'दर्ता',
      'email': 'इमेल',
      'password': 'पासवर्ड',
      'name': 'पूरा नाम',
      'sign_in_google': 'गुगलबाट लगइन',
      'sign_in_apple': 'एप्पलबाट लगइन',
      'guest_mode': 'अतिथिको रूपमा जारी राख्नुहोस्',
      'cv_builder': 'सीभी निर्माता',
      'qr_scanner': 'क्यूआर स्क्यानर',
      'image_to_pdf': 'तस्बिरबाट पीडीएफ',
      'ai_tools': 'एआई उपकरणहरू',
      'daily_tools': 'दैनिक उपकरणहरू',
      'grammar_check': 'व्याकरण जाँच',
      'summarize': 'सारांश',
      'translate': 'अनुवाद',
      'rewrite': 'पुनर्लेखन',
      'email_generator': 'इमेल जेनेरेटर',
      'caption_generator': 'क्याप्शन जेनेरेटर',
      'job_message': 'जागिर आवेदन',
      'subscription': 'सदस्यता',
      'premium': 'प्रिमियम',
      'free_plan': 'निःशुल्क योजना',
      'upgrade': 'प्रिमियममा अपग्रेड गर्नुहोस्',
      'settings': 'सेटिङहरू',
      'logout': 'लग आउट',
      'submit': 'पेश गर्नुहोस्',
      'cancel': 'रद्द गर्नुहोस्',
      'save': 'सेभ गर्नुहोस्',
      'download': 'डाउनलोड',
      'share': 'साझा गर्नुहोस्',
      'copy': 'कपि गर्नुहोस्',
      'generate': 'उत्पन्न गर्नुहोस्',
      'processing': 'प्रशोधन भइरहेको छ...',
      'usage_limit': 'प्रयोग सीमा पुग्यो। प्रिमियममा अपग्रेड गर्नुहोस्!',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
