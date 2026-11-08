/**
 * Credential helper for the maintenance scripts.
 *
 * These scripts need Firestore admin access. Rather than requiring a separate
 * `gcloud auth application-default login`, this reuses the Firebase CLI session
 * that is already logged in on this machine: the CLI stores a refresh token in
 * its configstore, and this turns it into a temporary authorized-user
 * credentials file that the firebase-admin SDK understands natively.
 *
 * The client id/secret below are the Firebase CLI's own public installed-app
 * credentials (the same constants firebase-tools ships and uses itself), so no
 * project-specific secret is involved.
 *
 * The credentials file is written to the OS temp directory and removed on exit.
 */

const fs = require("fs");
const os = require("os");
const path = require("path");

const CONFIGSTORE = path.join(
  os.homedir(),
  ".config",
  "configstore",
  "firebase-tools.json"
);

const CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

let tempFile = null;

/** Point GOOGLE_APPLICATION_CREDENTIALS at a file built from the CLI session. */
function useFirebaseCliCredentials() {
  if (!fs.existsSync(CONFIGSTORE)) {
    throw new Error(
      `Firebase CLI configstore not found at ${CONFIGSTORE}.\n` +
        "Run `firebase login` first."
    );
  }

  const store = JSON.parse(fs.readFileSync(CONFIGSTORE, "utf8"));
  const refreshToken = store && store.tokens && store.tokens.refresh_token;
  if (!refreshToken) {
    throw new Error(
      "No refresh token in the Firebase CLI session. Run `firebase login` first."
    );
  }

  tempFile = path.join(
    os.tmpdir(),
    `encaisse-adc-${process.pid}-${Date.now()}.json`
  );
  fs.writeFileSync(
    tempFile,
    JSON.stringify(
      {
        type: "authorized_user",
        client_id: CLI_CLIENT_ID,
        client_secret: CLI_CLIENT_SECRET,
        refresh_token: refreshToken,
      },
      null,
      2
    ),
    { encoding: "utf8", mode: 0o600 }
  );

  process.env.GOOGLE_APPLICATION_CREDENTIALS = tempFile;
  return tempFile;
}

function cleanup() {
  if (tempFile && fs.existsSync(tempFile)) {
    try {
      fs.unlinkSync(tempFile);
    } catch (_error) {
      /* best effort */
    }
    tempFile = null;
  }
}

process.on("exit", cleanup);

/**
 * firebase-admin resolved from the functions workspace, exposed through the
 * namespaced surface the scripts use (`admin.auth()`, `admin.firestore()`…).
 * The functions workspace ships the modular SDK, whose root export no longer
 * carries those accessors.
 */
function requireAdmin() {
  const root = path.join(__dirname, "..", "functions", "node_modules", "firebase-admin");
  const app = require(path.join(root, "lib", "app"));
  return {
    get apps() {
      return app.getApps();
    },
    initializeApp: (options) => app.initializeApp(options),
    auth: () => require(path.join(root, "lib", "auth")).getAuth(),
    firestore: () => require(path.join(root, "lib", "firestore")).getFirestore(),
    storage: () => require(path.join(root, "lib", "storage")).getStorage(),
  };
}

module.exports = { useFirebaseCliCredentials, requireAdmin, cleanup };
