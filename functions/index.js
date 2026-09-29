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
    const type = data.type != null ? String(data.type) : "";
    if (type.startsWith("engagement_") && user.remindersEnabled === false) return null;
    if (!type.startsWith("engagement_") && !type.startsWith("settlement_") &&
        user.activityNotificationsEnabled === false) return null;
    const tokens = collectTokens(user);
    if (tokens.length === 0) {
      console.log("No FCM token for user", uid);
      return null;
    }

    const title = String(data.title || "EnCaisse");
    const body = String(data.body || "");
    const groupId = data.groupId != null ? String(data.groupId) : "";

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

    const groupRef = doc.ref.parent.parent;
    if (groupRef) {
      await deleteQueryInBatches(
        groupRef.collection("audit").where("movementId", "==", doc.id),
      );
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
  if (url.startsWith("storage://")) return url.slice("storage://".length);
  try {
    const u = new URL(url);
    const marker = "/o/";
    const idx = u.pathname.indexOf(marker);
    if (u.host === "firebasestorage.googleapis.com" && idx >= 0) {
      return decodeURIComponent(u.pathname.slice(idx + marker.length));
    }
  } catch (_) {}
  return "";
}

function receiptReference(value, groupId) {
  const url = inputString(value, "Receipt URL", 2048, false);
  if (!url) return null;
  const path = storagePathFromUrl(url);
  if (!new RegExp(`^groups/${groupId}/receipts/[A-Za-z0-9_-]+\\.jpg$`).test(path)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Receipt must belong to this group.",
    );
  }
  return url;
}

const crypto = require("crypto");
const db = admin.firestore();
const supportedCurrencies = new Set([
  "USD", "GBP", "EUR", "CHF", "CAD", "MAD", "AED", "SAR", "EGP",
  "TND", "DZD", "MXN", "ARS", "COP", "CLP", "BRL", "CNY", "HKD",
  "TWD", "INR", "RUB", "JPY",
]);
const zeroDecimalCurrencies = new Set(["JPY", "CLP"]);
const inviteAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function requireAuth(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
  }
  return context.auth.uid;
}

function inputString(value, field, maxLength, required = true) {
  if (value == null && !required) return null;
  if (typeof value !== "string") {
    throw new functions.https.HttpsError("invalid-argument", `${field} is invalid.`);
  }
  const result = value.trim();
  if ((required && result.length === 0) || result.length > maxLength) {
    throw new functions.https.HttpsError("invalid-argument", `${field} is invalid.`);
  }
  return result || null;
}

function amountInMinorUnits(value, currency) {
  const amount = Number(value);
  const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
  const factor = 10 ** digits;
  const minor = Math.round(amount * factor);
  if (!Number.isFinite(amount) || amount <= 0 || amount > 1e9 ||
      Math.abs(amount * factor - minor) > 1e-6 || !Number.isSafeInteger(minor)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Amount must be positive and use the currency's supported precision.",
    );
  }
  return minor;
}

function signedMinor(data, currency) {
  const amount = amountInMinorUnits(data.amount, currency);
  if (data.type !== "deposit" && data.type !== "expense") {
    throw new functions.https.HttpsError("invalid-argument", "Movement type is invalid.");
  }
  return data.type === "expense" ? -amount : amount;
}

function movementSnapshot(data) {
  return {
    type: data.type,
    amount: data.amount,
    title: data.title,
    category: data.category,
    createdBy: data.createdBy,
    createdByName: data.createdByName,
    receiptUrl: data.receiptUrl || null,
    deleted: data.deleted === true,
    isStartingBalance: data.isStartingBalance === true,
  };
}

async function balanceMinorInTransaction(transaction, groupRef, groupData) {
  if (Number.isSafeInteger(groupData.balanceMinorUnits)) {
    return groupData.balanceMinorUnits;
  }
  // One-time migration for groups created before server-side balance tracking.
  const movements = await transaction.get(groupRef.collection("movements"));
  const digits = zeroDecimalCurrencies.has(groupData.currency) ? 0 : 2;
  const factor = 10 ** digits;
  return movements.docs.reduce((total, doc) => {
    const movement = doc.data();
    if (movement.deleted === true) return total;
    const amount = Math.round(Number(movement.amount || 0) * factor);
    return total + (movement.type === "expense" ? -amount : amount);
  }, 0);
}

function callableGroup(groupId, data) {
  return {
    id: groupId,
    name: data.name,
    createdBy: data.createdBy,
    createdAtMillis: data.createdAt.toMillis(),
    inviteCode: data.inviteCode,
    currency: data.currency,
    photoUrl: data.photoUrl || null,
    isPersonal: data.isPersonal === true,
  };
}

function newInviteCode() {
  const bytes = crypto.randomBytes(6);
  return [...bytes].map((byte) => inviteAlphabet[byte % inviteAlphabet.length]).join("");
}

