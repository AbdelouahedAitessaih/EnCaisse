const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * When a doc is written to users/{uid}/notifications/{id}, send an FCM push
 * so the recipient gets it even if the app is killed / in background.
 */
exports.sendPushOnNotificationCreated = functions
  .region("us-central1")
  .firestore.document("users/{uid}/notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const uid = context.params.uid;
    const data = snap.data();
    if (!data) return null;

    const userSnap = await admin.firestore().collection("users").doc(uid).get();
    if (!userSnap.exists) {
      console.warn("No user doc for push", uid);
      return null;
    }

    const user = userSnap.data() || {};
    const tokens = collectTokens(user);
    if (tokens.length === 0) {
      console.log("No FCM token for user", uid);
      return null;
    }

    const title = String(data.title || "EnCaisse");
    const body = String(data.body || "");
    const groupId = data.groupId != null ? String(data.groupId) : "";
    const type = data.type != null ? String(data.type) : "";

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {title, body},
      data: {
        groupId,
        type,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "encaisse_events",
          priority: "high",
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            contentAvailable: true,
          },
        },
      },
    });

    const badTokens = [];
    response.responses.forEach((res, i) => {
      if (res.success) return;
      const code = res.error?.code || "";
      console.warn("FCM send failed", uid, code, res.error?.message);
      if (
        code.includes("registration-token-not-registered") ||
        code.includes("invalid-registration-token")
      ) {
        badTokens.push(tokens[i]);
      }
    });

    if (badTokens.length > 0) {
      await clearBadTokens(uid, user, badTokens);
    }
    return null;
  });

function collectTokens(user) {
  const set = new Set();
  if (typeof user.fcmToken === "string" && user.fcmToken.length > 0) {
    set.add(user.fcmToken);
  }
  if (Array.isArray(user.fcmTokens)) {
    for (const t of user.fcmTokens) {
      if (typeof t === "string" && t.length > 0) set.add(t);
    }
  }
  return [...set];
}

async function clearBadTokens(uid, user, badTokens) {
  const updates = {};
  if (badTokens.includes(user.fcmToken)) {
    updates.fcmToken = null;
  }
  if (Array.isArray(user.fcmTokens)) {
    updates.fcmTokens = user.fcmTokens.filter((t) => !badTokens.includes(t));
  }
  if (Object.keys(updates).length === 0) return;
  await admin.firestore().collection("users").doc(uid).set(updates, {merge: true});
}
