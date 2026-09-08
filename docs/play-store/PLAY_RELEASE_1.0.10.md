# Play release — EnCaisse 1.0.10 (version code 11)

## What to upload

```
build/app/outputs/bundle/release/app-release.aab
```

Build command (already run for this release):

```bash
flutter build appbundle --release
```

Package: `com.encaisse.encaisse`  
Version name: **1.0.10**  
Version code: **11**

---

## Play Console steps

1. Open [Play Console](https://play.google.com/console) → **EnCaisse**
2. **Test and release → Production** (or Closed testing if you prefer a staged roll-out)
3. **Create new release**
4. Upload `app-release.aab`
5. Paste **Release notes** below (English + French)
6. Review → **Start rollout to Production** (or 20% staged, then 100%)

Privacy policy (unchanged):

```text
https://encaisse-3c7fb.web.app/privacy.html
```

Account deletion (unchanged):

```text
https://encaisse-3c7fb.web.app/delete-account.html
```

---

## Release notes — English (What’s new)

```
• Remember your email and save login with the system password manager
• Show / hide password when signing in
• App language follows your phone (or pick one in Settings)
• Group currency defaults to your country
• More currencies, with names in your language
• Compact pickers that no longer fill the screen
• See receipt photos on movements (list, details, and when adding)
• Background notifications and Google Sign-In fixes
```

---

## Release notes — French

```
• Mémorisation de l’e-mail et enregistrement du mot de passe
• Afficher / masquer le mot de passe à la connexion
• La langue suit le téléphone (ou choix dans Réglages)
• Devise du groupe selon le pays
• Plus de devises, avec le nom dans votre langue
• Sélecteurs compacts (plus de menu plein écran)
• Photos de reçus visibles sur les mouvements
• Notifications en arrière-plan et correction de Google Sign-In
```

---

## After the release is live on Play

In Firestore → `config/appUpdate` set:

| Field | Value |
|-------|--------|
| `minVersionCode` | `11` |
| `latestVersionCode` | `11` |
| `forceUpdate` | `true` |
| `message` | `Please update EnCaisse for login, receipts, and notifications.` |

Wait until Play shows version **1.0.10 (11)** as available before raising `minVersionCode`, or older users will be blocked with no update to install.
