/**
 * Demo data for Play Store screenshots.
 *
 * Creates throwaway member accounts and a showcase group through the deployed
 * callables (the same path the app uses), so the screens show real splits,
 * a foreign-currency expense and a "who owes whom" summary without exposing
 * anyone's actual groups.
 *
 *   node scripts/store-demo.cjs seed              # creates members + group, prints invite code
 *   (join the code from the phone)
 *   node scripts/store-demo.cjs fill <email>      # adds movements, splitting with that account
 *   node scripts/store-demo.cjs cleanup           # deletes the group, members and their data
 *
 * State (ids and throwaway passwords) lives in the OS temp directory between
 * `seed` and `fill`. `cleanup` finds the demo accounts by email instead.
 */

const fs = require("fs");
const os = require("os");
const path = require("path");
const crypto = require("crypto");
const { useFirebaseCliCredentials, requireAdmin } = require("./_auth.cjs");

const PROJECT_ID = "encaisse-3c7fb";
const BASE = `https://us-central1-${PROJECT_ID}.cloudfunctions.net`;
const API_KEY = "AIzaSyDc3DcjdOEjSNiKp9w5oEJJzQVtxMql88o";
const STATE_FILE = path.join(os.tmpdir(), "encaisse-store-demo.json");

const MEMBERS = [
  { key: "sara", name: "Sara" },
  { key: "youssef", name: "Youssef" },
  { key: "lina", name: "Lina" },
];

let admin;

function loadState() {
  if (!fs.existsSync(STATE_FILE)) return null;
  return JSON.parse(fs.readFileSync(STATE_FILE, "utf8"));
}

function saveState(state) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2), { mode: 0o600 });
}

