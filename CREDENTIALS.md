# EnCaisse credentials setup (do this before running on a device)

## Firebase (required)

1. Create a project at https://console.firebase.google.com named e.g. `encaisse`.
2. Enable **Authentication** → Email/Password and Google.
3. Create a **Cloud Firestore** database (production mode), then publish rules:

   **Easiest (Firebase Console — no CLI):**
   1. Open Firestore → **Rules**
   2. Delete everything in the editor
   3. Paste the full contents of `firebase/firestore.rules`
   4. Click **Publish**

   **Optional (CLI):**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase use encaisse
   firebase deploy --only firestore:rules
   ```
4. Add an **Android** app with package name `com.encaisse.encaisse`.
5. Add an **iOS** app with bundle id `com.encaisse.encaisse`.
6. Download and place:
   - `android/app/google-services.json` (replace the `.PLACEHOLDER` sibling)
   - `ios/Runner/GoogleService-Info.plist` (replace the `.PLACEHOLDER` sibling)
7. Run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` with real values.
8. In `android/app/build.gradle.kts`, uncomment:
   ```kotlin
   id("com.google.gms.google-services")
   ```
9. Deploy indexes: `firebase deploy --only firestore:indexes` (from `firebase/`).

## AdMob (required before Play release)

Right now the app uses **Google sample/test IDs** (`ca-app-pub-3940256099942544...`).  
Those work for development. Before you publish on Play Store, swap them for **your** AdMob IDs.

### What you need from AdMob (2 kinds of IDs)

| Kind | Looks like | Used for |
|------|------------|----------|
| **App ID** | `ca-app-pub-XXXXXXXX~YYYYYYYY` (tilde `~`) | Registers the app with AdMob (manifest / Info.plist) |
| **Ad unit ID** | `ca-app-pub-XXXXXXXX/ZZZZZZZZ` (slash `/`) | Each ad placement (banner, interstitial) |

### Step A — Create the app + ad units in AdMob

1. Open https://admob.google.com → sign in.
2. **Apps** → **Add app**
   - Platform: **Android**
   - App name: `EnCaisse`
   - Package name: `com.encaisse.encaisse`
   - Copy the **App ID** (has `~`).
3. (If you ship iOS later) Add an **iOS** app with bundle `com.encaisse.encaisse` and copy its App ID too.
4. Open your Android app → **Ad units** → **Add ad unit**:
   - Create a **Banner** → name it e.g. `Home banner` → copy its Ad unit ID (has `/`).
   - Create an **Interstitial** → name it e.g. `After 3rd group` → copy its Ad unit ID.
5. Repeat ad units for iOS if you have an iOS app in AdMob.

### Step B — Paste IDs into the project

**1. App IDs (manifest / plist)**

- Android → open `android/app/src/main/AndroidManifest.xml`  
  Find:
  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-3940256099942544~3347511713"/>
  ```
  Replace `android:value="..."` with **your Android App ID** (`~`).

- iOS → open `ios/Runner/Info.plist`  
  Find `GADApplicationIdentifier` and replace the string with **your iOS App ID** (`~`).

**2. Ad unit IDs (Dart)**

Open `lib/core/constants/app_constants.dart` and replace every `// TEST` value in `AdMobConfig`:

| Field | Paste this from AdMob |
|-------|------------------------|
| `androidAppId` | Android App ID (`~`) |
| `iosAppId` | iOS App ID (`~`) |
| `bannerAdUnitIdAndroid` | Android Banner ad unit (`/`) |
| `bannerAdUnitIdIos` | iOS Banner ad unit (`/`) |
| `interstitialAdUnitIdAndroid` | Android Interstitial ad unit (`/`) |
| `interstitialAdUnitIdIos` | iOS Interstitial ad unit (`/`) |

### Where ads appear in EnCaisse

- **Banner** → Home screen only (list of groups).
- **Interstitial** → only after the user creates their **3rd** group.

### Tip

Keep test IDs while developing (avoids policy risk). Switch to your real IDs only for release builds / Play upload.

When you have the 6 IDs ready, paste them here in chat and they can be filled into the files for you.

## Google Sign-In

- Android: SHA-1 (and SHA-256) of each debug/release keystore must be added in Firebase Console → Project settings → Your Android app, then download a fresh `google-services.json` into the repo once.
- Registered debug fingerprints (add any new PC’s SHA the same way; no need for a separate json per machine):
  - SHA-1: `A7:EA:41:4E:DD:68:E0:97:1F:FB:FF:38:AF:B5:D6:6B:2F:81:CA:8A`
  - SHA-256: `6F:8B:04:8B:95:71:A6:46:3E:E0:53:AD:91:12:39:28:C6:E3:55:3A:A6:D9:F5:56:5F:C2:C2:A7:1F:5D:31:AF`
  - Other PC SHA-1: `23:EA:A2:C7:81:93:22:1E:2C:94:F7:55:E1:6A:D4:54:E4:D5:73:5A`
- Missing or mismatched SHA usually surfaces as `[16] Account reauth failed` / fake “canceled” from Credential Manager.
- iOS: URL scheme from `REVERSED_CLIENT_ID` in GoogleService-Info.plist must be in Xcode.
