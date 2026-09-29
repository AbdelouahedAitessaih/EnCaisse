/**
 * Backfill so existing users pick up the new "helpful reminders on by default"
 * behaviour.
 *
 * The app now creates every new user doc with remindersEnabled = true, and the
 * reminder job queries `where("remindersEnabled", "==", true)`. Users created
 * before that change have the field set to false (or missing entirely), so the
 * query never returns them and they would keep receiving no reminders.
 *
 * This sets the field explicitly to true for those users, which is what makes
 * them eligible. Anyone who has explicitly turned reminders OFF in the app
 * would be re-enabled by this, so review the dry-run output first.
 *
 * Usage (requires `firebase login` on this machine):
 *   1. Preview:  node scripts/enable-reminders-default.cjs
 *   2. Apply:    node scripts/enable-reminders-default.cjs --apply
 *
 * To only enable reminders for accounts that have never made a choice, pass
 * --unset-only, which leaves an existing explicit false alone. Note that before
 * the default flipped, every new user doc was written with an explicit false,
 * so an explicit false is not a reliable signal that someone opted out.
 */

const { useFirebaseCliCredentials, requireAdmin } = require("./_auth.cjs");

const PROJECT_ID = process.env.GCLOUD_PROJECT || "encaisse-3c7fb";
const APPLY = process.argv.includes("--apply");
const UNSET_ONLY = process.argv.includes("--unset-only");

useFirebaseCliCredentials();
const admin = requireAdmin();
admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

(async () => {
  console.log(`Project: ${PROJECT_ID}`);
  console.log(
    `Mode:    ${APPLY ? "APPLY (will write)" : "dry run, nothing will be written"}` +
      `${UNSET_ONLY ? " | --unset-only (skip explicit false)" : ""}\n`
  );

  const users = await db.collection("users").get();
  const targets = [];

  for (const doc of users.docs) {
    const data = doc.data() || {};
    const current = data.remindersEnabled;

    if (current === true) continue;
    if (UNSET_ONLY && current === false) continue;

    targets.push({
      ref: doc.ref,
      uid: doc.id,
      email: data.email || "(no email)",
      current: current === undefined ? "missing" : current,
    });
  }

  if (targets.length === 0) {
    console.log("No user docs need updating.");
    process.exit(0);
  }

  console.log(`${targets.length} user doc(s) will get remindersEnabled = true:\n`);
  for (const t of targets) {
    console.log(`  ${t.uid}  ${t.email}  (current: ${t.current})`);
  }

  if (!APPLY) {
    console.log("\nRe-run with --apply to write these changes.");
    process.exit(0);
  }

  let batch = db.batch();
  let ops = 0;
  for (const t of targets) {
    batch.set(t.ref, { remindersEnabled: true }, { merge: true });
    ops++;
    if (ops >= 400) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }
  if (ops > 0) await batch.commit();

  console.log(`\nUpdated ${targets.length} user doc(s).`);
})();
