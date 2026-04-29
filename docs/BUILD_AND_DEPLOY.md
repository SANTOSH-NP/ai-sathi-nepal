# Build & Deploy Guide - AI Sathi Nepal

## Prerequisites

- Flutter SDK (3.24+)
- Android Studio with Android SDK
- Xcode (for iOS, Mac only)
- Firebase project configured

## Step 1: Place Firebase Config Files

```bash
# Android
cp google-services.json flutter_app/android/app/

# iOS
cp GoogleService-Info.plist flutter_app/ios/Runner/
```

## Step 2: Install Dependencies

```bash
cd flutter_app
flutter pub get
```

## Step 3: Generate Keystore (First Time Only)

```bash
keytool -genkey -v -keystore keystore/ai-sathi-nepal.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ai-sathi-nepal \
  -storepass YOUR_PASSWORD \
  -keypass YOUR_PASSWORD \
  -dname "CN=AI Sathi Nepal, OU=Mobile, O=AI Sathi Nepal, L=Kathmandu, ST=Bagmati, C=NP"
```

Then create `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=ai-sathi-nepal
storeFile=../keystore/ai-sathi-nepal.jks
```

**IMPORTANT: Never commit key.properties or .jks files to git!**

## Step 4: Add SHA-1 to Firebase

Get your keystore SHA-1:
```bash
keytool -list -v -keystore keystore/ai-sathi-nepal.jks -alias ai-sathi-nepal
```

Copy the SHA-1 fingerprint and add it to:
Firebase Console → Project Settings → Your Apps → Android → Add fingerprint

Also add the debug SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

## Step 5: Build Debug APK

```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

## Step 6: Build Release APK

```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Step 7: Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Step 8: Upload to Google Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app → fill in details from `store_listing/PLAY_STORE_LISTING.md`
3. Upload the `.aab` file
4. Add the privacy policy from `store_listing/PRIVACY_POLICY.md`
5. Upload the app icon from `store_listing/icon_1024.png`
6. Take screenshots on different device sizes
7. Set pricing (free with in-app purchases)
8. Submit for review

## Step 9: Backend Deployment

### Option A: Railway/Render (Easiest)
1. Push backend code to GitHub
2. Connect your repo on [Railway](https://railway.app) or [Render](https://render.com)
3. Set environment variables from `.env.example`
4. Deploy

### Option B: Google Cloud Run
```bash
cd backend
gcloud builds submit --tag gcr.io/ai-sathi-nepal/backend
gcloud run deploy ai-sathi-nepal-api --image gcr.io/ai-sathi-nepal/backend --region asia-south1
```

### Option C: Docker
```bash
cd backend
docker build -t ai-sathi-nepal-backend .
docker run -p 3000:3000 --env-file .env ai-sathi-nepal-backend
```

## Step 10: Update API URL

After deploying the backend, update the API URL in:
`flutter_app/lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'https://your-deployed-api-url.com/api/v1';
```

Then rebuild the app.

## AdMob Setup

1. Create an AdMob account at https://admob.google.com
2. Create an app in AdMob
3. Create ad units (Banner, Interstitial, Rewarded)
4. Replace test IDs in `lib/core/constants/app_constants.dart` with real IDs
5. Replace test App ID in `android/app/src/main/AndroidManifest.xml` with your real App ID

## Troubleshooting

### App crashes on launch
- Make sure `google-services.json` is in `android/app/`
- Make sure AdMob App ID is in `AndroidManifest.xml`
- Check `flutter doctor` for missing dependencies

### Google Sign-In not working
- Add SHA-1 fingerprints (both debug and release) to Firebase Console
- Enable Google Sign-In in Firebase Console → Authentication → Sign-in method

### Build fails
- Run `flutter clean && flutter pub get`
- Delete `build/` folder and rebuild
- Make sure Java 17 is installed
