# Play release — EnCaisse 1.0.13 (version code 14)

## Summary

Product P2 features:
- Email verification after signup
- Who-owes-whom settle + category charts
- CSV / PDF export from group menu
- In-app notification inbox
- Offline banner
- Forced first-launch onboarding
- Soft-delete purge Cloud Function (deploy separately)
- iOS store URL support + AdMob iOS slots ready
- Extra unit tests (balance, settle, soft-delete window)

## AAB

```
c:\Users\abdel\Bureau\EnCaisse\build\app\outputs\bundle\release\app-release.aab
```

Version **1.0.13** / code **14**

## Deploy extras

```
firebase deploy --only functions:default:purgeExpiredSoftDeletes,firestore:indexes --force
```

Set `config/appUpdate.appStoreUrl` when the iOS app is on the App Store.
Create dedicated AdMob **iOS** app/units and replace IDs in `AdMobConfig` + `Info.plist`.

> Note: with `codebase: "default"` in `firebase.json`, filters must be
> `functions:default:FunctionName` (not `functions:FunctionName`).
