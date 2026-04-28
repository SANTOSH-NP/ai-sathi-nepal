# AI Sathi Nepal - System Architecture

## 1. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐   │
│  │  Flutter App   │  │  Flutter App   │  │   Flutter Web (PWA)   │  │
│  │  (Android)     │  │  (iOS)         │  │   (Future)            │  │
│  └───────┬───────┘  └───────┬───────┘  └──────────┬────────────┘  │
│          │                  │                      │               │
│          └──────────────────┼──────────────────────┘               │
│                             │                                      │
│                      ┌──────▼──────┐                               │
│                      │  API Client  │                               │
│                      │  (Dio/HTTP)  │                               │
│                      └──────┬──────┘                               │
└─────────────────────────────┼───────────────────────────────────────┘
                              │ HTTPS (TLS 1.3)
                              │
┌─────────────────────────────┼───────────────────────────────────────┐
│                      API GATEWAY / CDN                              │
│                    ┌────────▼────────┐                              │
│                    │  Cloudflare CDN  │                              │
│                    │  + WAF + DDoS    │                              │
│                    └────────┬────────┘                              │
└─────────────────────────────┼───────────────────────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────────────┐
│                     BACKEND LAYER                                   │
│                                                                     │
│  ┌──────────────────────────▼──────────────────────────────────┐   │
│  │              Node.js / Express API Server                    │   │
│  │                                                              │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │   │
│  │  │  Auth    │ │  CV Gen  │ │ AI Tools │ │ Payment  │       │   │
│  │  │ Controller│ │Controller│ │Controller│ │Controller│       │   │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │   │
│  │       │             │            │             │              │   │
│  │  ┌────▼─────────────▼────────────▼─────────────▼──────┐      │   │
│  │  │              SERVICE LAYER                          │      │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐           │      │   │
│  │  │  │ Firebase  │ │ OpenAI   │ │ Payment  │           │      │   │
│  │  │  │ Service   │ │ Service  │ │ Service  │           │      │   │
│  │  │  └──────────┘ └──────────┘ └──────────┘           │      │   │
│  │  └────────────────────────────────────────────────────┘      │   │
│  │                                                              │   │
│  │  MIDDLEWARE: Rate Limiter │ Auth Guard │ Validator │ Logger  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐                        │
│  │ Cloud Functions   │  │  Cloud Storage    │                        │
│  │ (Firebase)        │  │  (PDFs, Images)   │                        │
│  └──────────────────┘  └──────────────────┘                        │
└─────────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────────────┐
│                     DATA LAYER                                      │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │  Firestore    │  │  Firebase     │  │  Redis (Cache)           │  │
│  │  (NoSQL DB)   │  │  Auth         │  │  Rate Limiting + Cache   │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────────────┐
│                 EXTERNAL SERVICES                                   │
│                                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │  OpenAI  │ │  Khalti  │ │  eSewa   │ │  Stripe  │ │ AdMob   │ │
│  │  API     │ │  API     │ │  API     │ │  API     │ │ SDK     │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. Authentication Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│  Client  │     │  Firebase    │     │   Backend    │     │ Firestore│
│  (App)   │     │  Auth        │     │   API        │     │          │
└────┬─────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                   │
     │ 1. Login Request │                    │                   │
     │ (Google/Apple/   │                    │                   │
     │  Email)          │                    │                   │
     ├─────────────────►│                    │                   │
     │                  │                    │                   │
     │ 2. Firebase Token│                    │                   │
     │◄─────────────────┤                    │                   │
     │                  │                    │                   │
     │ 3. Send Firebase Token               │                   │
     ├──────────────────────────────────────►│                   │
     │                  │                    │                   │
     │                  │ 4. Verify Token    │                   │
     │                  │◄───────────────────┤                   │
     │                  │                    │                   │
     │                  │ 5. Token Valid     │                   │
     │                  ├───────────────────►│                   │
     │                  │                    │                   │
     │                  │                    │ 6. Create/Update  │
     │                  │                    │    User Profile   │
     │                  │                    ├──────────────────►│
     │                  │                    │                   │
     │                  │                    │ 7. User Data      │
     │                  │                    │◄──────────────────┤
     │                  │                    │                   │
     │ 8. JWT Token + User Data             │                   │
     │◄─────────────────────────────────────┤                   │
     │                  │                    │                   │
