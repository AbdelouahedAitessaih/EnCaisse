const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");
const {initializeTestEnvironment, assertFails, assertSucceeds} =
  require("@firebase/rules-unit-testing");
const {doc, getDoc, setDoc, updateDoc} = require("firebase/firestore");

const projectId = "encaisse-rules-test";
let env;

test.before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: "127.0.0.1",
      port: 8080,
      rules: fs.readFileSync(path.join(__dirname, "../firestore.rules"), "utf8"),
    },
  });
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "groups/g1"), {
      name: "Shared caisse",
      createdBy: "owner",
      createdAt: new Date(),
      inviteCode: "ABCD2345",
      currency: "MAD",
    });
    await setDoc(doc(db, "groups/g1/members/owner"), {
      displayName: "Owner",
      notificationsMuted: false,
    });
    await setDoc(doc(db, "groups/g1/members/member"), {
      displayName: "Member",
      notificationsMuted: false,
    });
    await setDoc(doc(db, "groups/g1/movements/m1"), {
      type: "deposit",
      amount: 10,
      deleted: false,
    });
    await setDoc(doc(db, "groups/g1/settlements/s1"), {
      fromUid: "member",
      toUid: "owner",
      amount: 5,
      status: "pending",
      createdAt: new Date(),
    });
    await setDoc(doc(db, "users/member"), {
      displayName: "Member",
      email: "member@example.test",
      createdAt: new Date(),
    });
  });
});

test.after(async () => {
  if (env) await env.cleanup();
});

test("only group members can read a group and its movements", async () => {
  const memberDb = env.authenticatedContext("member").firestore();
  const outsiderDb = env.authenticatedContext("outsider").firestore();
  await assertSucceeds(getDoc(doc(memberDb, "groups/g1")));
  await assertSucceeds(getDoc(doc(memberDb, "groups/g1/movements/m1")));
  await assertSucceeds(getDoc(doc(memberDb, "groups/g1/settlements/s1")));
  await assertFails(getDoc(doc(outsiderDb, "groups/g1")));
  await assertFails(getDoc(doc(outsiderDb, "groups/g1/movements/m1")));
});

test("clients cannot create memberships, movements, audits, or notifications", async () => {
  const db = env.authenticatedContext("member").firestore();
  await assertFails(setDoc(doc(db, "groups/g1/members/outsider"), {
    displayName: "Outsider",
    notificationsMuted: false,
  }));
  await assertFails(setDoc(doc(db, "groups/g1/movements/m2"), {
    type: "deposit",
    amount: 1000,
  }));
  await assertFails(setDoc(doc(db, "groups/g1/audit/a1"), {action: "create"}));
  await assertFails(setDoc(doc(db, "groups/g1/settlements/s2"), {amount: 100}));
  await assertFails(setDoc(doc(db, "users/member/notifications/n1"), {read: false}));
});

test("members can update their own safe profile fields but not group identity", async () => {
  const memberDb = env.authenticatedContext("member").firestore();
  const ownerDb = env.authenticatedContext("owner").firestore();
  await assertSucceeds(updateDoc(doc(memberDb, "groups/g1/members/member"), {
    displayName: "Updated member",
  }));
  await assertFails(updateDoc(doc(memberDb, "groups/g1"), {name: "Taken over"}));
  await assertSucceeds(updateDoc(doc(ownerDb, "groups/g1"), {name: "Renamed"}));
});

test("recurring rules are readable by members and written only by the server", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "groups/g1/recurring/r1"), {
      type: "expense",
      amount: 20,
      createdBy: "owner",
      active: true,
    });
  });
  const memberDb = env.authenticatedContext("member").firestore();
  const ownerDb = env.authenticatedContext("owner").firestore();
  const outsiderDb = env.authenticatedContext("outsider").firestore();
  await assertSucceeds(getDoc(doc(memberDb, "groups/g1/recurring/r1")));
  await assertFails(getDoc(doc(outsiderDb, "groups/g1/recurring/r1")));
  await assertFails(updateDoc(doc(ownerDb, "groups/g1/recurring/r1"), {amount: 1}));
  await assertFails(setDoc(doc(memberDb, "groups/g1/recurring/r2"), {amount: 5}));
});

test("users can mark their own notifications read, but cannot change other fields", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/member/notifications/n1"), {
      read: false,
      title: "Notice",
    });
  });
  const db = env.authenticatedContext("member").firestore();
  await assertSucceeds(updateDoc(doc(db, "users/member/notifications/n1"), {read: true}));
  await assertFails(updateDoc(doc(db, "users/member/notifications/n1"), {title: "Forged"}));
});
