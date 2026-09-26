# App update / force update

EnCaisse checks Firestore `config/appUpdate` on launch.

## Create the config document

Firebase Console → Firestore → collection **`config`** → document **`appUpdate`**:

| Field | Type | Example | Meaning |
|-------|------|---------|---------|
| `minVersionCode` | number | `10` | Below this → **forced** update (app blocked) |
| `latestVersionCode` | number | `10` | Below this → soft “Update available” dialog |
| `forceUpdate` | boolean | `true` | If true, anyone below `latestVersionCode` is forced |
| `message` | string | optional | Custom text on the update screen |
| `playStoreUrl` | string | optional | Defaults to EnCaisse Play listing |
| `appStoreUrl` | string | optional | iOS App Store URL (required for iOS force-update) |

### Example (force everyone on old builds to take 1.0.13+)

```
minVersionCode: 14
latestVersionCode: 14
forceUpdate: true
message: "Please update EnCaisse."
appStoreUrl: "https://apps.apple.com/app/idXXXXXXXX"
```

`versionCode` is the number after `+` in `pubspec.yaml` (`1.0.13+14` → **14**).

Wait until the store shows the target build as available before raising `minVersionCode`.

## How it works

1. **Android:** Google Play in-app update when available; otherwise opens Play Store.
2. **iOS:** Opens `appStoreUrl` (or App Store search for EnCaisse if unset).
3. You cannot force store “auto-update” for all users. In-app force update is the reliable gate.

## Publish rules

After changing `firebase/firestore.rules`, publish them (Console → Firestore → Rules, or `firebase deploy --only firestore:rules`).
