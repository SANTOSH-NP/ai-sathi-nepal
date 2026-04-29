## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }

## Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

## Prevent obfuscation of model classes used by Gson/JSON
-keepattributes Signature
-keepattributes *Annotation*
