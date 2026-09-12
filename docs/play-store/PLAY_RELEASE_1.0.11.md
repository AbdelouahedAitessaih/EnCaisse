# Play release — EnCaisse 1.0.11 (version code 12)

## What to upload

```
c:\Users\abdel\Bureau\EnCaisse\build\app\outputs\bundle\release\app-release.aab
```

Package: `com.encaisse.encaisse`  
Version name: **1.0.11**  
Version code: **12**

## Play Console steps

1. [Play Console](https://play.google.com/console) → **EnCaisse**
2. **Test and release → Production** → **Create new release**
3. Upload `app-release.aab`
4. Paste release notes below (EN + FR)
5. **Review** → **Start rollout to Production**

---

## Release notes — English (What’s new)

```
• Fix Google Sign-In on phones where the system Google sheet fails (including some Huawei devices)
• Google sign-in can fall back to a secure browser login when needed
• Ads on Home (banner) and after creating your 3rd group (full-screen)
• Clearer messages when Google sign-in cannot complete
```

---

## Release notes — French

```
• Correction de la connexion Google (dont certains Huawei)
• Si besoin, connexion Google via navigateur sécurisé
• Publicités : bannière sur l’accueil et plein écran après le 3ᵉ groupe
• Messages plus clairs si Google ne peut pas finaliser
```

---

## After the release is live

Firestore Firestore `config/appUpdate` only when Play shows **1.0.11 (12)** available:

| Field | Value |
|-------|--------|
| `minVersionCode` | `12` |
| `latestVersionCode` | `12` |
| `forceUpdate` | `true` |
| `message` | `Please update EnCaisse for Google Sign-In and ads.` |

Do not raise `minVersionCode` before the update is installable.