```

## 3. Payment Integration Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
│  Client  │     │   Payment    │     │   Backend    │     │ Firestore│
│  (App)   │     │   Gateway    │     │   API        │     │          │
└────┬─────┘     └──────┬───────┘     └──────┬───────┘     └────┬─────┘
     │                  │                    │                   │
     │ 1. Select Plan   │                    │                   │
     ├──────────────────────────────────────►│                   │
     │                  │                    │                   │
     │ 2. Init Payment  │                    │                   │
     │◄─────────────────────────────────────┤                   │
     │                  │                    │                   │
     │ 3. Pay via       │                    │                   │
     │    Khalti/eSewa/ │                    │                   │
     │    Stripe        │                    │                   │
     ├─────────────────►│                    │                   │
     │                  │                    │                   │
     │ 4. Payment Token │                    │                   │
     │◄─────────────────┤                    │                   │
     │                  │                    │                   │
     │ 5. Verify Payment                    │                   │
     ├──────────────────────────────────────►│                   │
     │                  │                    │                   │
     │                  │ 6. Server-Side     │                   │
     │                  │    Verification    │                   │
     │                  │◄───────────────────┤                   │
     │                  │                    │                   │
     │                  │ 7. Confirmed       │                   │
     │                  ├───────────────────►│                   │
     │                  │                    │                   │
     │                  │                    │ 8. Update Sub     │
     │                  │                    ├──────────────────►│
     │                  │                    │                   │
     │ 9. Subscription Activated            │                   │
     │◄─────────────────────────────────────┤                   │
     │                  │                    │                   │
```

## 4. Database Schema (Firestore)

### Collections

```
├── users/
│   └── {userId}
│       ├── id: string
│       ├── name: string
│       ├── email: string
│       ├── photoUrl: string?
│       ├── authProvider: "google" | "apple" | "email" | "guest"
│       ├── subscriptionType: "free" | "premium_monthly" | "premium_yearly"
│       ├── subscriptionExpiry: timestamp?
│       ├── usageLimits: {
│       │   ├── aiCalls: number (daily limit)
│       │   ├── cvDownloads: number (monthly limit)
│       │   └── imageToPdf: number (daily limit)
│       │   }
│       ├── preferredLanguage: "en" | "ne"
│       ├── deviceIds: string[]
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── payments/
│   └── {paymentId}
│       ├── userId: string
│       ├── amount: number
│       ├── currency: "NPR" | "USD"
│       ├── method: "khalti" | "esewa" | "stripe" | "apple_iap" | "google_play"
│       ├── status: "pending" | "completed" | "failed" | "refunded"
│       ├── transactionId: string
│       ├── planType: "premium_monthly" | "premium_yearly"
│       ├── metadata: map
│       ├── createdAt: timestamp
│       └── verifiedAt: timestamp?
│
├── usage/
│   └── {usageId}
│       ├── userId: string
│       ├── featureUsed: "cv_generate" | "qr_scan" | "image_to_pdf" |
│       │                "ai_grammar" | "ai_summarize" | "ai_translate" |
│       │                "ai_rewrite" | "email_gen" | "caption_gen"
│       ├── inputTokens: number?
│       ├── outputTokens: number?
│       ├── timestamp: timestamp
│       └── sessionId: string
│
├── cvTemplates/
│   └── {templateId}
│       ├── name: string
│       ├── type: "europass" | "ats" | "modern"
│       ├── htmlTemplate: string
│       ├── isPremium: boolean
│       └── thumbnailUrl: string
│
└── appConfig/
    └── settings
        ├── freeAiCallsPerDay: number
        ├── freeCvDownloadsPerMonth: number
        ├── freeImageToPdfPerDay: number
        ├── premiumMonthlyPriceNPR: number
        ├── premiumYearlyPriceNPR: number
        ├── premiumMonthlyPriceUSD: number
        ├── premiumYearlyPriceUSD: number
        ├── maintenanceMode: boolean
        └── minimumAppVersion: string
```

