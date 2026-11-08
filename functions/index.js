const functions = require("firebase-functions/v1");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {
  getFirestore,
  FieldPath,
  FieldValue,
  Timestamp,
} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {getStorage} = require("firebase-admin/storage");

initializeApp();

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

    const userSnap = await getFirestore().collection("users").doc(uid).get();
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

    const response = await getMessaging().sendEachForMulticast({
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
  await getFirestore().collection("users").doc(uid).set(updates, {merge: true});
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
  const cutoff = Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000),
  );
  const snap = await getFirestore()
    .collectionGroup("movements")
    .where("deleted", "==", true)
    .where("deletedAt", "<", cutoff)
    .limit(400)
    .get();

  if (snap.empty) {
    console.log("No expired soft-deletes to purge");
    return 0;
  }

  let batch = getFirestore().batch();
  let ops = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const receiptUrl = data.receiptUrl;
    if (typeof receiptUrl === "string" && receiptUrl.length > 0) {
      try {
        await getStorage().bucket().file(storagePathFromUrl(receiptUrl)).delete();
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
      batch = getFirestore().batch();
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
const db = getFirestore();
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
    split: data.split || null,
    originalCurrency: data.originalCurrency || null,
    originalAmount: data.originalAmount || null,
  };
}

const MAX_SPLIT_MEMBERS = 50;

function minorFactor(currency) {
  return 10 ** (zeroDecimalCurrencies.has(currency) ? 0 : 2);
}

/**
 * Validates a member uid → share map. Shares are checked in minor units so the
 * parts always add up to exactly the movement amount, and every participant
 * must currently be a member, which is why this has to run inside the
 * transaction before any write.
 */
async function parseSplit(transaction, groupRef, raw, amountMinor, currency) {
  if (raw == null) return null;
  if (typeof raw !== "object" || Array.isArray(raw)) {
    throw new functions.https.HttpsError("invalid-argument", "Split is invalid.");
  }
  const entries = Object.entries(raw);
  if (entries.length === 0 || entries.length > MAX_SPLIT_MEMBERS) {
    throw new functions.https.HttpsError("invalid-argument", "Split is invalid.");
  }
  const factor = minorFactor(currency);
  const split = {};
  let total = 0;
  for (const [uid, value] of entries) {
    if (!SAFE_ID_RE.test(uid)) {
      throw new functions.https.HttpsError("invalid-argument", "Split is invalid.");
    }
    const minor = amountInMinorUnits(value, currency);
    total += minor;
    split[uid] = minor / factor;
  }
  if (total !== amountMinor) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Split shares must add up to the amount.",
    );
  }
  const members = await transaction.getAll(
    ...entries.map(([uid]) => groupRef.collection("members").doc(uid)),
  );
  if (members.some((snap) => !snap.exists)) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The split includes someone who is not in this group.",
    );
  }
  return split;
}

/**
 * A movement typed in another currency keeps what was actually paid next to
 * the converted group-currency amount. The conversion is re-checked here so a
 * client cannot store a rate that disagrees with the amount it charged.
 */
function parseOriginal(raw, amountMinor, currency) {
  if (raw == null) return null;
  if (typeof raw !== "object" || Array.isArray(raw)) {
    throw new functions.https.HttpsError("invalid-argument", "Original amount is invalid.");
  }
  const code = inputString(raw.currency, "Original currency", 3);
  if (!supportedCurrencies.has(code) || code === currency) {
    throw new functions.https.HttpsError("invalid-argument", "Original currency is invalid.");
  }
  const originalMinor = amountInMinorUnits(raw.amount, code);
  const rate = Number(raw.rate);
  if (!Number.isFinite(rate) || rate <= 0 || rate > 1e7) {
    throw new functions.https.HttpsError("invalid-argument", "Exchange rate is invalid.");
  }
  const originalAmount = originalMinor / minorFactor(code);
  const expectedMinor = Math.round(originalAmount * rate * minorFactor(currency));
  if (Math.abs(expectedMinor - amountMinor) > 1) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Converted amount does not match the exchange rate.",
    );
  }
  return {originalCurrency: code, originalAmount, exchangeRate: rate};
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