exports.createGroup = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const name = inputString(data.name, "Group name", 60);
  if (name.length < 2) {
    throw new functions.https.HttpsError("invalid-argument", "Group name is too short.");
  }
  const displayName = inputString(data.displayName, "Display name", 80, false) || "Member";
  const photoUrl = inputString(data.photoUrl, "Photo URL", 2048, false);
  const currency = inputString(data.currency, "Currency", 3);
  if (!supportedCurrencies.has(currency)) {
    throw new functions.https.HttpsError("invalid-argument", "Currency is not supported.");
  }
  const rawStartingAmount = Number(data.startingAmount || 0);
  const startingMinor = rawStartingAmount === 0
    ? 0
    : amountInMinorUnits(rawStartingAmount, currency);
  const isPersonal = data.isPersonal === true;
  const now = admin.firestore.Timestamp.now();
  const groupRef = db.collection("groups").doc();
  const userRef = db.collection("users").doc(uid);
  const movementRef = startingMinor > 0 ? groupRef.collection("movements").doc() : null;
  const auditRef = startingMinor > 0 ? groupRef.collection("audit").doc() : null;

  for (let attempt = 0; attempt < 8; attempt++) {
    const inviteCode = newInviteCode();
    const inviteRef = db.collection("inviteCodes").doc(inviteCode);
    const legacyMatch = await db.collection("groups")
      .where("inviteCode", "==", inviteCode).limit(1).get();
    if (!legacyMatch.empty) continue;

    try {
      await db.runTransaction(async (transaction) => {
        const [inviteSnap, userSnap] = await Promise.all([
          transaction.get(inviteRef),
          transaction.get(userRef),
        ]);
        if (inviteSnap.exists) throw new Error("invite-code-collision");
        const userData = userSnap.data() || {};
        const finalName = displayName || userData.displayName || "Member";
        const groupData = {
          name,
          createdBy: uid,
          createdAt: now,
          inviteCode,
          currency,
          isPersonal,
          balanceMinorUnits: startingMinor,
          ...(photoUrl ? {photoUrl} : {}),
        };
        transaction.create(groupRef, groupData);
        transaction.create(inviteRef, {groupId: groupRef.id});
        transaction.create(groupRef.collection("members").doc(uid), {
          displayName: finalName,
          joinedAt: now,
          photoUrl,
          notificationsMuted: false,
        });
        transaction.set(userRef.collection("memberships").doc(groupRef.id), {
          groupId: groupRef.id,
          joinedAt: now,
          name,
          isPersonal,
        });
        if (startingMinor > 0) {
          const factor = zeroDecimalCurrencies.has(currency) ? 1 : 100;
          const amount = startingMinor / factor;
          const movement = {
            type: "deposit",
            amount,
            title: "Starting balance",
            category: "Other",
            createdBy: uid,
            createdByName: finalName,
            createdAt: now,
            updatedAt: now,
            updatedBy: uid,
            updatedByName: finalName,
            receiptUrl: null,
            deleted: false,
            deletedAt: null,
            isStartingBalance: true,
          };
          transaction.create(movementRef, movement);
          transaction.create(auditRef, {
            movementId: movementRef.id,
            action: "create",
            performedBy: uid,
            performedByName: finalName,
            timestamp: now,
            before: null,
            after: movementSnapshot(movement),
          });
        }
        return groupData;
      });
      const snap = await groupRef.get();
      return callableGroup(groupRef.id, snap.data());
    } catch (error) {
      if (error.message === "invite-code-collision") continue;
      throw error;
    }
  }
  throw new functions.https.HttpsError("resource-exhausted", "Could not reserve an invite code.");
});

exports.joinGroup = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const inviteCode = inputString(data.inviteCode, "Invite code", 12).toUpperCase();
  const displayName = inputString(data.displayName, "Display name", 80) || "Member";
  const photoUrl = inputString(data.photoUrl, "Photo URL", 2048, false);
  const inviteSnap = await db.collection("inviteCodes").doc(inviteCode).get();
  let groupId = inviteSnap.data()?.groupId;
  if (!groupId) {
    const legacy = await db.collection("groups")
      .where("inviteCode", "==", inviteCode).limit(1).get();
    groupId = legacy.docs[0]?.id;
  }
  if (!groupId) {
    throw new functions.https.HttpsError("not-found", "No group found for this invite code.");
  }

  const groupRef = db.collection("groups").doc(groupId);
  const memberRef = groupRef.collection("members").doc(uid);
  const userRef = db.collection("users").doc(uid);
  let groupData;
  await db.runTransaction(async (transaction) => {
    const [groupSnap, memberSnap] = await Promise.all([
      transaction.get(groupRef),
      transaction.get(memberRef),
    ]);
    if (!groupSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Group no longer exists.");
    }
    groupData = groupSnap.data();
    if (!memberSnap.exists) {
      const now = admin.firestore.Timestamp.now();
      transaction.create(memberRef, {
        displayName,
        joinedAt: now,
        photoUrl,
        notificationsMuted: false,
      });
      transaction.set(userRef.collection("memberships").doc(groupId), {
        groupId,
        joinedAt: now,
        name: groupData.name,
        isPersonal: groupData.isPersonal === true,
      });
    }
  });

  return callableGroup(groupId, groupData);
});

