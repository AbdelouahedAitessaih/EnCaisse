# EnCaisse

**EnCaisse, ensemble.** — a shared group cash (“caisse”) app built with Flutter and Firebase.

## Features

- Email/password and Google sign-in
- Create / join groups with invite codes
- Deposits & expenses with categories, receipts, and audit trail
- Live balance derived from movements (never stored)
- Soft-delete with undo window
- Multi-language (EN, FR, AR, ES, PT, ZH, HI, RU, JA)
- Light / dark / system theme

## Stack

- Flutter + Riverpod + go_router
- Firebase Auth, Firestore, Storage, Messaging
- AdMob (banner / interstitial placeholders)

## Getting started

### Prerequisites

- Flutter SDK (see `pubspec.yaml` for SDK constraint)
- Firebase project with Auth, Firestore, Storage enabled
- Android Studio / Xcode for device builds

### Setup

```bash
git clone https://github.com/AbdelouahedAitessaih/EnCaisse.git
cd EnCaisse
flutter pub get
```

1. Place Firebase config files if you regenerate them:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
2. For **Google Sign-In on Android**, add your debug/release **SHA-1** (and SHA-256) in Firebase → Project settings → Your Android app, then download a fresh `google-services.json`.
3. Publish security rules from this repo:
   - Firestore: `firebase/firestore.rules`
   - Storage: `firebase/storage.rules`
4. Run:

```bash
flutter run
```

### Useful commands

```bash
flutter gen-l10n
flutter analyze
flutter test
```

## Project layout

```
lib/
  screens/          UI screens
  services/         Firebase & domain services
  providers/        Riverpod providers
  models/           Data models
  l10n/             ARB + generated localizations
  widgets/          Shared widgets
firebase/
  firestore.rules
  storage.rules
```

## License

Private repository — all rights reserved.
