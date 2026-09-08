# Background push notifications (FCM)

## Why notifications stopped when the app was closed

The app used to **only** listen to Firestore while running, then show a **local** notification.  
If EnCaisse was killed / never opened, that listener was dead → **no alerts**.

## Fix

1. The app still writes `users/{uid}/notifications/{id}` (unchanged).
2. Cloud Function **`sendPushOnNotificationCreated`** sends a real **FCM** push to the user's `fcmToken` / `fcmTokens`.
3. Android/iOS show the notification even when the app is closed.

## Deploy (required once)

Cloud Functions need the **Blaze** (pay-as-you-go) plan. FCM + this tiny function stay within free quotas for normal usage.

```bash
firebase login
cd functions
npm install
cd ..
firebase deploy --only functions --project encaisse-3c7fb
```

In Firebase Console → **Build → Functions**, confirm `sendPushOnNotificationCreated` is listed.

## Test

1. User A and User B install the **new** app build and open it once (saves FCM token + creates channel).
2. Force-close EnCaisse on User B's phone.
3. User A adds a deposit/expense in a shared group.
4. User B should get a system notification without opening the app.

## Notes

- User must allow notifications in system settings.
- Each device should open the app at least once after update so `fcmToken` is stored.
