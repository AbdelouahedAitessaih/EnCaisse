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

### Example (force everyone on old builds to take 1.0.11+)

```
minVersionCode: 12
latestVersionCode: 12
forceUpdate: true
message: "Please update EnCaisse for Google Sign-In and ads."
```

`versionCode` is the number after `+` in `pubspec.yaml` (`1.0.11+12` → **12**).

Wait until Play shows **1.0.11 (12)** as available before raising `minVersionCode`.

## How it works

1. **Google Play in-app update** (when available): downloads/installs from Play inside the app (immediate = blocking, flexible = soft).
2. If in-app update is unavailable → opens the Play Store page.
3. You cannot force Play “auto-update” for all users (that’s a user Play setting). Force update in-app is the reliable way.

## Publish rules

After changing `firebase/firestore.rules`, publish them (Console → Firestore → Rules, or `firebase deploy --only firestore:rules`).