/**
 * Send opt-in, actionable reminders in the recipient's local early evening.
 * A user gets one new-group reminder, or at most one unseen-activity recap
 * every seven days. Returning to the app or opening a group updates the
 * activity timestamps used below.
 */
exports.sendEngagementReminders = functions.region("us-central1")
  .runWith({timeoutSeconds: 540, memory: "256MB"})
  .pubsub.schedule("every 60 minutes")
  .timeZone("Etc/UTC")
  .onRun(async () => {
    const users = await db.collection("users")
      .where("remindersEnabled", "==", true).get();
    const now = new Date();
    const nowTs = admin.firestore.Timestamp.fromDate(now);
    const inactivityCutoff = now.getTime() - 3 * 24 * 60 * 60 * 1000;
    const cooldown = 7 * 24 * 60 * 60 * 1000;
    let sent = 0;

    for (const userDoc of users.docs) {
      const user = userDoc.data() || {};
      const zone = typeof user.timeZone === "string" ? user.timeZone : "Etc/UTC";
      let localHour;
      try {
        localHour = Number(new Intl.DateTimeFormat("en-GB", {
          timeZone: zone,
          hour: "2-digit",
          hourCycle: "h23",
        }).format(now));
      } catch (_error) {
        localHour = Number(new Intl.DateTimeFormat("en-GB", {
          timeZone: "Etc/UTC",
          hour: "2-digit",
          hourCycle: "h23",
        }).format(now));
      }
      if (localHour !== 18) continue;

      const lastActive = user.lastActiveAt?.toMillis?.() || 0;
      if (lastActive && lastActive > inactivityCutoff) continue;
      const memberships = await userDoc.ref.collection("memberships").get();

      if (memberships.empty) {
        const createdAt = user.createdAt?.toMillis?.() || 0;
        const accountIsOldEnough = createdAt &&
          now.getTime() - createdAt >= 3 * 24 * 60 * 60 * 1000;
        if (accountIsOldEnough && !user.onboardingReminderSentAt) {
          const reminderRef = userDoc.ref.collection("notifications")
            .doc("engagement_no_group");
          try {
            await reminderRef.create({
              title: "Your caisse is ready to start",
              body: "Create a personal caisse or join a group to keep shared expenses together.",
              type: "engagement_no_group",
              groupId: "",
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              read: false,
            });
          } catch (error) {
            if (error.code !== 6 && error.code !== "already-exists") throw error;
          }
          await userDoc.ref.update({onboardingReminderSentAt: nowTs});
          sent++;
        }
        continue;
      }

      const lastReminder = user.lastEngagementReminderAt?.toMillis?.() || 0;
      if (now.getTime() - lastReminder < cooldown) continue;
      let reminder = null;
      for (const membership of memberships.docs) {
        const groupId = membership.id;
        const groupRef = db.collection("groups").doc(groupId);
        const memberSnap = await groupRef.collection("members").doc(userDoc.id).get();
        if (!memberSnap.exists || memberSnap.data().notificationsMuted === true) continue;
        const groupSnap = await groupRef.get();
        if (!groupSnap.exists) continue;
        const lastViewed = membership.data().lastViewedAt?.toMillis?.() ||
          membership.data().joinedAt?.toMillis?.() || 0;
        const recentMovements = await groupRef.collection("movements")
          .orderBy("createdAt", "desc").limit(8).get();
        const unseen = recentMovements.docs.find((movement) => {
          const data = movement.data();
          return data.deleted !== true && data.createdBy !== userDoc.id &&
            data.createdAt?.toMillis?.() > lastViewed;
        });
        if (unseen) {
          reminder = {groupId, groupName: groupSnap.data().name || "your group"};
          break;
        }
      }
      if (!reminder) continue;
      const day = now.toISOString().slice(0, 10);
      try {
        await userDoc.ref.collection("notifications")
          .doc(`engagement_activity_${reminder.groupId}_${day}`).create({
            groupId: reminder.groupId,
            title: "Your group has new activity",
            body: `There is new activity in ${reminder.groupName}. Open the group to catch up.`,
            type: "engagement_activity",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
          });
      } catch (error) {
        if (error.code !== 6 && error.code !== "already-exists") throw error;
      }
      await userDoc.ref.update({lastEngagementReminderAt: nowTs});
      sent++;
    }
    console.log(`Sent ${sent} opt-in engagement reminders`);
    return sent;
  });

async function deleteQueryInBatches(query) {
  let deleted = 0;
  while (true) {
    const snap = await query.limit(400).get();
    if (snap.empty) break;
    let batch = db.batch();
    for (const doc of snap.docs) batch.delete(doc.ref);
    await batch.commit();
    deleted += snap.size;
    if (snap.size < 400) break;
  }
  return deleted;
}

