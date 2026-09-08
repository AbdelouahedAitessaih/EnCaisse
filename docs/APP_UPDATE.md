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

### Example (force everyone on old builds to take 1.0.10+)

```
minVersionCode: 11
latestVersionCode: 11
forceUpdate: true
message: "Please update EnCaisse for login, receipts, and notifications."
```

`versionCode` is the number after `+` in `pubspec.yaml` (`1.0.10+11` → **11**).

Wait until Play shows **1.0.10 (11)** as available before raising `minVersionCode`.

## How it works

1. **Google Play in-app update** (when available): downloads/installs from Play inside the app (immediate = blocking, flexible = soft).
2. If in-app update is unavailable → opens the Play Store page.
3. You cannot force Play “auto-update” for all users (that’s a user Play setting). Force update in-app is the reliable way.

## Publish rules

After changing `firebase/firestore.rules`, publish them (Console → Firestore → Rules, or `firebase deploy --only firestore:rules`).
