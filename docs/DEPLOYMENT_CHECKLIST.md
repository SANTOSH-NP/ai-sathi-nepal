# AI Sathi Nepal - Deployment Checklist

## Pre-Deployment

### Backend
- [ ] All environment variables configured in production
- [ ] Firebase Admin SDK service account key secured
- [ ] OpenAI API key configured with spending limits
- [ ] Payment gateway credentials (Khalti, eSewa, Stripe) verified
- [ ] CORS origins set to production domains only
- [ ] Rate limiting configured for production load
- [ ] Logging configured (structured JSON logs)
- [ ] Error tracking (Sentry) configured
- [ ] Health check endpoint (`/health`) working
- [ ] Database indexes created in Firestore
- [ ] Firebase security rules deployed and tested
- [ ] SSL/TLS certificates configured
- [ ] API documentation generated (Swagger/OpenAPI)

### Flutter App
- [ ] Production Firebase config files in place
  - `google-services.json` (Android)
  - `GoogleService-Info.plist` (iOS)
- [ ] API base URL pointing to production server
- [ ] AdMob ad unit IDs set to production IDs
- [ ] App signing keys generated and secured
- [ ] App icons and splash screen finalized
- [ ] All debug flags disabled
- [ ] ProGuard/R8 rules configured (Android)
- [ ] App version and build number updated
- [ ] Deep linking configured

## Google Play Store

### Build
- [ ] Generate signed AAB (Android App Bundle)
- [ ] Test on multiple device sizes (phone + tablet)
- [ ] Test on Android API 24+ (minimum)
- [ ] Run `flutter build appbundle --release`

### Store Listing
- [ ] App title: "AI Sathi Nepal"
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] Feature graphic (1024x500 px)
- [ ] App icon (512x512 px)
- [ ] Screenshots (min 2, phone + tablet)
- [ ] Category: Tools / Productivity
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL hosted and linked
- [ ] Terms of service URL hosted and linked

### Compliance
- [ ] Data safety section filled out
- [ ] Ads declaration (contains ads for free version)
- [ ] In-app purchase products created
- [ ] Target audience and content configured
- [ ] App review submitted

## Apple App Store

### Build
- [ ] Generate IPA via Xcode
- [ ] Test on iPhone and iPad
- [ ] Minimum iOS version: 14.0
- [ ] Run `flutter build ipa --release`
- [ ] Upload via Transporter or Xcode

### Store Listing
- [ ] App name: "AI Sathi Nepal"
- [ ] Subtitle (30 chars max)
- [ ] Description
- [ ] Keywords (100 chars max)
- [ ] Screenshots (6.7", 6.5", 5.5" displays)
- [ ] App icon (1024x1024 px, no alpha)
- [ ] Category: Productivity
- [ ] Privacy policy URL
- [ ] Support URL

### Compliance
- [ ] Apple Sign-In implemented (required if other social logins exist)
- [ ] In-App Purchase products created in App Store Connect
- [ ] App Privacy labels filled out
- [ ] Export compliance information provided
- [ ] App Review guidelines checked

## Post-Deployment

- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Monitor API performance and error rates
- [ ] Monitor payment success rates
- [ ] Set up alerting for critical errors
- [ ] Plan first update cycle (bug fixes + feature requests)
- [ ] Respond to user reviews within 24 hours
- [ ] Track key metrics:
  - DAU/MAU
  - Conversion rate (free → premium)
  - Payment success rate
  - AI feature usage
  - Crash-free rate (target: 99.5%+)

## Subscription Plans

| Plan | Price (NPR) | Price (USD) | Features |
|------|------------|-------------|----------|
| Free | 0 | 0 | 5 AI calls/day, 2 CV downloads/month, Ads enabled |
| Premium Monthly | 299 | $2.99 | Unlimited AI, Unlimited CV, No ads |
| Premium Yearly | 2,499 | $24.99 | Unlimited AI, Unlimited CV, No ads, Priority support |
