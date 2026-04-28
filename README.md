# AI Sathi Nepal

AI-powered multi-tool mobile application for Nepal users. Built with Flutter (frontend) and Node.js/Express (backend), powered by Firebase and OpenAI.

## Features

- **CV/Resume Generator** - Europass, ATS-friendly, and Modern templates with PDF export
- **QR Code Scanner** - Scan URLs, text, WiFi, contacts with smart action suggestions
- **Image to PDF Converter** - Multi-image upload with A4 PDF generation and compression
- **AI Text Tools** - Grammar correction, summarization, translation (Nepali/English), professional rewriting
- **Smart Daily Tools** - Email generator, business caption generator, job application messages
- **Bilingual Support** - Full Nepali and English language support

## Tech Stack

### Frontend (Flutter)
- Flutter 3.x with Dart
- Riverpod for state management
- GoRouter for navigation
- Dio for networking
- Firebase SDK (Auth, Firestore, Storage, Crashlytics, Analytics)
- Google AdMob for monetization

### Backend (Node.js)
- Express.js API server
- Firebase Admin SDK
- OpenAI GPT-4o-mini for AI features
- JWT authentication with refresh tokens
- Rate limiting and usage quotas
- Input validation with Joi

### Payment Integrations
- Khalti (Nepal)
- eSewa (Nepal)
- Stripe (International)
- Apple In-App Purchase (iOS)
- Google Play Billing (Android)

## Project Structure

```
ai-sathi-nepal/
├── docs/
│   ├── ARCHITECTURE.md          # System architecture & diagrams
│   └── DEPLOYMENT_CHECKLIST.md  # Store deployment checklist
├── backend/
│   ├── src/
│   │   ├── config/              # Firebase, constants
│   │   ├── controllers/         # Route handlers
│   │   ├── middleware/           # Auth, rate limiting, validation
│   │   ├── models/              # Data models
│   │   ├── routes/              # API routes
│   │   ├── services/            # Business logic (OpenAI, payment, CV)
│   │   ├── utils/               # Logger, helpers
│   │   └── index.js             # Entry point
│   ├── firestore.rules          # Firebase security rules
│   ├── Dockerfile               # Production Docker image
│   └── package.json
└── flutter_app/
    ├── lib/
    │   ├── app/                 # App entry, MaterialApp
    │   ├── core/
    │   │   ├── constants/       # API & app constants
    │   │   ├── l10n/            # Localization (EN/NE)
    │   │   ├── models/          # Data models
    │   │   ├── network/         # Dio client, interceptors
    │   │   ├── router/          # GoRouter configuration
    │   │   └── theme/           # Colors, theme data
    │   └── features/
    │       ├── auth/            # Login, register, providers
    │       ├── home/            # Dashboard, feature cards
    │       ├── cv/              # CV builder, preview
    │       ├── qr/              # QR scanner
    │       ├── pdf/             # Image to PDF
    │       ├── ai_tools/        # Grammar, translate, summarize, rewrite
    │       ├── daily_tools/     # Email, caption, job message
    │       ├── profile/         # User profile
    │       ├── subscription/    # Premium plans, payment
    │       ├── splash/          # Splash screen
    │       └── settings/        # Language, preferences
    └── pubspec.yaml
```

## Getting Started

### Prerequisites
- Node.js 18+
- Flutter 3.x
- Firebase project with Auth, Firestore, and Storage enabled
- OpenAI API key

### Backend Setup

```bash
cd backend
cp .env.example .env
# Fill in your environment variables
npm install
npm run dev
```

### Flutter Setup

```bash
cd flutter_app

# Configure Firebase
flutterfire configure

# Install dependencies
flutter pub get

# Run code generators
flutter pub run build_runner build

# Run the app
flutter run
```

## Subscription Plans

| Plan | Price (NPR) | Price (USD) | Features |
|------|------------|-------------|----------|
| Free | 0 | 0 | 5 AI calls/day, 2 CV downloads/month, Ads |
| Premium Monthly | 299 | $2.99 | Unlimited AI, Unlimited CV, No ads |
| Premium Yearly | 2,499 | $24.99 | Everything in monthly + priority support |

## API Documentation

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for complete API endpoint documentation, database schema, authentication flow, and payment integration flow.

## Security

- JWT-based authentication with short-lived tokens (15 min) and refresh tokens (7 days)
- Server-side payment verification for all payment methods
- Rate limiting per user, per IP, and per endpoint
- Input validation and sanitization on all endpoints
- Firebase security rules for database access control
- API keys stored server-side only

## License

Proprietary - All rights reserved.
