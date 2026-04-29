import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDppQmNyXo1FnuwYZ66Sf4nYtB2ClAfQM8',
    appId: '1:274994178301:android:aa56ead6d8f549b0eab694',
    messagingSenderId: '274994178301',
    projectId: 'ai-sathi-nepal',
    storageBucket: 'ai-sathi-nepal.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYAts4FEzr5c0q7HJAANmZ6dqj6nu28_s',
    appId: '1:274994178301:ios:e679218bff3c0cb3eab694',
    messagingSenderId: '274994178301',
    projectId: 'ai-sathi-nepal',
    storageBucket: 'ai-sathi-nepal.firebasestorage.app',
    iosBundleId: 'com.aisathi.nepal',
  );
}