exports.deleteGroup = functions.region("us-central1")
  .runWith({timeoutSeconds: 540, memory: "512MB"})
  .https.onCall(async (data, context) => {
    const uid = requireAuth(context);
    const groupId = data.groupId;
    if (typeof groupId !== "string" || !/^[A-Za-z0-9_-]{1,128}$/.test(groupId)) {
      throw new functions.https.HttpsError("invalid-argument", "Group is invalid.");
    }
    const groupRef = db.collection("groups").doc(groupId);
    const groupSnap = await groupRef.get();
    if (!groupSnap.exists) return {deleted: true};
    const group = groupSnap.data();
    if (group.createdBy !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the creator can delete this group.");
    }
    const members = await groupRef.collection("members").get();

    // Remove the group contents before the member docs. Firestore rules require
    // the caller's member doc to read anything under the group, so deleting it
    // first makes the group unreadable from the client immediately — and if a
    // later step then fails, the group is left half-deleted with no way to retry.
    const movementsRef = groupRef.collection("movements");
    while (true) {
      const movements = await movementsRef.limit(100).get();
      if (movements.empty) break;
      for (const movement of movements.docs) {
        await deleteQueryInBatches(groupRef.collection("audit")
          .where("movementId", "==", movement.id));
        await movement.ref.delete();
      }
    }
    await deleteQueryInBatches(groupRef.collection("audit"));
    await deleteQueryInBatches(groupRef.collection("settlements"));
    await admin.storage().bucket().deleteFiles({prefix: `groups/${groupId}/`})
      .catch((error) => console.error("storage cleanup failed", error));
    if (typeof group.inviteCode === "string") {
      await db.collection("inviteCodes").doc(group.inviteCode).delete().catch(() => {});
    }
    await groupRef.delete();

    // Best-effort sweeps. A missing index here must never fail the delete.
    await deleteQueryInBatches(
      db.collectionGroup("memberships").where("groupId", "==", groupId),
    ).catch((error) => console.error("membership sweep failed", error));

    let batch = db.batch();
    let writes = 0;
    for (const member of members.docs) {
      batch.delete(member.ref);
      batch.delete(db.collection("users").doc(member.id)
        .collection("memberships").doc(groupId));
      writes += 2;
      if (writes >= 400) { await batch.commit(); batch = db.batch(); writes = 0; }
    }
    if (writes > 0) await batch.commit();
    return {deleted: true};
  });

async function getGroupAndMember(transaction, groupId, uid) {
  if (typeof groupId !== "string" || !/^[A-Za-z0-9_-]{1,128}$/.test(groupId)) {
    throw new functions.https.HttpsError("invalid-argument", "Group is invalid.");
  }
  const groupRef = db.collection("groups").doc(groupId);
  const memberRef = groupRef.collection("members").doc(uid);
  const [groupSnap, memberSnap] = await Promise.all([
    transaction.get(groupRef),
    transaction.get(memberRef),
  ]);
  if (!groupSnap.exists || !memberSnap.exists) {
    throw new functions.https.HttpsError("permission-denied", "Group membership required.");
  }
  return {groupRef, groupData: groupSnap.data(), memberData: memberSnap.data()};
}

function auditWrite(transaction, groupRef, movementId, action, uid, name, before, after, now) {
  transaction.create(groupRef.collection("audit").doc(), {
    movementId,
    action,
    performedBy: uid,
    performedByName: name,
    timestamp: now,
    before: before ? movementSnapshot(before) : null,
    after: after ? movementSnapshot(after) : null,
  });
}

function resultTime(timestamp) {
  return {timestampMillis: timestamp.toMillis()};
}

exports.createMovement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupId = data.groupId;
  const movementId = inputString(data.movementId, "Movement ID", 128);
  if (!/^[A-Za-z0-9_-]+$/.test(movementId)) {
    throw new functions.https.HttpsError("invalid-argument", "Movement ID is invalid.");
  }
  const groupRef = db.collection("groups").doc(groupId);
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = admin.firestore.Timestamp.now();
  let created = false;
  await db.runTransaction(async (transaction) => {
    created = false;
    const {groupData, memberData} = await getGroupAndMember(transaction, groupId, uid);
    const existing = await transaction.get(movementRef);
    if (existing.exists) {
      if (existing.data().createdBy !== uid) {
        throw new functions.https.HttpsError("already-exists", "Movement ID is already used.");
      }
      return;
    }
    const currency = groupData.currency || "MAD";
    const delta = signedMinor(data, currency);
    const amount = amountInMinorUnits(data.amount, currency);
    const balance = await balanceMinorInTransaction(transaction, groupRef, groupData);
    if (balance + delta < 0) {
      throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
    }
    const displayName = inputString(data.displayName, "Display name", 80) ||
      memberData.displayName || "Member";
    const title = inputString(data.title, "Title", 120);
    const category = inputString(data.category, "Category", 60);
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const movement = {
      type: data.type,
      amount: amount / (10 ** digits),
      title,
      category,
      createdBy: uid,
      createdByName: displayName,
      createdAt: now,
      updatedAt: now,
      updatedBy: uid,
      updatedByName: displayName,
      receiptUrl: receiptReference(data.receiptUrl, groupId),
      deleted: false,
      deletedAt: null,
      isStartingBalance: false,
    };
    transaction.create(movementRef, movement);
    transaction.set(groupRef, {balanceMinorUnits: balance + delta}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "create", uid, displayName, null, movement, now);
    created = true;
  });
  return {...resultTime(now), movementId, created};
});