// Exactly the alphabet newInviteCode() can emit. A lookup by document id is a
// free existence oracle, so anything outside this shape is refused before any
// read happens instead of being used as a probe.
const INVITE_CODE_RE = /^[A-HJ-NP-Z2-9]{6}$/;
const MAX_MEMBERS_PER_GROUP = 200;
const JOIN_WINDOW_MS = 60 * 60 * 1000;
const MAX_JOIN_ATTEMPTS = 10;
const CREATE_WINDOW_MS = 24 * 60 * 60 * 1000;
const MAX_GROUPS_PER_DAY = 20;
const SAFE_ID_RE = /^[A-Za-z0-9_-]{1,128}$/;

function safeId(value, field) {
  if (typeof value !== "string" || !SAFE_ID_RE.test(value)) {
    throw new functions.https.HttpsError("invalid-argument", `${field} is invalid.`);
  }
  return value;
}

// Validating before the reference is built turns a malformed id into a clean
// invalid-argument instead of an unhandled SDK path error, which surfaced as
// an opaque internal to the client.
function groupRefFrom(groupId) {
  return db.collection("groups").doc(safeId(groupId, "Group"));
}

/**
 * Fixed-window counter charged in its own transaction, so a call that later
 * fails (a wrong invite code, a missing group) still costs the caller an
 * attempt. The read and the write share the transaction, so concurrent calls
 * cannot all observe the same count and slip past the limit.
 */