## 5. API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/register` | No | Email registration |
| POST | `/api/v1/auth/login` | No | Email login |
| POST | `/api/v1/auth/google` | No | Google Sign-In |
| POST | `/api/v1/auth/apple` | No | Apple Sign-In |
| POST | `/api/v1/auth/guest` | No | Guest access |
| POST | `/api/v1/auth/refresh` | Yes | Refresh JWT token |
| POST | `/api/v1/auth/forgot-password` | No | Password reset email |
| GET | `/api/v1/user/profile` | Yes | Get user profile |
| PUT | `/api/v1/user/profile` | Yes | Update profile |
| GET | `/api/v1/user/usage` | Yes | Get usage stats |
| POST | `/api/v1/cv/generate` | Yes | Generate CV |
| GET | `/api/v1/cv/templates` | Yes | List CV templates |
| GET | `/api/v1/cv/download/:id` | Yes | Download CV PDF |
| POST | `/api/v1/ai/grammar` | Yes | Grammar correction |
| POST | `/api/v1/ai/summarize` | Yes | Text summarization |
| POST | `/api/v1/ai/translate` | Yes | Translation |
| POST | `/api/v1/ai/rewrite` | Yes | Professional rewriting |
| POST | `/api/v1/ai/email` | Yes | Email generation |
| POST | `/api/v1/ai/caption` | Yes | Caption generation |
| POST | `/api/v1/ai/job-message` | Yes | Job application message |
| POST | `/api/v1/payment/khalti/init` | Yes | Initialize Khalti payment |
| POST | `/api/v1/payment/khalti/verify` | Yes | Verify Khalti payment |
| POST | `/api/v1/payment/esewa/init` | Yes | Initialize eSewa payment |
| POST | `/api/v1/payment/esewa/verify` | Yes | Verify eSewa payment |
| POST | `/api/v1/payment/stripe/create-intent` | Yes | Create Stripe payment intent |
| POST | `/api/v1/payment/stripe/webhook` | No | Stripe webhook |
| POST | `/api/v1/payment/verify-receipt` | Yes | Verify IAP receipt |
| GET | `/api/v1/payment/history` | Yes | Payment history |
| POST | `/api/v1/tools/image-to-pdf` | Yes | Convert images to PDF |

## 6. Security Best Practices

1. **API Key Protection**: All API keys stored server-side only, never in client code
2. **JWT Tokens**: Short-lived access tokens (15 min) + long-lived refresh tokens (7 days)
3. **Rate Limiting**: Per-user, per-IP, and per-endpoint rate limiting
4. **Input Validation**: Joi/Zod schema validation on all inputs
5. **CORS**: Strict origin whitelist
6. **Helmet.js**: Security headers on all responses
7. **Firebase Rules**: Strict read/write rules per collection
8. **Anti-Abuse**: AI usage quotas, device fingerprinting, anomaly detection
9. **Payment Security**: Server-side verification only, no client-side trust
10. **Data Encryption**: AES-256 for sensitive data at rest

## 7. Scalability Plan

- **Horizontal scaling**: Deploy behind load balancer (Cloud Run / ECS)
- **Database**: Firestore auto-scales, add composite indexes for complex queries
- **Caching**: Redis for API responses, user sessions, rate limiting
- **CDN**: Cloudflare for static assets (CV templates, images)
- **Queue**: Bull/BullMQ for async PDF generation and AI processing
- **Monitoring**: Firebase Crashlytics + Cloud Monitoring + Sentry