exports.updateMovement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const {groupId, movementId} = data;
  const groupRef = db.collection("groups").doc(groupId);
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = admin.firestore.Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupId, uid);
    const movementSnap = await transaction.get(movementRef);
    if (!movementSnap.exists) throw new functions.https.HttpsError("not-found", "Movement not found.");
    const existing = movementSnap.data();
    if (existing.isStartingBalance === true && groupData.createdBy !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the creator can change the starting balance.");
    }
    const currency = groupData.currency || "MAD";
    const type = existing.isStartingBalance ? "deposit" : data.type;
    const amountMinor = amountInMinorUnits(data.amount, currency);
    const oldDelta = existing.deleted ? 0 : signedMinor(existing, currency);
    const nextDelta = existing.deleted ? 0 : signedMinor({...data, type}, currency);
    const balance = await balanceMinorInTransaction(transaction, groupRef, groupData);
    if (balance + nextDelta - oldDelta < 0) {
      throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
    }
    const displayName = inputString(data.displayName, "Display name", 80) ||
      memberData.displayName || "Member";
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const updated = {
      ...existing,
      type,
      amount: amountMinor / (10 ** digits),
      title: existing.isStartingBalance ? "Starting balance" : inputString(data.title, "Title", 120),
      category: existing.isStartingBalance ? "Other" : inputString(data.category, "Category", 60),
      updatedAt: now,
      updatedBy: uid,
      updatedByName: displayName,
      ...(existing.isStartingBalance ? {} : {
        receiptUrl: receiptReference(data.receiptUrl, groupId),
      }),
    };
    transaction.set(movementRef, updated);
    transaction.set(groupRef, {balanceMinorUnits: balance + nextDelta - oldDelta}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "update", uid, displayName, existing, updated, now);
  });
  return resultTime(now);
});

exports.softDeleteMovement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const {groupId, movementId} = data;
  const groupRef = db.collection("groups").doc(groupId);
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = admin.firestore.Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupId, uid);
    const snap = await transaction.get(movementRef);
    if (!snap.exists) throw new functions.https.HttpsError("not-found", "Movement not found.");
    const existing = snap.data();
    if (existing.deleted) throw new functions.https.HttpsError("failed-precondition", "Movement is already deleted.");
    if (existing.isStartingBalance === true && groupData.createdBy !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the creator can delete the starting balance.");
    }
    const balance = await balanceMinorInTransaction(transaction, groupRef, groupData);
    const nextBalance = balance - signedMinor(existing, groupData.currency || "MAD");
    if (nextBalance < 0) {
      throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
    }
    const name = inputString(data.displayName, "Display name", 80) || memberData.displayName || "Member";
    const deleted = {...existing, deleted: true, deletedAt: now, updatedAt: now, updatedBy: uid, updatedByName: name};
    transaction.set(movementRef, deleted);
    transaction.set(groupRef, {balanceMinorUnits: nextBalance}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "delete", uid, name, existing, deleted, now);
  });
  return resultTime(now);
});

exports.undoSoftDelete = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const {groupId, movementId} = data;
  const groupRef = db.collection("groups").doc(groupId);
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = admin.firestore.Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupId, uid);
    const snap = await transaction.get(movementRef);
    if (!snap.exists) throw new functions.https.HttpsError("not-found", "Movement not found.");
    const existing = snap.data();
    if (!existing.deleted || !existing.deletedAt ||
        now.toMillis() - existing.deletedAt.toMillis() >= 24 * 60 * 60 * 1000) {
      throw new functions.https.HttpsError("failed-precondition", "Undo window has expired.");
    }
    if (existing.isStartingBalance === true && groupData.createdBy !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the creator can restore the starting balance.");
    }
    const balance = await balanceMinorInTransaction(transaction, groupRef, groupData);
    const nextBalance = balance + signedMinor(existing, groupData.currency || "MAD");
    if (nextBalance < 0) {
      throw new functions.https.HttpsError("failed-precondition", "Insufficient balance.");
    }
    const name = inputString(data.displayName, "Display name", 80) || memberData.displayName || "Member";
    const restored = {...existing, deleted: false, deletedAt: null, updatedAt: now, updatedBy: uid, updatedByName: name};
    transaction.set(movementRef, restored);
    transaction.set(groupRef, {balanceMinorUnits: nextBalance}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "update", uid, name, existing, restored, now);
  });
  return resultTime(now);
});

