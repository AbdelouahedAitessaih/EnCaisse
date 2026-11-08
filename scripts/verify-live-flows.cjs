/**
 * Live verification of the deployed callable functions.
 *
 * This talks to the real Cloud Functions over HTTPS with real ID tokens, the
 * same transport lib/services/backend_service.dart uses, so it exercises the
 * deployed code rather than the emulator. Callers are authenticated with a
 * custom token minted by the Admin SDK, which avoids storing any test account
 * password on this machine.
 *
 * Every group it creates is deleted again before the script exits, and the one
 * rate-limit counter it touches is reset first, so a run leaves no residue.
 *
 * Usage: node scripts/verify-live-flows.cjs
 */

const { useFirebaseCliCredentials, requireAdmin } = require("./_auth.cjs");

const PROJECT_ID = "encaisse-3c7fb";
const REGION = "us-central1";
const API_KEY = "AIzaSyDc3DcjdOEjSNiKp9w5oEJJzQVtxMql88o";
const BASE = `https://${REGION}-${PROJECT_ID}.cloudfunctions.net`;
/**
 * The run uses two throwaway accounts rather than the QA accounts, because the
 * QA accounts are signed in on the physical test device and resetting a
 * password to get a token would lock that device out. These accounts are
 * deleted before the script exits.
 */
const EPHEMERAL_DOMAIN = "verify.invalid";
const results = [];
let admin;
const db = () => admin.firestore();

function record(name, ok, detail) {
  results.push({name, ok, detail});
  console.log(`${ok ? "PASS" : "FAIL"}  ${name}${detail ? ` — ${detail}` : ""}`);
}

function randomSecret() {
  return require("crypto").randomBytes(18).toString("hex");
}

async function createEphemeralUser(role) {
  const email = `verify-${role}-${randomSecret().slice(0, 12)}@${EPHEMERAL_DOMAIN}`;
  const password = randomSecret();
  const user = await admin.auth().createUser({email, password, emailVerified: true});
  return {uid: user.uid, email, password};
}

async function idTokenFor(email, password) {
  const response = await fetch(
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword" +
      `?key=${API_KEY}`,
    {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({email, password, returnSecureToken: true}),
    }
  );
  const body = await response.json();
  if (!body.idToken) throw new Error(`sign-in failed: ${JSON.stringify(body)}`);
  return body.idToken;
}

/** Call a deployed callable the way the Flutter client does. */
async function call(name, token, data) {
  const response = await fetch(`${BASE}/${name}`, {
    method: "POST",
    headers: {"Authorization": `Bearer ${token}`, "Content-Type": "application/json"},
    body: JSON.stringify({data}),
  });
  const body = await response.json();
  if (body.error) {
    // The callable envelope returns the status uppercased ("INVALID_ARGUMENT").
    return {
      ok: false,
      code: String(body.error.status || "unknown").toLowerCase(),
      message: body.error.message,
    };
  }
  return {ok: true, result: body.result};
}