async function consumeRateLimit(ref, windowMs, max, message) {
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const current = snap.data() || {};
    const startMs = current.windowStart ? current.windowStart.toMillis() : 0;
    const inWindow = startMs > 0 && now.toMillis() - startMs < windowMs;
    const count = (inWindow ? current.count : 0) + 1;
    if (count > max) {
      throw new functions.https.HttpsError("resource-exhausted", message);
    }
    transaction.set(ref, {
      count,
      windowStart: inWindow
        ? current.windowStart
        : FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
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
  const now = Timestamp.now();
  const groupRef = db.collection("groups").doc();
  const userRef = db.collection("users").doc(uid);
const movementRef = startingMinor > 0 ? groupRef.collection("movements").doc() : null;
  const auditRef = startingMinor > 0 ? groupRef.collection("audit").doc() : null;
  // Each group mints an invite code, a membership index and a member doc, and
  // createGroup is self-service, so an unthrottled caller could create groups
  // without limit. One daily quota per account bounds it.
  const createQuotaRef = db.collection("rateLimits").doc(`create_${uid}`);

  for (let attempt = 0; attempt < 8; attempt++) {
    const inviteCode = newInviteCode();
    const inviteRef = db.collection("inviteCodes").doc(inviteCode);
    const legacyMatch = await db.collection("groups")
      .where("inviteCode", "==", inviteCode).limit(1).get();
    if (!legacyMatch.empty) continue;

    try {
      await db.runTransaction(async (transaction) => {
const [inviteSnap, userSnap, quotaSnap] = await Promise.all([
          transaction.get(inviteRef),
          transaction.get(userRef),
          transaction.get(createQuotaRef),
        ]);
        if (inviteSnap.exists) throw new Error("invite-code-collision");
        const quota = quotaSnap.data() || {};
        const quotaStartMs = quota.windowStart ? quota.windowStart.toMillis() : 0;
        const quotaInWindow = quotaStartMs > 0 &&
          now.toMillis() - quotaStartMs < CREATE_WINDOW_MS;
        const createdToday = (quotaInWindow ? quota.count : 0) + 1;
        if (createdToday > MAX_GROUPS_PER_DAY) {
          throw new functions.https.HttpsError(
            "resource-exhausted", "Group creation limit reached. Try again tomorrow.",
          );
        }
        transaction.set(createQuotaRef, {
          count: createdToday,
          windowStart: quotaInWindow
            ? quota.windowStart
            : FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        }, {merge: true});
        const userData = userSnap.data() || {};
        const finalName = displayName || userData.displayName || "Member";
        const groupData = {
          name,
          createdBy: uid,
          createdAt: now,
          inviteCode,
          currency,
          isPersonal,
          memberCount: 1,
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
  const inviteCode = inputString(data.inviteCode, "Invite code", 32).toUpperCase();
  if (!INVITE_CODE_RE.test(inviteCode)) {
    throw new functions.https.HttpsError("invalid-argument", "Invite code is invalid.");
  }
  const displayName = inputString(data.displayName, "Display name", 80, false) || "Member";
  const photoUrl = inputString(data.photoUrl, "Photo URL", 2048, false);

  // Charged before the code is resolved so guessing is rate limited even when
  // every guess misses. A leaked code is one of 32^6; without this an attacker
  // with any self-registered account can enumerate the space at line speed.
  await consumeRateLimit(
    db.collection("rateLimits").doc(`join_${uid}`),
    JOIN_WINDOW_MS,
    MAX_JOIN_ATTEMPTS,
    "Too many invite code attempts. Try again later.",
  );

  const inviteSnap = await db.collection("inviteCodes").doc(inviteCode).get();
  let groupId = inviteSnap.data()?.groupId;
  if (!groupId) {
    // Codes issued before the inviteCodes mirror existed are only reachable
    // through the group document, so this fallback stays. The rate limit above
    // is what bounds how often it can be paid for.
    const legacy = await db.collection("groups")
      .where("inviteCode", "==", inviteCode).limit(1).get();
    groupId = legacy.docs[0]?.id;
  }
  if (!groupId) {
    throw new functions.https.HttpsError("not-found", "No group found for this invite code.");
  }

  const groupRef = groupRefFrom(groupId);
  const memberRef = groupRef.collection("members").doc(uid);
  const userRef = db.collection("users").doc(uid);

  // A group has no hard capacity in the schema, and every join fans out one
  // notification per existing member, so an uncapped group is a billing
  // amplifier as well as a product problem. One capped read answers it.
  const members = await groupRef.collection("members")
    .limit(MAX_MEMBERS_PER_GROUP + 1).get();
  if (members.docs.length > MAX_MEMBERS_PER_GROUP) {
    throw new functions.https.HttpsError("resource-exhausted", "This group is full.");
  }

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
    // The share button is hidden for personal caisses in the client, but that
    // is a courtesy and not a control: a code that leaks through a screenshot
    // or a guess must not hand over someone's private ledger.
    if (groupData.isPersonal === true) {
      throw new functions.https.HttpsError(
        "failed-precondition", "This is a personal caisse and cannot be joined.",
      );
    }
    const now = Timestamp.now();
    if (!memberSnap.exists) {
      transaction.create(memberRef, {
        displayName,
        joinedAt: now,
        photoUrl,
        notificationsMuted: false,
      });
      transaction.set(groupRef, {
        memberCount: FieldValue.increment(1),
      }, {merge: true});
    }
    // Written on every call, not just the first join, so a member who left and
    // came back does not keep a stale joinedAt on their own index entry.
    transaction.set(userRef.collection("memberships").doc(groupId), {
      groupId,
      joinedAt: memberSnap.exists ? memberSnap.data().joinedAt : now,
      name: groupData.name,
      isPersonal: false,
    });
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
    // Opted-in users are paged instead of loaded in one shot: a single
    // unbounded .get() scales with the whole user base and will exhaust this
    // 256MB instance once the collection is large. Paging by document id keeps
    // the same filter and visits each opted-in user exactly once.
    //
    // Re-processing is safe, so if the budget is reached the next hourly run
    // simply starts over: the per-user cooldown, the local-hour gate and the
    // deterministic notification ids all prevent duplicate reminders.
    const PAGE_SIZE = 200;
    const MAX_DOCS_PER_RUN = 2000;

    const now = new Date();
    const nowTs = Timestamp.fromDate(now);
    const inactivityCutoff = now.getTime() - 3 * 24 * 60 * 60 * 1000;
    const cooldown = 7 * 24 * 60 * 60 * 1000;
    let sent = 0;
    let scanned = 0;
    let cursor = null;
    let exhausted = false;

    while (!exhausted && scanned < MAX_DOCS_PER_RUN) {
      let query = db.collection("users")
        .where("remindersEnabled", "==", true)
        .orderBy(FieldPath.documentId())
        .limit(Math.min(PAGE_SIZE, MAX_DOCS_PER_RUN - scanned));
      if (cursor) {
        query = query.startAfter(cursor);
      }

      const page = await query.get();
      if (page.empty) {
        exhausted = true;
        break;
      }
      cursor = page.docs[page.docs.length - 1].id;

      for (const userDoc of page.docs) {
        scanned++;
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
                createdAt: FieldValue.serverTimestamp(),
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
            createdAt: FieldValue.serverTimestamp(),
            read: false,
          });
      } catch (error) {
        if (error.code !== 6 && error.code !== "already-exists") throw error;
      }
await userDoc.ref.update({lastEngagementReminderAt: nowTs});
      sent++;
      }
    }
    console.log(
      `Sent ${sent} opt-in engagement reminders ` +
      `(scanned ${scanned} users${exhausted ? "" : ", budget reached"})`,
    );
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
    // Deletions are done in batches with parallelism for speed: movements and
    // audit entries are deleted in batches without per-document round trips.
    await deleteQueryInBatches(groupRef.collection("movements"));
    await deleteQueryInBatches(groupRef.collection("audit"));
    await deleteQueryInBatches(groupRef.collection("settlements"));
    await deleteQueryInBatches(groupRef.collection("recurring"));
    await getStorage().bucket().deleteFiles({prefix: `groups/${groupId}/`})
      .catch((error) => console.error("storage cleanup failed", error));
    if (typeof group.inviteCode === "string") {
      await db.collection("inviteCodes").doc(group.inviteCode).delete().catch(() => {});
    }
    await groupRef.delete();

    // Best-effort sweeps. A missing index here must never fail the delete.
    await deleteQueryInBatches(
      db.collectionGroup("memberships").where("groupId", "==", groupId),
    ).catch((error) => console.error("membership sweep failed", error));

    // Delete member docs and membership refs in batches.
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

    // Clean up notifications referencing this group from each member's inbox.
    // Best-effort: a missing index should never fail the delete.
    await Promise.all(members.docs.map(async (memberDoc) => {
      try {
        await deleteQueryInBatches(
          db.collection("users").doc(memberDoc.id)
            .collection("notifications")
            .where("groupId", "==", groupId),
        );
      } catch (error) {
        console.error(`notification cleanup failed for ${memberDoc.id}`, error);
      }
    })).catch((error) => console.error("group notification sweep failed", error));

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
const groupRef = groupRefFrom(data.groupId);
  const movementId = safeId(data.movementId, "Movement ID");
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = Timestamp.now();
  let created = false;
  await db.runTransaction(async (transaction) => {
    created = false;
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
    const displayName = inputString(data.displayName, "Display name", 80, false) ||
      memberData.displayName || "Member";
    const title = inputString(data.title, "Title", 120);
    const category = inputString(data.category, "Category", 60);
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const split = groupData.isPersonal === true
      ? null
      : await parseSplit(transaction, groupRef, data.split, amount, currency);
    const original = parseOriginal(data.original, amount, currency);
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
      receiptUrl: receiptReference(data.receiptUrl, groupRef.id),
      deleted: false,
      deletedAt: null,
      isStartingBalance: false,
      split,
      originalCurrency: original ? original.originalCurrency : null,
      originalAmount: original ? original.originalAmount : null,
      exchangeRate: original ? original.exchangeRate : null,
      recurringId: null,
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
  const groupRef = groupRefFrom(data.groupId);
  const movementId = safeId(data.movementId, "Movement ID");
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
    const displayName = inputString(data.displayName, "Display name", 80, false) ||
      memberData.displayName || "Member";
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const plain = existing.isStartingBalance === true;
    const split = plain || groupData.isPersonal === true
      ? null
      : await parseSplit(transaction, groupRef, data.split, amountMinor, currency);
    const original = plain ? null : parseOriginal(data.original, amountMinor, currency);
    const updated = {
      ...existing,
      type,
      amount: amountMinor / (10 ** digits),
      title: existing.isStartingBalance ? "Starting balance" : inputString(data.title, "Title", 120),
      category: existing.isStartingBalance ? "Other" : inputString(data.category, "Category", 60),
      updatedAt: now,
      updatedBy: uid,
      updatedByName: displayName,
      split,
      originalCurrency: original ? original.originalCurrency : null,
      originalAmount: original ? original.originalAmount : null,
      exchangeRate: original ? original.exchangeRate : null,
      ...(existing.isStartingBalance ? {} : {
        receiptUrl: receiptReference(data.receiptUrl, groupRef.id),
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
  const groupRef = groupRefFrom(data.groupId);
  const movementId = safeId(data.movementId, "Movement ID");
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
    const name = inputString(data.displayName, "Display name", 80, false) || memberData.displayName || "Member";
    const deleted = {...existing, deleted: true, deletedAt: now, updatedAt: now, updatedBy: uid, updatedByName: name};
    transaction.set(movementRef, deleted);
    transaction.set(groupRef, {balanceMinorUnits: nextBalance}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "delete", uid, name, existing, deleted, now);
  });
  return resultTime(now);
});

exports.undoSoftDelete = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupRef = groupRefFrom(data.groupId);
  const movementId = safeId(data.movementId, "Movement ID");
  const movementRef = groupRef.collection("movements").doc(movementId);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
    const name = inputString(data.displayName, "Display name", 80, false) || memberData.displayName || "Member";
    const restored = {...existing, deleted: false, deletedAt: null, updatedAt: now, updatedBy: uid, updatedByName: name};
    transaction.set(movementRef, restored);
    transaction.set(groupRef, {balanceMinorUnits: nextBalance}, {merge: true});
    auditWrite(transaction, groupRef, movementId, "update", uid, name, existing, restored, now);
  });
  return resultTime(now);
});

// Deterministic per-direction key for the settlement replay guard. Both uids
// are validated against [A-Za-z0-9_-]+ before this is ever called, so the
// result is always a legal document id.
function settlementPairKey(fromUid, toUid) {
  return `${fromUid}__${toUid}`;
}

exports.recordSettlement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
const groupRef = groupRefFrom(data.groupId);
  const settlementId = safeId(data.settlementId, "Settlement ID");
  const fromUid = inputString(data.fromUid, "Payer", 128);
  const toUid = inputString(data.toUid, "Recipient", 128);
  // Both uids reach settlementPairKey() and so become part of a document id:
  // an unchecked "/" throws an SDK path error that reaches the client as an
  // opaque internal, and an unchecked "__" would alias one pair's replay guard
  // onto a different pair's.
  // The recipient may record money already in hand. That payment needs no
  // second confirmation, because the person who would confirm it is the caller.
  const asRecipient = data.asRecipient === true;
  const otherUid = asRecipient ? fromUid : toUid;
  if (!SAFE_ID_RE.test(fromUid) || !SAFE_ID_RE.test(toUid) ||
      fromUid.includes("__") || toUid.includes("__") || fromUid === toUid ||
      (asRecipient ? toUid !== uid : fromUid !== uid)) {
    throw new functions.https.HttpsError("invalid-argument", "Settlement details are invalid.");
  }
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = Timestamp.now();
  let created = false;
  await db.runTransaction(async (transaction) => {
    created = false;
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
    if (groupData.isPersonal === true) {
      throw new functions.https.HttpsError("failed-precondition", "Personal caisses do not use group settlements.");
    }
    const otherMemberRef = groupRef.collection("members").doc(otherUid);
    const pendingQuery = groupRef.collection("settlements")
      .where("fromUid", "==", fromUid)
      .where("toUid", "==", toUid)
      .where("status", "==", "pending");
    const pairGuardRef = groupRef
      .collection("settlementGuards")
      .doc(settlementPairKey(fromUid, toUid));
    // A settlement is only worth recording when something changed since the
    // last one. Keying on the balance alone is not enough: expenses and deposits
    // can return the balance to the same number while genuinely new activity
    // happened, so the newest movement is tracked as a monotonic second signal.
    const latestMovementQuery = groupRef.collection("movements")
      .orderBy("createdAt", "desc")
      .limit(1);
    const [otherMember, existing, pending, pairGuard, latestMovement] = await Promise.all([
      transaction.get(otherMemberRef),
      transaction.get(settlementRef),
      transaction.get(pendingQuery),
      transaction.get(pairGuardRef),
      transaction.get(latestMovementQuery),
    ]);
    if (!otherMember.exists) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        asRecipient ? "The payer is no longer in this group." : "The recipient is no longer in this group.",
      );
    }
    if (existing.exists) {
      if (existing.data().fromUid === fromUid && existing.data().toUid === toUid) return;
      throw new functions.https.HttpsError("already-exists", "Settlement ID is already used.");
    }
    if (!pending.empty) {
      throw new functions.https.HttpsError("failed-precondition", "A payment is already waiting for confirmation.");
    }
    // Replay guard. The pending check above only covers payments that have not
    // been confirmed yet, so once a payment was confirmed the same pair could
    // record and confirm an identical payment again under a fresh client-chosen
    // id, forever. A new payment for this pair is only meaningful after the
    // group's balance has actually moved, which is what the guard records.
    const currentBalanceMinor = groupData.balanceMinorUnits || 0;
    const latestMovementAt = latestMovement.docs.length
      ? latestMovement.docs[0].get("createdAt") || null
      : null;
    if (pairGuard.exists) {
      const guard = pairGuard.data();
      const balanceUnchanged =
        (guard.balanceMinorUnits || 0) === currentBalanceMinor;
      const guardAt = guard.latestMovementAt || null;
      const noNewMovement = guardAt == null || latestMovementAt == null
        ? guardAt == null && latestMovementAt == null
        : guardAt.toMillis() === latestMovementAt.toMillis();
      if (balanceUnchanged && noNewMovement) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Nothing new to settle since the last recorded payment.",
        );
      }
    }
    const currency = groupData.currency || "MAD";
    const minor = amountInMinorUnits(data.amount, currency);
    const digits = zeroDecimalCurrencies.has(currency) ? 0 : 2;
    const amount = minor / (10 ** digits);
    const callerName = memberData.displayName || "Member";
    const otherName = otherMember.data().displayName || "Member";
    const fromName = asRecipient ? otherName : callerName;
    const toName = asRecipient ? callerName : otherName;
    transaction.create(settlementRef, {
      fromUid,
      fromName,
      toUid,
      toName,
      amount,
      currency,
      status: asRecipient ? "confirmed" : "pending",
      createdAt: now,
      confirmedAt: asRecipient ? now : null,
      ...(asRecipient ? {confirmedBy: uid} : {}),
    });
    transaction.set(pairGuardRef, {
      fromUid,
      toUid,
      balanceMinorUnits: currentBalanceMinor,
      latestMovementAt,
      settlementId,
      updatedAt: now,
    }, {merge: true});
    transaction.set(groupRef, {
      settlementRevision: FieldValue.increment(1),
    }, {merge: true});
    transaction.create(groupRef.collection("audit").doc(), {
      settlementId,
      action: asRecipient ? "settlement_confirmed" : "settlement_pending",
      performedBy: uid,
      performedByName: callerName,
      timestamp: now,
      amount,
      fromUid,
      toUid,
    });
    const notificationType = asRecipient ? "settlement_confirmed" : "settlement_pending";
    transaction.create(db.collection("users").doc(otherUid)
      .collection("notifications").doc(`${notificationType}_${settlementId}`), {
        groupId: groupRef.id,
        title: asRecipient ? "Payment confirmed" : "Payment to confirm",
        body: asRecipient
          ? `${callerName} confirmed receiving ${amount} ${currency} from you.`
          : `${callerName} recorded a payment of ${amount} ${currency} to you.`,
        type: notificationType,
        actorUid: uid,
        actorName: callerName,
        createdAt: now,
        read: false,
      });
    created = true;
  });
  return {...resultTime(now), settlementId, created};
});