exports.recordSettlement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupId = data.groupId;
  const settlementId = inputString(data.settlementId, "Settlement ID", 128);
  const fromUid = inputString(data.fromUid, "Payer", 128);
  const toUid = inputString(data.toUid, "Recipient", 128);
  if (!/^[A-Za-z0-9_-]+$/.test(settlementId) || fromUid !== uid || toUid === uid) {
    throw new functions.https.HttpsError("invalid-argument", "Settlement details are invalid.");
  }
  const groupRef = db.collection("groups").doc(groupId);
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = admin.firestore.Timestamp.now();
  let created = false;
  await db.runTransaction(async (transaction) => {
    created = false;
    const {groupData, memberData} = await getGroupAndMember(transaction, groupId, uid);
    if (groupData.isPersonal === true) {
      throw new functions.https.HttpsError("failed-precondition", "Personal caisses do not use group settlements.");
    }
    const toMemberRef = groupRef.collection("members").doc(toUid);
    const pendingQuery = groupRef.collection("settlements")
      .where("fromUid", "==", uid)
      .where("toUid", "==", toUid)
      .where("status", "==", "pending");
    const [toMember, existing, pending] = await Promise.all([
      transaction.get(toMemberRef),
      transaction.get(settlementRef),
      transaction.get(pendingQuery),
    ]);
    if (!toMember.exists) {
      throw new functions.https.HttpsError("failed-precondition", "The recipient is no longer in this group.");
    }
    if (existing.exists) {
      if (existing.data().fromUid === uid && existing.data().toUid === toUid) return;
      throw new functions.https.HttpsError("already-exists", "Settlement ID is already used.");
    }
    if (!pending.empty) {
      throw new functions.https.HttpsError("failed-precondition", "A payment is already waiting for confirmation.");
    }
    const currency = groupData.currency || "MAD";
    const minor = amountInMinorUnits(data.amount, currency);
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const amount = minor / (10 ** digits);
    const fromName = memberData.displayName || "Member";
    const toName = toMember.data().displayName || "Member";
    transaction.create(settlementRef, {
      fromUid: uid,
      fromName,
      toUid,
      toName,
      amount,
      currency,
      status: "pending",
      createdAt: now,
      confirmedAt: null,
    });
    transaction.set(groupRef, {
      settlementRevision: admin.firestore.FieldValue.increment(1),
    }, {merge: true});
    transaction.create(groupRef.collection("audit").doc(), {
      settlementId,
      action: "settlement_pending",
      performedBy: uid,
      performedByName: fromName,
      timestamp: now,
      amount,
      fromUid: uid,
      toUid,
    });
    transaction.create(db.collection("users").doc(toUid)
      .collection("notifications").doc(`settlement_pending_${settlementId}`), {
        groupId,
        title: "Payment to confirm",
        body: `${fromName} recorded a payment of ${amount} ${currency} to you.`,
        type: "settlement_pending",
        actorUid: uid,
        actorName: fromName,
        createdAt: now,
        read: false,
      });
    created = true;
  });
  return {...resultTime(now), settlementId, created};
});

exports.confirmSettlement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupId = data.groupId;
  const settlementId = inputString(data.settlementId, "Settlement ID", 128);
  const groupRef = db.collection("groups").doc(groupId);
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = admin.firestore.Timestamp.now();
  let confirmed = false;
  await db.runTransaction(async (transaction) => {
    confirmed = false;
    const {memberData} = await getGroupAndMember(transaction, groupId, uid);
    const snap = await transaction.get(settlementRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError("not-found", "Payment not found.");
    }
    const payment = snap.data();
    if (payment.toUid !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the recipient can confirm this payment.");
    }
    if (payment.status === "confirmed") return;
    transaction.update(settlementRef, {
      status: "confirmed",
      confirmedAt: now,
      confirmedBy: uid,
    });
    transaction.set(groupRef, {
      settlementRevision: admin.firestore.FieldValue.increment(1),
    }, {merge: true});
    transaction.create(groupRef.collection("audit").doc(), {
      settlementId,
      action: "settlement_confirmed",
      performedBy: uid,
      performedByName: memberData.displayName || "Member",
      timestamp: now,
      amount: payment.amount,
      fromUid: payment.fromUid,
      toUid: uid,
    });
    transaction.create(db.collection("users").doc(payment.fromUid)
      .collection("notifications").doc(`settlement_confirmed_${settlementId}`), {
        groupId,
        title: "Payment confirmed",
        body: `${payment.toName || "The recipient"} confirmed your payment of ${payment.amount} ${payment.currency || ""}.`,
        type: "settlement_confirmed",
        actorUid: uid,
        actorName: memberData.displayName || "Member",
        createdAt: now,
        read: false,
      });
    confirmed = true;
  });
  return {...resultTime(now), settlementId, confirmed};
});

