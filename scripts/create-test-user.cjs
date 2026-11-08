/**
 * Creates (or resets) a throwaway Firebase Auth account for integration tests.
 *
 * The integration suite needs a real account to exercise the callables and
 * Firestore rules. Rather than hard-coding a password in the repository, one is
 * generated here and printed once. Pass it to the test run:
 *
 *   node scripts/create-test-user.cjs
 *   flutter test integration_test -d <device-id> \
 *     --dart-define=UITEST_EMAIL=... --dart-define=UITEST_PASSWORD=...
 *
 * Reuses the Firebase CLI session (see _auth.cjs) so no separate service
 * account is needed.
 */

const crypto = require("crypto");
const { useFirebaseCliCredentials, requireAdmin } = require("./_auth.cjs");

async function main() {
  const email = process.argv[2] || "encaisse.uitest3@gmail.com";
  const password =
    process.argv[3] ||
    crypto.randomBytes(18).toString("base64url") + "aA1!";

  useFirebaseCliCredentials();
  const admin = requireAdmin();
  const projectId = process.env.GCLOUD_PROJECT || "encaisse-3c7fb";
  if (admin.apps.length === 0) admin.initializeApp({ projectId });

  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(user.uid, {
      password,
      emailVerified: true,
    });
    console.log("reset existing user");
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    user = await admin.auth().createUser({
      email,
      password,
      emailVerified: true,
      displayName: "Integration Tester",
    });
    console.log("created new user");
  }

  console.log("EMAIL=" + email);
  console.log("PASSWORD=" + password);
  console.log("UID=" + user.uid);
}

main().then(
  () => process.exit(0),
  (error) => {
    console.error("failed:", error.message || error);
    process.exit(1);
  }
);