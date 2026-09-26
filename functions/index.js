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

/**
 * Hard-delete soft-deleted movements after the 24h undo window.
 * Also removes nested audit entries and receipt files when present.
 * Requires Blaze + Cloud Scheduler (enabled on first deploy).
 */
exports.purgeExpiredSoftDeletes = functions
  .region("us-central1")
  .runWith({timeoutSeconds: 540, memory: "256MB"})
  .pubsub.schedule("every 24 hours")
  .timeZone("Etc/UTC")
  .onRun(async () => {
    return purgeExpiredMovements();
  });

/** Manual/HTTP trigger fallback (Cloud Scheduler or curl with auth). */
exports.purgeExpiredSoftDeletesHttp = functions
  .region("us-central1")
  .runWith({timeoutSeconds: 540, memory: "256MB"})
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST" && req.method !== "GET") {
      res.status(405).send("Method not allowed");
      return;
    }
    try {
      const result = await purgeExpiredMovements();
      res.status(200).json({ok: true, purged: result});
    } catch (e) {
      console.error(e);
      res.status(500).json({ok: false, error: String(e.message || e)});
    }
  });

async function purgeExpiredMovements() {
  const cutoff = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000),
  );
  const snap = await admin
    .firestore()
    .collectionGroup("movements")
    .where("deleted", "==", true)
    .where("deletedAt", "<", cutoff)
    .limit(400)
    .get();

  if (snap.empty) {
    console.log("No expired soft-deletes to purge");
    return 0;
  }

  let batch = admin.firestore().batch();
  let ops = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const receiptUrl = data.receiptUrl;
    if (typeof receiptUrl === "string" && receiptUrl.length > 0) {
      try {
        await admin.storage().bucket().file(storagePathFromUrl(receiptUrl)).delete();
      } catch (e) {
        console.warn("Receipt delete skipped", doc.ref.path, e.message);
      }
    }

    const auditSnap = await doc.ref.collection("audit").limit(200).get();
    for (const a of auditSnap.docs) {
      batch.delete(a.ref);
      ops++;
      if (ops >= 400) {
        await batch.commit();
        batch = admin.firestore().batch();
        ops = 0;
      }
    }
    batch.delete(doc.ref);
    ops++;
    if (ops >= 400) {
      await batch.commit();
      batch = admin.firestore().batch();
      ops = 0;
    }
  }
  if (ops > 0) await batch.commit();
  console.log("Purged soft-deleted movements:", snap.size);
  return snap.size;
}

function storagePathFromUrl(url) {
  try {
    const u = new URL(url);
    const marker = "/o/";
    const idx = u.pathname.indexOf(marker);
    if (idx >= 0) {
      return decodeURIComponent(u.pathname.slice(idx + marker.length));
    }
  } catch (_) {}
  return url;
}