async function main() {
  useFirebaseCliCredentials();
  admin = requireAdmin();
  if (admin.apps.length === 0) admin.initializeApp({projectId: PROJECT_ID});

  const caller = await createEphemeralUser("caller");
  const partner = await createEphemeralUser("partner");
  const callerUid = caller.uid;
  const partnerUid = partner.uid;
  const callerToken = await idTokenFor(caller.email, caller.password);
  const partnerToken = await idTokenFor(partner.email, partner.password);
  console.log(`caller  ${caller.email} ${callerUid}`);
  console.log(`partner ${partner.email} ${partnerUid}\n`);

  const createdGroups = [];
  const stamp = Date.now();

  try {
    // 1. createGroup still works and now seeds a member count.
    const created = await call("createGroup", callerToken, {
      name: `verify-live-${stamp}`,
      displayName: "Caller",
      currency: "MAD",
      startingAmount: 100,
    });
    if (!created.ok) throw new Error(`createGroup failed: ${JSON.stringify(created)}`);
    const groupId = created.result.id;
    const inviteCode = created.result.inviteCode;
    createdGroups.push(groupId);
    const groupDoc = await db().collection("groups").doc(groupId).get();
    record(
      "createGroup issues a well-formed invite code and seeds memberCount",
      /^[A-HJ-NP-Z2-9]{6}$/.test(inviteCode) && groupDoc.get("memberCount") === 1,
      `code=${inviteCode} memberCount=${groupDoc.get("memberCount")}`
    );

    // 2. A malformed code is refused before any lookup happens.
    const malformed = await call("joinGroup", partnerToken, {inviteCode: "not-a-code"});
    record(
      "joinGroup rejects a malformed invite code",
      !malformed.ok && malformed.code === "invalid_argument",
      `${malformed.code}: ${malformed.message}`
    );

    // 3. A well-formed code that resolves to nothing is a clean not-found, and
    //    the legacy fallback query does not turn it into an internal error.
    const missing = await call("joinGroup", partnerToken, {inviteCode: "ZZZZZZ"});
    record(
      "joinGroup returns not-found for an unknown code",
      !missing.ok && missing.code === "not_found",
      `${missing.code}: ${missing.message}`
    );

    // 4. Personal caisses are refused even though they have a valid code.
    const personal = await call("createGroup", callerToken, {
      name: `verify-live-personal-${stamp}`,
      displayName: "Caller",
      currency: "MAD",
      isPersonal: true,
    });
    if (!personal.ok) throw new Error(`createGroup personal failed: ${JSON.stringify(personal)}`);
    createdGroups.push(personal.result.id);
    const personalJoin = await call("joinGroup", partnerToken, {
      inviteCode: personal.result.inviteCode,
    });
    record(
      "joinGroup refuses a personal caisse",
      !personalJoin.ok && personalJoin.code === "failed_precondition",
      `${personalJoin.code}: ${personalJoin.message}`
    );

    // 5. A second member can join a shared group.
    const joined = await call("joinGroup", partnerToken, {
      inviteCode,
      displayName: "Partner",
    });
    record("joinGroup admits a second member", joined.ok, joined.ok ? "" : JSON.stringify(joined));

    // 6. Movements work.
    const deposit = await call("createMovement", callerToken, {
      groupId,
      movementId: `verify-deposit-${stamp}`,
      type: "deposit",
      amount: 100,
      title: "verify deposit",
      category: "Other",
      createdBy: callerUid,
      createdByName: "Caller",
    });
    record("createMovement accepts a deposit", deposit.ok, deposit.ok ? "" : JSON.stringify(deposit));

    // 7. Self-settlement and a payer that is not the caller are refused.
    const selfPay = await call("recordSettlement", callerToken, {
      groupId,
      settlementId: `verify-self-${stamp}`,
      fromUid: callerUid,
      toUid: callerUid,
      amount: 10,
    });
    record(
      "recordSettlement refuses a self-settlement",
      !selfPay.ok && selfPay.code === "invalid_argument",
      `${selfPay.code}: ${selfPay.message}`
    );
    const spoofPay = await call("recordSettlement", partnerToken, {
      groupId,
      settlementId: `verify-spoof-${stamp}`,
      fromUid: callerUid,
      toUid: partnerUid,
      amount: 10,
    });
    record(
      "recordSettlement pins the payer to the caller",
      !spoofPay.ok && spoofPay.code === "invalid_argument",
      `${spoofPay.code}: ${spoofPay.message}`
    );

    // 8. The replay guard refuses a second identical payment for the same pair.
    const firstPay = await call("recordSettlement", callerToken, {
      groupId,
      settlementId: `verify-pay-1-${stamp}`,
      fromUid: callerUid,
      toUid: partnerUid,
      amount: 50,
    });
    record("recordSettlement accepts a first payment", firstPay.ok, firstPay.ok ? "" : JSON.stringify(firstPay));

    // The pending check only covers unconfirmed payments, so the first payment
    // is confirmed before the replay is attempted. Otherwise the pending
    // check answers first and the guard is never reached.
    const confirmFirst = await call("confirmSettlement", partnerToken, {
      groupId,
      settlementId: `verify-pay-1-${stamp}`,
    });
    record(
      "confirmSettlement accepts the recipient",
      confirmFirst.ok,
      confirmFirst.ok ? "" : JSON.stringify(confirmFirst)
    );

    const replay = await call("recordSettlement", callerToken, {
      groupId,
      settlementId: `verify-pay-2-${stamp}`,
      fromUid: callerUid,
      toUid: partnerUid,
      amount: 50,
    });
    record(
      "recordSettlement replay guard refuses an identical repeat payment",
      !replay.ok &&
        replay.code === "failed_precondition" &&
        /nothing new to settle/i.test(replay.message || ""),
      `${replay.code}: ${replay.message}`
    );

    // 9. A fresh movement makes the pair settleable again. This is the case the
    //    balance-only guard used to block when the balance returned to its
    //    previous value.
    const expense = await call("createMovement", callerToken, {
      groupId,
      movementId: `verify-expense-${stamp}`,
      type: "expense",
      amount: 10,
      title: "verify expense",
      category: "Other",
      createdBy: callerUid,
      createdByName: "Caller",
    });
    const secondPay = await call("recordSettlement", callerToken, {
      groupId,
      settlementId: `verify-pay-3-${stamp}`,
      fromUid: callerUid,
      toUid: partnerUid,
      amount: 50,
    });
    record(
      "a new movement re-enables settlement for the same pair",
      expense.ok && secondPay.ok,
      expense.ok ? (secondPay.ok ? "" : JSON.stringify(secondPay)) : JSON.stringify(expense)
    );

    // 10. Confirmation is recipient-only.
    const selfConfirm = await call("confirmSettlement", callerToken, {
      groupId,
      settlementId: `verify-pay-3-${stamp}`,
    });
    record(
      "confirmSettlement refuses the payer",
      !selfConfirm.ok,
      `${selfConfirm.code}: ${selfConfirm.message}`
    );
    const confirmed = await call("confirmSettlement", partnerToken, {
      groupId,
      settlementId: `verify-pay-3-${stamp}`,
    });
    record(
      "confirmSettlement accepts the recipient for a second payment",
      confirmed.ok,
      confirmed.ok ? "" : JSON.stringify(confirmed)
    );
    const guardCount = (
      await db().collection("groups").doc(groupId).collection("settlementGuards").get()
    ).size;
    record(
      "the replay guard document is server-only and recorded once per pair",
      guardCount === 1,
      `settlementGuards=${guardCount}`
    );

    // 11. A non-creator cannot delete the group.
    const foreignDelete = await call("deleteGroup", partnerToken, {groupId});
    record(
      "deleteGroup refuses a non-creator",
      !foreignDelete.ok,
      `${foreignDelete.code}: ${foreignDelete.message}`
    );

    // 12. The creator can, and the group document is actually gone.
    const deleted = await call("deleteGroup", callerToken, {groupId});
    const gone = !(await db().collection("groups").doc(groupId).get()).exists;
    record(
      "deleteGroup removes the group document for its creator",
      deleted.ok && gone,
      deleted.ok ? `groupRemoved=${gone}` : JSON.stringify(deleted)
    );
    createdGroups.splice(createdGroups.indexOf(groupId), 1);

    // 13. Rate limiting trips for the partner, who has spent attempts above.
    const codes = [];
    for (let attempt = 0; attempt < 14; attempt++) {
      const attemptResult = await call("joinGroup", partnerToken, {inviteCode: "ZZZZZZ"});
      codes.push(attemptResult.ok ? "ok" : attemptResult.code);
    }
    record(
      "joinGroup rate limits repeated attempts",
      codes.includes("resource_exhausted") &&
        codes.lastIndexOf("not_found") < codes.indexOf("resource_exhausted"),
      codes.join(",")
    );
    await db().collection("rateLimits").doc(`join_${partnerUid}`).delete();
  } finally {
    for (const id of createdGroups) {
      const removed = await call("deleteGroup", callerToken, {groupId: id});
      if (!removed.ok) console.log(`cleanup: could not delete ${id} (${removed.code})`);
    }
    for (const uid of [callerUid, partnerUid]) {
      for (const doc of [`join_${uid}`, `create_${uid}`]) {
        await db().collection("rateLimits").doc(doc).delete().catch(() => {});
      }
      await admin.auth().deleteUser(uid).catch(() => {});
    }
  }

  const failed = results.filter((r) => !r.ok);
  console.log(`\n${results.length - failed.length}/${results.length} live checks passed`);
  process.exit(failed.length === 0 ? 0 : 1);
}

main().catch((error) => {
  console.error("verify-live-flows failed:", error);
  process.exit(1);
});