exports.cancelSettlement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupId = data.groupId;
  const settlementId = inputString(data.settlementId, "Settlement ID", 128);
  const groupRef = db.collection("groups").doc(groupId);
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = admin.firestore.Timestamp.now();
  let cancelled = false;
  await db.runTransaction(async (transaction) => {
    cancelled = false;
    const {memberData} = await getGroupAndMember(transaction, groupId, uid);
    const snap = await transaction.get(settlementRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError("not-found", "Payment not found.");
    }
    const payment = snap.data();
    if (payment.fromUid !== uid && payment.toUid !== uid) {
      throw new functions.https.HttpsError("permission-denied", "Only the participants can cancel this payment.");
    }
    if (payment.status !== "pending") {
      throw new functions.https.HttpsError("failed-precondition", "Only a pending payment can be cancelled.");
    }
    transaction.update(settlementRef, {
      status: "cancelled",
      cancelledAt: now,
      cancelledBy: uid,
    });
    transaction.set(groupRef, {
      settlementRevision: admin.firestore.FieldValue.increment(1),
    }, {merge: true});
    transaction.create(groupRef.collection("audit").doc(), {
      settlementId,
      action: "settlement_cancelled",
      performedBy: uid,
      performedByName: memberData.displayName || "Member",
      timestamp: now,
      amount: payment.amount,
      fromUid: payment.fromUid,
      toUid: payment.toUid,
    });
    const otherUid = uid === payment.fromUid ? payment.toUid : payment.fromUid;
    transaction.create(db.collection("users").doc(otherUid)
      .collection("notifications").doc(`settlement_cancelled_${settlementId}`), {
        groupId,
        title: "Payment cancelled",
        body: `${memberData.displayName || "A member"} cancelled a pending payment.`,
        type: "settlement_cancelled",
        actorUid: uid,
        actorName: memberData.displayName || "Member",
        createdAt: now,
        read: false,
      });
    cancelled = true;
  });
  return {...resultTime(now), settlementId, cancelled};
});