exports.confirmSettlement = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupRef = groupRefFrom(data.groupId);
  const settlementId = safeId(data.settlementId, "Settlement ID");
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = Timestamp.now();
  let confirmed = false;
  await db.runTransaction(async (transaction) => {
    confirmed = false;
    const {memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
      settlementRevision: FieldValue.increment(1),
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
        groupId: groupRef.id,
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
  const groupRef = groupRefFrom(data.groupId);
  const settlementId = safeId(data.settlementId, "Settlement ID");
  const settlementRef = groupRef.collection("settlements").doc(settlementId);
  const now = Timestamp.now();
  let cancelled = false;
  await db.runTransaction(async (transaction) => {
    cancelled = false;
    const {memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
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
    // A cancelled payment must not leave the replay guard behind, otherwise
    // the pair could never record a legitimate payment again.
    transaction.delete(
      groupRef.collection("settlementGuards")
        .doc(settlementPairKey(payment.fromUid, payment.toUid)),
    );
    transaction.set(groupRef, {
      settlementRevision: FieldValue.increment(1),
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
        groupId: groupRef.id,
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

const RECURRING_FREQUENCIES = new Set(["weekly", "monthly"]);
const MAX_ACTIVE_RECURRING_PER_GROUP = 50;
const MAX_FIRST_RUN_AHEAD_MS = 400 * 24 * 60 * 60 * 1000;

/**
 * Next run after [from]. Monthly rules keep their original day of the month
 * (clamped to shorter months), so a rule set on the 31st does not drift to
 * the 28th forever after February.
 */
function nextOccurrence(from, frequency, anchorDay) {
  if (frequency === "weekly") {
    return new Date(from.getTime() + 7 * 24 * 60 * 60 * 1000);
  }
  const year = from.getUTCFullYear();
  const month = from.getUTCMonth() + 1;
  const lastDay = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
  return new Date(Date.UTC(
    year,
    month,
    Math.min(anchorDay, lastDay),
    from.getUTCHours(),
    from.getUTCMinutes(),
  ));
}

exports.createRecurring = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupRef = groupRefFrom(data.groupId);
  const recurringId = safeId(data.recurringId, "Recurring ID");
  const frequency = data.frequency;
  if (!RECURRING_FREQUENCIES.has(frequency)) {
    throw new functions.https.HttpsError("invalid-argument", "Frequency is invalid.");
  }
  const firstRunMillis = Number(data.firstRunAtMillis);
  const nowMillis = Date.now();
  if (!Number.isFinite(firstRunMillis) || firstRunMillis < nowMillis - 60 * 1000 ||
      firstRunMillis > nowMillis + MAX_FIRST_RUN_AHEAD_MS) {
    throw new functions.https.HttpsError("invalid-argument", "First run date is invalid.");
  }
  const ruleRef = groupRef.collection("recurring").doc(recurringId);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData, memberData} = await getGroupAndMember(transaction, groupRef.id, uid);
    const [existing, active] = await Promise.all([
      transaction.get(ruleRef),
      transaction.get(groupRef.collection("recurring")
        .where("active", "==", true)
        .limit(MAX_ACTIVE_RECURRING_PER_GROUP)),
    ]);
    if (existing.exists) {
      if (existing.data().createdBy === uid) return;
      throw new functions.https.HttpsError("already-exists", "Recurring ID is already used.");
    }
    if (active.size >= MAX_ACTIVE_RECURRING_PER_GROUP) {
      throw new functions.https.HttpsError("resource-exhausted", "Too many recurring movements in this caisse.");
    }
    const currency = groupData.currency || "MAD";
    signedMinor(data, currency);
    const amountMinor = amountInMinorUnits(data.amount, currency);
    const split = groupData.isPersonal === true
      ? null
      : await parseSplit(transaction, groupRef, data.split, amountMinor, currency);
    const displayName = inputString(data.displayName, "Display name", 80, false) ||
      memberData.displayName || "Member";
    transaction.create(ruleRef, {
      type: data.type,
      amount: amountMinor / minorFactor(currency),
      title: inputString(data.title, "Title", 120),
      category: inputString(data.category, "Category", 60),
      split,
      frequency,
      anchorDay: new Date(firstRunMillis).getUTCDate(),
      nextRunAt: Timestamp.fromMillis(firstRunMillis),
      active: true,
      createdBy: uid,
      createdByName: displayName,
      createdAt: now,
      lastRunAt: null,
      lastError: null,
    });
  });
  return {...resultTime(now), recurringId};
});

exports.deleteRecurring = functions.region("us-central1").https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const groupRef = groupRefFrom(data.groupId);
  const recurringId = safeId(data.recurringId, "Recurring ID");
  const ruleRef = groupRef.collection("recurring").doc(recurringId);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const {groupData} = await getGroupAndMember(transaction, groupRef.id, uid);
    const snap = await transaction.get(ruleRef);
    if (!snap.exists) return;
    if (snap.data().createdBy !== uid && groupData.createdBy !== uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the person who set it up or the caisse creator can stop it.",
      );
    }
    transaction.delete(ruleRef);
  });
  return resultTime(now);
});

