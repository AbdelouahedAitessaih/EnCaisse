# Play release — EnCaisse 1.0.12 (version code 13)

## Why this release

Google Sign-In worked with `flutter run` (debug SHA) but failed on Play
Store installs for some devices (Huawei Y9s). Release Android now uses
Firebase browser OAuth first, which does not depend on Credential Manager.

## What to upload

```
c:\Users\abdel\Bureau\EnCaisse\build\app\outputs\bundle\release\app-release.aab
```

Version name: **1.0.12**  
Version code: **13**

## Release notes — English

```
• Fix Google Sign-In for Play Store installs (including Huawei)
• Google login now uses a secure browser flow on Android release builds
• Production ads on Home and after the 3rd group
```

## Release notes — French

```
• Correction de la connexion Google pour les installs Play Store (dont Huawei)
• Sur Android, la connexion Google utilise un navigateur sécurisé
• Publicités sur l’accueil et après le 3ᵉ groupe
```

## Firebase checklist (required)

Play Console → EnCaisse → **Test and release → App integrity → App signing**

Copy **App signing key certificate**:
- SHA-1
- SHA-256

Paste both in Firebase → Project settings → Android app `com.encaisse.encaisse` → Add fingerprint.

Also add **Upload key certificate** SHA-1 / SHA-256 if not already there.

Then download a fresh `google-services.json` into `android/app/`.

Current Play App Signing SHA-1 in repo: `81d87acb2bbf360e654d96b1a14fd84dd0eb19b6`

## After live

Ask the Huawei user to update to **1.0.12**, then Google Sign-In (browser sheet).

Firestore `config/appUpdate` only when 1.0.12 is available:
- `minVersionCode`: 13
- `latestVersionCode`: 13
- `forceUpdate`: true