exports.notifyMovementChange = functions.region("us-central1")
  .firestore.document("groups/{groupId}/movements/{movementId}")
  .onWrite(async (change, context) => {
    if (!change.after.exists) return null;
    const after = change.after.data();
    const before = change.before.exists ? change.before.data() : null;
    let type = "movement_update";
    if (!before) type = "new_movement";
    else if (!before.deleted && after.deleted) type = "movement_delete";
    else if (before.deleted && !after.deleted) type = "movement_restore";
    const actorUid = after.updatedBy || after.createdBy || "";
    const title = type === "new_movement"
      ? (after.type === "expense" ? "New expense" : "New deposit")
      : type === "movement_delete" ? "Movement deleted"
      : type === "movement_restore" ? "Movement restored" : "Movement updated";
    const body = `${after.updatedByName || after.createdByName || "A member"}: ${after.title || "Movement"}`;
    const members = await db.collection("groups").doc(context.params.groupId)
      .collection("members").get();
    let batch = db.batch();
    let count = 0;
    for (const member of members.docs) {
      if (member.id === actorUid || member.data().notificationsMuted === true) continue;
      const id = crypto.createHash("sha256")
        .update(`${context.eventId}:${member.id}`).digest("hex").slice(0, 40);
      batch.create(db.collection("users").doc(member.id)
        .collection("notifications").doc(id), {
          groupId: context.params.groupId,
          title,
          body,
          type,
          actorUid,
          actorName: after.updatedByName || after.createdByName || null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      count++;
      if (count >= 450) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
    return null;
  });

exports.notifyMemberJoin = functions.region("us-central1")
  .firestore.document("groups/{groupId}/members/{uid}")
  .onCreate(async (snap, context) => {
    const groupId = context.params.groupId;
    const actorUid = context.params.uid;
    const groupRef = db.collection("groups").doc(groupId);
    const groupSnap = await groupRef.get();
    if (!groupSnap.exists || groupSnap.data().createdBy === actorUid) return null;
    const actorName = snap.data().displayName || "A member";
    const members = await groupRef.collection("members").get();
    let batch = db.batch();
    let count = 0;
    for (const member of members.docs) {
      if (member.id === actorUid || member.data().notificationsMuted === true) continue;
      const id = crypto.createHash("sha256")
        .update(`${context.eventId}:${member.id}`).digest("hex").slice(0, 40);
      batch.create(db.collection("users").doc(member.id)
        .collection("notifications").doc(id), {
          groupId,
          title: "New group member",
          body: `${actorName} joined ${groupSnap.data().name || "the group"}.`,
          type: "member_join",
          actorUid,
          actorName,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      count++;
      if (count >= 450) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
    return null;
  });

exports.deleteAccount = functions.region("us-central1")
  .runWith({timeoutSeconds: 540, memory: "512MB"})
  .https.onCall(async (_data, context) => {
    const uid = requireAuth(context);
    const authTime = Number(context.auth.token.auth_time || 0) * 1000;
    if (!authTime || Date.now() - authTime > 10 * 60 * 1000) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "For security, sign out and sign in again before deleting your account.",
      );
    }
    const owned = await db.collection("groups").where("createdBy", "==", uid).limit(1).get();
    if (!owned.empty) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Delete groups you created before deleting your account.",
      );
    }

    const indexedMemberships = await db.collection("users").doc(uid).collection("memberships").get();
    const groupIds = new Set(indexedMemberships.docs.map((doc) => doc.id));
    for (const groupId of groupIds) {
      const batch = db.batch();
      batch.delete(db.collection("groups").doc(groupId).collection("members").doc(uid));
      batch.delete(db.collection("users").doc(uid).collection("memberships").doc(groupId));
      await batch.commit();
    }

    const pseudonym = "deleted_" + crypto.createHash("sha256").update(uid).digest("hex").slice(0, 16);
    const [authored, updatedByUser] = await Promise.all([
      db.collectionGroup("movements").where("createdBy", "==", uid).get(),
      db.collectionGroup("movements").where("updatedBy", "==", uid).get(),
    ]);
    const movementDocs = new Map();
    for (const doc of [...authored.docs, ...updatedByUser.docs]) movementDocs.set(doc.ref.path, doc);
    const idsByGroup = new Map();
    let batch = db.batch();
    let count = 0;
    for (const doc of movementDocs.values()) {
      const data = doc.data();
      const groupRef = doc.ref.parent.parent;
      if (data.createdBy === uid && groupRef) {
        if (!idsByGroup.has(groupRef.id)) idsByGroup.set(groupRef.id, new Set());
        idsByGroup.get(groupRef.id).add(doc.id);
      }
      batch.update(doc.ref, {
        ...(data.createdBy === uid
          ? {createdBy: pseudonym, createdByName: "Deleted member"}
          : {}),
        ...(data.updatedBy === uid
          ? {updatedBy: pseudonym, updatedByName: "Deleted member"}
          : {}),
      });
      if (++count === 400) { await batch.commit(); batch = db.batch(); count = 0; }
    }
    if (count > 0) await batch.commit();

    const [paidSettlements, receivedSettlements, confirmedSettlements, cancelledSettlements] = await Promise.all([
      db.collectionGroup("settlements").where("fromUid", "==", uid).get(),
      db.collectionGroup("settlements").where("toUid", "==", uid).get(),
      db.collectionGroup("settlements").where("confirmedBy", "==", uid).get(),
      db.collectionGroup("settlements").where("cancelledBy", "==", uid).get(),
    ]);
    const settlementDocs = new Map();
    for (const doc of [...paidSettlements.docs, ...receivedSettlements.docs, ...confirmedSettlements.docs, ...cancelledSettlements.docs]) {
      settlementDocs.set(doc.ref.path, doc);
    }
    batch = db.batch();
    count = 0;
    for (const doc of settlementDocs.values()) {
      const payment = doc.data();
      batch.update(doc.ref, {
        ...(payment.fromUid === uid
          ? {fromUid: pseudonym, fromName: "Deleted member"}
          : {}),
        ...(payment.toUid === uid
          ? {toUid: pseudonym, toName: "Deleted member"}
          : {}),
        ...(payment.confirmedBy === uid ? {confirmedBy: pseudonym} : {}),
        ...(payment.cancelledBy === uid ? {cancelledBy: pseudonym} : {}),
      });
      if (++count === 400) { await batch.commit(); batch = db.batch(); count = 0; }
    }
    if (count > 0) await batch.commit();

    const auditDocs = new Map();
    const performedByUser = await db.collectionGroup("audit")
      .where("performedBy", "==", uid).get();
    for (const doc of performedByUser.docs) auditDocs.set(doc.ref.path, doc);
    for (const [groupId, movementIds] of idsByGroup.entries()) {
      const ids = [...movementIds];
      for (let offset = 0; offset < ids.length; offset += 30) {
        const chunk = ids.slice(offset, offset + 30);
        const related = await db.collection("groups").doc(groupId).collection("audit")
          .where("movementId", "in", chunk).get();
        for (const doc of related.docs) auditDocs.set(doc.ref.path, doc);
      }
    }

    const scrubSnapshot = (snapshot) => snapshot && ({
      ...snapshot,
      ...(snapshot.createdBy === uid
        ? {createdBy: pseudonym, createdByName: "Deleted member"}
        : {}),
    });
    batch = db.batch();
    count = 0;
    for (const doc of auditDocs.values()) {
      const data = doc.data();
      batch.update(doc.ref, {
        ...(data.performedBy === uid
          ? {performedBy: pseudonym, performedByName: "Deleted member"}
          : {}),
        before: scrubSnapshot(data.before),
        after: scrubSnapshot(data.after),
      });
      if (++count === 400) { await batch.commit(); batch = db.batch(); count = 0; }
    }
    if (count > 0) await batch.commit();

    const actorNotifications = await db.collectionGroup("notifications")
      .where("actorUid", "==", uid).get();
    batch = db.batch();
    count = 0;
    for (const doc of actorNotifications.docs) {
      batch.update(doc.ref, {actorUid: pseudonym, actorName: "Deleted member"});
      if (++count === 400) { await batch.commit(); batch = db.batch(); count = 0; }
    }
    if (count > 0) await batch.commit();

    const notifications = await db.collection("users").doc(uid).collection("notifications").get();
    batch = db.batch();
    count = 0;
    for (const doc of notifications.docs) {
      batch.delete(doc.ref);
      if (++count === 400) { await batch.commit(); batch = db.batch(); count = 0; }
    }
    if (count > 0) await batch.commit();
    await admin.storage().bucket().deleteFiles({prefix: `users/${uid}/`});
    await db.collection("users").doc(uid).delete();
    await admin.auth().deleteUser(uid);
    return {deleted: true};
  });
