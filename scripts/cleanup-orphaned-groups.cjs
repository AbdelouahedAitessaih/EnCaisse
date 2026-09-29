/**
 * Cleanup tool for groups orphaned by the failed `deleteGroup` bug.
 *
 * The bug deleted the member docs first, then threw because the
 * `memberships` collection-group index was missing. The group document,
 * movements, audit, settlements, storage objects and invite code were left
 * behind with no way for the owner to retry: the app has already lost read
 * access to the group, so `deleteGroup` can no longer be called for it.
 *
 * This script finds those orphans and (with --apply) removes them.
 *
 * Usage (requires `firebase login` on this machine):
 *   1. Preview (read only):  node scripts/cleanup-orphaned-groups.cjs
 *   2. Actually delete:      node scripts/cleanup-orphaned-groups.cjs --apply
 *
 * Optional: set STORAGE_BUCKET if receipts live outside the default bucket.
 */

const { useFirebaseCliCredentials, requireAdmin } = require("./_auth.cjs");

const PROJECT_ID = process.env.GCLOUD_PROJECT || "encaisse-3c7fb";
// Leave unset to use the SDK's default bucket resolution, which matches what
// the deleteGroup function does. Override only if receipts live elsewhere.
const STORAGE_BUCKET = process.env.STORAGE_BUCKET || "";
const APPLY = process.argv.includes("--apply");

useFirebaseCliCredentials();
const admin = requireAdmin();
admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

/** Receipts bucket, resolved the same way the Cloud Function resolves it. */
function receiptsBucket() {
  return STORAGE_BUCKET
    ? admin.storage().bucket(STORAGE_BUCKET)
    : admin.storage().bucket();
}

/** A group is orphaned when the group doc survives but its members are gone. */
async function findOrphans() {
  const groups = await db.collection("groups").get();
  const orphans = [];

  for (const group of groups.docs) {
    const data = group.data() || {};
    const members = await group.ref.collection("members").get();

    // Intact groups always have at least one member doc.
    if (members.size > 0) continue;

    // Confirm the owner's membership pointer is gone too, so we never touch a
    // group that simply has no members for some other reason.
    const creator = data.createdBy;
    if (typeof creator !== "string") continue;
    const membership = await db
      .collection("users")
      .doc(creator)
      .collection("memberships")
      .doc(group.id)
      .get();
    if (membership.exists) continue;

    const movements = await group.ref.collection("movements").get();
    orphans.push({
      ref: group.ref,
      id: group.id,
      name: data.name,
      isPersonal: data.isPersonal === true,
      createdBy: creator,
      inviteCode: data.inviteCode,
      movements: movements.size,
      createdAt: data.createdAt && data.createdAt.toDate
        ? data.createdAt.toDate().toISOString()
        : "unknown",
    });
  }

  return orphans;
}

async function deleteOrphan(orphan) {
  const { ref, id } = orphan;

  const movements = await ref.collection("movements").get();
  for (const movement of movements.docs) {
    await deleteQuery(ref.collection("audit").where("movementId", "==", movement.id));
    await movement.ref.delete();
  }
  await deleteQuery(ref.collection("audit"));
  await deleteQuery(ref.collection("settlements"));

  await receiptsBucket()
    .deleteFiles({ prefix: `groups/${id}/` })
    .catch((e) => console.warn(`  storage cleanup skipped: ${e.message}`));

  if (typeof orphan.inviteCode === "string") {
    await db.collection("inviteCodes").doc(orphan.inviteCode).delete().catch(() => {});
  }
  await ref.delete();
}

async function deleteQuery(query) {
  while (true) {
    const snap = await query.limit(400).get();
    if (snap.empty) return;
    const batch = db.batch();
    for (const doc of snap.docs) batch.delete(doc.ref);
    await batch.commit();
    if (snap.size < 400) return;
  }
}

(async () => {
  console.log(`Project: ${PROJECT_ID}`);
  console.log(`Mode:    ${APPLY ? "APPLY (destructive)" : "dry run, nothing will be deleted"}\n`);

  const orphans = await findOrphans();
  if (orphans.length === 0) {
    console.log("No orphaned groups found. Nothing to do.");
    process.exit(0);
  }

  console.log(`Found ${orphans.length} orphaned group(s):\n`);
  for (const o of orphans) {
    console.log(`  id        ${o.id}`);
    console.log(`  name      ${o.name}${o.isPersonal ? " (personal)" : ""}`);
    console.log(`  created   ${o.createdAt} by ${o.createdBy}`);
    console.log(`  movements ${o.movements}`);
    console.log(`  invite    ${o.inviteCode || "none"}`);
    console.log("");
  }

  if (!APPLY) {
    console.log("Re-run with --apply to permanently delete the groups listed above.");
    process.exit(0);
  }

  for (const o of orphans) {
    process.stdout.write(`Deleting ${o.id} (${o.name})... `);
    try {
      await deleteOrphan(o);
      console.log("done");
    } catch (e) {
      console.log(`FAILED: ${e.message}`);
    }
  }
  console.log("\nFinished.");
})();