const RECURRING_FAILURE_COPY = {
  insufficient_balance: "the caisse did not hold enough money",
  split_invalid: "someone in its split has left the caisse",
};

async function runRecurringRule(ruleRef) {
  const groupRef = ruleRef.parent.parent;
  if (!groupRef) return false;
  const now = Timestamp.now();
  let outcome = null;
  await db.runTransaction(async (transaction) => {
    outcome = null;
    const ruleSnap = await transaction.get(ruleRef);
    if (!ruleSnap.exists) return;
    const rule = ruleSnap.data();
    if (rule.active !== true || !rule.nextRunAt ||
        rule.nextRunAt.toMillis() > now.toMillis()) {
      return;
    }
    const [groupSnap, creatorSnap] = await Promise.all([
      transaction.get(groupRef),
      transaction.get(groupRef.collection("members").doc(rule.createdBy)),
    ]);
    if (!groupSnap.exists || !creatorSnap.exists) {
      transaction.update(ruleRef, {active: false, lastError: "creator_left", lastRunAt: now});
      return;
    }
    const runAt = rule.nextRunAt.toDate();
    const nextRunAt = Timestamp.fromDate(nextOccurrence(
      runAt,
      rule.frequency,
      Number.isInteger(rule.anchorDay) ? rule.anchorDay : runAt.getUTCDate(),
    ));
    const groupData = groupSnap.data();
    const currency = groupData.currency || "MAD";
    let amountMinor;
    let split;
    try {
      amountMinor = amountInMinorUnits(rule.amount, currency);
      split = groupData.isPersonal === true || rule.split == null
        ? null
        : await parseSplit(transaction, groupRef, rule.split, amountMinor, currency);
    } catch (error) {
      transaction.update(ruleRef, {nextRunAt, lastRunAt: now, lastError: "split_invalid"});
      outcome = {failed: "split_invalid", rule};
      return;
    }
    const delta = rule.type === "expense" ? -amountMinor : amountMinor;
    const balance = await balanceMinorInTransaction(transaction, groupRef, groupData);
    if (balance + delta < 0) {
      transaction.update(ruleRef, {nextRunAt, lastRunAt: now, lastError: "insufficient_balance"});
      outcome = {failed: "insufficient_balance", rule};
      return;
    }
    const name = creatorSnap.data().displayName || rule.createdByName || "Member";
    const movementRef = groupRef.collection("movements").doc();
    const movement = {
      type: rule.type === "expense" ? "expense" : "deposit",
      amount: amountMinor / minorFactor(currency),
      title: rule.title,
      category: rule.category,
      createdBy: rule.createdBy,
      createdByName: name,
      createdAt: now,
      updatedAt: now,
      updatedBy: rule.createdBy,
      updatedByName: name,
      receiptUrl: null,
      deleted: false,
      deletedAt: null,
      isStartingBalance: false,
      split,
      originalCurrency: null,
      originalAmount: null,
      exchangeRate: null,
      recurringId: ruleRef.id,
    };
    transaction.create(movementRef, movement);
    transaction.set(groupRef, {balanceMinorUnits: balance + delta}, {merge: true});
    auditWrite(transaction, groupRef, movementRef.id, "create", rule.createdBy, name, null, movement, now);
    transaction.update(ruleRef, {nextRunAt, lastRunAt: now, lastError: null});
    outcome = {created: true};
  });
  if (outcome && outcome.failed) {
    const {rule, failed} = outcome;
    await db.collection("users").doc(rule.createdBy).collection("notifications")
      .doc(`recurring_failed_${ruleRef.id}_${now.toMillis()}`)
      .set({
        groupId: groupRef.id,
        title: "Recurring movement skipped",
        body: `"${rule.title}" was not added because ${RECURRING_FAILURE_COPY[failed]}.`,
        type: "recurring_failed",
        actorUid: rule.createdBy,
        actorName: rule.createdByName || "Member",
        createdAt: now,
        read: false,
      })
      .catch((error) => console.error("recurring failure notice failed", ruleRef.path, error));
  }
  return outcome != null && outcome.created === true;
}

exports.runRecurringMovements = functions.region("us-central1")
  .runWith({timeoutSeconds: 300, memory: "256MB"})
  .pubsub.schedule("every 60 minutes")
  .timeZone("Etc/UTC")
  .onRun(async () => {
    const due = await db.collectionGroup("recurring")
      .where("active", "==", true)
      .where("nextRunAt", "<=", Timestamp.now())
      .limit(200)
      .get();
    let created = 0;
    for (const doc of due.docs) {
      try {
        if (await runRecurringRule(doc.ref)) created++;
      } catch (error) {
        console.error("recurring run failed", doc.ref.path, error);
      }
    }
    console.log(`Recurring movements: ${created} created from ${due.size} due rules`);
    return created;
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
          createdAt: FieldValue.serverTimestamp(),
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
          createdAt: FieldValue.serverTimestamp(),
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
    await getStorage().bucket().deleteFiles({prefix: `users/${uid}/`});
    await db.collection("users").doc(uid).delete();
    await getAuth().deleteUser(uid);
    return {deleted: true};
  });