async function idToken(email, password) {
  const response = await fetch(
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword" +
      `?key=${API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    }
  );
  const body = await response.json();
  if (!body.idToken) throw new Error(`sign-in failed for ${email}`);
  return body.idToken;
}

async function call(name, token, data) {
  const response = await fetch(`${BASE}/${name}`, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify({ data }),
  });
  const body = await response.json();
  if (body.error) {
    throw new Error(`${name}: ${body.error.status} ${body.error.message}`);
  }
  return body.result;
}

async function tokens(state) {
  const out = {};
  for (const m of state.members) out[m.key] = await idToken(m.email, m.password);
  return out;
}

async function seed() {
  if (loadState()) throw new Error("Demo already seeded; run cleanup first.");
  const state = { members: [], groupId: null, inviteCode: null };
  saveState(state);
  for (const m of MEMBERS) {
    const email = `store-${m.key}-${crypto.randomBytes(4).toString("hex")}@demo.invalid`;
    const password = crypto.randomBytes(18).toString("hex");
    const user = await admin.auth().createUser({
      email,
      password,
      emailVerified: true,
      displayName: m.name,
    });
    await admin.firestore().collection("users").doc(user.uid).set({
      displayName: m.name,
      email,
    }, { merge: true });
    state.members.push({ ...m, uid: user.uid, email, password });
    saveState(state);
  }

  const t = await tokens(state);
  const group = await call("createGroup", t.sara, {
    name: "Chefchaouen trip",
    displayName: "Sara",
    currency: "MAD",
  });
  state.groupId = group.id;
  state.inviteCode = group.inviteCode;
  saveState(state);
  for (const key of ["youssef", "lina"]) {
    const name = state.members.find((m) => m.key === key).name;
    await call("joinGroup", t[key], { inviteCode: group.inviteCode, displayName: name });
  }
  console.log(`INVITE_CODE=${group.inviteCode}`);
}

function equal(amount, uids) {
  const cents = Math.round(amount * 100);
  const base = Math.floor(cents / uids.length);
  let rest = cents - base * uids.length;
  const split = {};
  for (const uid of uids) {
    split[uid] = (base + (rest-- > 0 ? 1 : 0)) / 100;
  }
  return split;
}

async function fill(email) {
  const state = loadState();
  if (!state || !state.groupId) throw new Error("Run seed first.");
  const owner = await admin.auth().getUserByEmail(email);
  const member = await admin.firestore()
    .collection("groups").doc(state.groupId)
    .collection("members").doc(owner.uid).get();
  if (!member.exists) throw new Error("Join the group from the phone first.");

  const t = await tokens(state);
  const uid = Object.fromEntries(state.members.map((m) => [m.key, m.uid]));
  const everyone = [uid.sara, uid.youssef, uid.lina, owner.uid];
  const stamp = Date.now();
  let n = 0;
  const add = (key, payload) => call("createMovement", t[key], {
    groupId: state.groupId,
    movementId: `demo-${stamp}-${n++}`,
    createdBy: uid[key],
    createdByName: state.members.find((m) => m.key === key).name,
    ...payload,
  });

  await add("sara", { type: "deposit", amount: 2000, title: "Trip fund", category: "Other" });
  await add("youssef", { type: "deposit", amount: 2000, title: "Trip fund", category: "Other" });
  await add("lina", { type: "deposit", amount: 1500, title: "Trip fund", category: "Other" });
  await add("sara", {
    type: "expense",
    amount: 1308,
    title: "Riad booking",
    category: "Travel",
    split: equal(1308, everyone),
    original: { currency: "EUR", amount: 120, rate: 10.9 },
  });
  await add("lina", {
    type: "expense",
    amount: 360,
    title: "Taxi from Tangier",
    category: "Transport",
    split: equal(360, everyone),
  });
  await add("youssef", {
    type: "expense",
    amount: 480,
    title: "Dinner at Bab Ssour",
    category: "Food",
    split: equal(480, everyone),
  });
  await add("sara", {
    type: "expense",
    amount: 96,
    title: "Mint tea & pastries",
    category: "Food",
    split: equal(96, [uid.sara, uid.lina]),
  });
  await add("youssef", {
    type: "expense",
    amount: 250,
    title: "Hike guide to Akchour",
    category: "Entertainment",
    split: equal(250, everyone),
  });
  await add("lina", {
    type: "expense",
    amount: 420,
    title: "Rugs & souvenirs",
    category: "Shopping",
    split: equal(420, [uid.lina, owner.uid]),
  });
  console.log(`added ${n} movements`);
}

/**
 * Finds every demo account by its email pattern rather than trusting the state
 * file, so an interrupted run or a lost temp file never leaves data behind.
 */
async function demoAccounts() {
  const pattern = /^store-[a-z]+-[0-9a-f]{8}@demo\.invalid$/;
  const found = [];
  let pageToken;
  do {
    const page = await admin.auth().listUsers(1000, pageToken);
    for (const user of page.users) {
      if (user.email && pattern.test(user.email)) found.push(user);
    }
    pageToken = page.pageToken;
  } while (pageToken);
  return found;
}

async function cleanup() {
  const db = admin.firestore();
  const accounts = await demoAccounts();
  for (const user of accounts) {
    const owned = await db.collection("groups").where("createdBy", "==", user.uid).get();
    if (owned.empty) continue;
    const password = crypto.randomBytes(18).toString("hex");
    await admin.auth().updateUser(user.uid, { password });
    const token = await idToken(user.email, password);
    for (const group of owned.docs) {
      await call("deleteGroup", token, { groupId: group.id });
      console.log(`deleted group ${group.id}`);
    }
  }
  for (const m of accounts) {
    for (const doc of [`join_${m.uid}`, `create_${m.uid}`]) {
      await db.collection("rateLimits").doc(doc).delete().catch(() => {});
    }
    await db.recursiveDelete(db.collection("users").doc(m.uid)).catch(() => {});
    await admin.auth().deleteUser(m.uid).catch(() => {});
  }
  if (fs.existsSync(STATE_FILE)) fs.unlinkSync(STATE_FILE);
  console.log(`removed ${accounts.length} demo accounts`);
}

async function main() {
  useFirebaseCliCredentials();
  admin = requireAdmin();
  if (admin.apps.length === 0) admin.initializeApp({ projectId: PROJECT_ID });
  const [command, arg] = process.argv.slice(2);
  if (command === "seed") return seed();
  if (command === "fill") return fill(arg);
  if (command === "cleanup") return cleanup();
  throw new Error("usage: store-demo.cjs seed | fill <email> | cleanup");
}

main().then(
  () => process.exit(0),
  (error) => {
    console.error("store-demo failed:", error.message || error);
    process.exit(1);
  }
);
