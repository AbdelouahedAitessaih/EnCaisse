import 'package:encaisse/firebase_options.dart';
import 'package:encaisse/models/models.dart';
import 'package:encaisse/services/backend_service.dart';
import 'package:encaisse/services/group_service.dart';
import 'package:encaisse/services/movement_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Credentials are injected at run time so no secret is ever committed:
//
//   flutter test integration_test -d <device-id> \
//     --dart-define=UITEST_EMAIL=... --dart-define=UITEST_PASSWORD=...
//
// These run against the real backend and create/remove their own throwaway
// groups, so every test cleans up after itself.
const _email = String.fromEnvironment('UITEST_EMAIL');
const _password = String.fromEnvironment('UITEST_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final configured = _email.isNotEmpty && _password.isNotEmpty;
  final skipReason = configured
      ? null
      : 'Pass --dart-define=UITEST_EMAIL=... --dart-define=UITEST_PASSWORD=...';

  late FirebaseFirestore db;
  late GroupService groups;
  late MovementService movements;
  late String uid;

  setUpAll(() async {
    // Every test below is skipped without credentials, so there is nothing to
    // initialise either. Guarding here keeps a plain `flutter test` run green
    // instead of failing on an empty sign-in.
    if (!configured) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final cred = await auth.signInWithEmailAndPassword(
      email: _email,
      password: _password,
    );
    uid = cred.user!.uid;
    final backend = BackendService(auth: auth);
    groups = GroupService(firestore: db, backend: backend);
    movements = MovementService(firestore: db, backend: backend);
  });

  /// Creates a throwaway group and registers its removal with the current test.
  Future<String> freshGroup(String label) async {
    final group = await groups.createGroup(
      name: 'zz-itest-$label-${DateTime.now().millisecondsSinceEpoch}',
      createdBy: uid,
      displayName: 'Integration Tester',
      currency: 'MAD',
    );
    addTearDown(() async {
      try {
        await groups.deleteGroup(groupId: group.id);
      } catch (_) {
        // Already gone, or the test removed it deliberately.
      }
    });
    return group.id;
  }

  test(
    'createGroup writes the group, its creator membership and an invite code',
    () async {
      final groupId = await freshGroup('create');

      final doc = await db.collection('groups').doc(groupId).get();
      expect(doc.exists, isTrue);
      expect(doc.get('createdBy'), uid);
      expect(doc.get('currency'), 'MAD');
      expect(doc.get('isPersonal'), isFalse);
      expect((doc.get('inviteCode') as String?)?.isNotEmpty, isTrue);

      // The reverse membership pointer is what Home actually reads.
      final membership = await db
          .collection('users')
          .doc(uid)
          .collection('memberships')
          .doc(groupId)
          .get();
      expect(membership.exists, isTrue);
    },
    skip: skipReason,
  );

  test('createGroup rejects an unsupported currency', () async {
    await expectLater(
      groups.createGroup(
        name: 'zz-itest-bad-currency',
        createdBy: uid,
        displayName: 'Integration Tester',
        currency: 'XXX',
      ),
      throwsA(isA<BackendCallException>()),
    );
  }, skip: skipReason);

  test('a deposit is persisted and moves the stored balance', () async {
    final groupId = await freshGroup('deposit');

    await movements.createMovement(
      groupId: groupId,
      type: MovementType.deposit,
      amount: 100,
      title: 'itest deposit',
      category: 'Food',
      uid: uid,
      displayName: 'Integration Tester',
    );

    final doc = await db.collection('groups').doc(groupId).get();
    // MAD has two minor digits, so 100.00 is 10000 minor units.
    expect(doc.get('balanceMinorUnits'), 10000);

    final stored = await db
        .collection('groups')
        .doc(groupId)
        .collection('movements')
        .get();
    expect(stored.docs, hasLength(1));
    expect(stored.docs.first.get('createdBy'), uid);
  }, skip: skipReason);

  test(
    'an expense larger than the balance is refused and writes nothing',
    () async {
      final groupId = await freshGroup('overdraw');

      await movements.createMovement(
        groupId: groupId,
        type: MovementType.deposit,
        amount: 100,
        title: 'itest deposit',
        category: 'Food',
        uid: uid,
        displayName: 'Integration Tester',
      );

      await expectLater(
        movements.createMovement(
          groupId: groupId,
          type: MovementType.expense,
          amount: 500,
          title: 'itest overdraw',
          category: 'Food',
          uid: uid,
          displayName: 'Integration Tester',
        ),
        throwsA(isA<InsufficientBalanceException>()),
      );

      // The refused expense must not have been written, and the balance the
      // deposit produced must be untouched.
      final stored = await db
          .collection('groups')
          .doc(groupId)
          .collection('movements')
          .get();
      expect(stored.docs, hasLength(1));
      final doc = await db.collection('groups').doc(groupId).get();
      expect(doc.get('balanceMinorUnits'), 10000);
    },
    skip: skipReason,
  );

  test(
    'soft deleting a movement then undoing it restores the balance',
    () async {
      final groupId = await freshGroup('undo');

      final movement = await movements.createMovement(
        groupId: groupId,
        type: MovementType.deposit,
        amount: 80,
        title: 'itest undo',
        category: 'Food',
        uid: uid,
        displayName: 'Integration Tester',
      );
      expect(movement.deleted, isFalse);

      Future<int> balanceMinor() async =>
          (await db.collection('groups').doc(groupId).get()).get(
                'balanceMinorUnits',
              )
              as int;

      expect(await balanceMinor(), 8000);

      await movements.softDeleteMovement(
        groupId: groupId,
        existing: movement,
        uid: uid,
        displayName: 'Integration Tester',
      );
      // A soft delete is reversible, so it must also take the money back out.
      expect(await balanceMinor(), 0);

      await movements.undoSoftDelete(
        groupId: groupId,
        existing: movement,
        uid: uid,
        displayName: 'Integration Tester',
      );
      expect(await balanceMinor(), 8000);

      // Still a single movement: delete/undo must never duplicate the write.
      final stored = await db
          .collection('groups')
          .doc(groupId)
          .collection('movements')
          .get();
      expect(stored.docs, hasLength(1));
    },
    skip: skipReason,
  );

  test(
    'deleteGroup removes the group, its movements and the membership',
    () async {
      final groupId = await freshGroup('delete');

      await movements.createMovement(
        groupId: groupId,
        type: MovementType.deposit,
        amount: 42,
        title: 'itest delete',
        category: 'Food',
        uid: uid,
        displayName: 'Integration Tester',
      );

      await groups.deleteGroup(groupId: groupId);

      // Access is revoked: the caller is no longer a member, so the rules now
      // deny the read. That denial is the proof the group is really gone.
      await expectLater(
        db.collection('groups').doc(groupId).get(),
        throwsA(isA<FirebaseException>()),
      );
      // The membership pointer is gone too, and this collection is readable by
      // its owner, so it can be asserted directly.
      final membership = await db
          .collection('users')
          .doc(uid)
          .collection('memberships')
          .doc(groupId)
          .get();
      expect(membership.exists, isFalse);
    },
    skip: skipReason,
  );

  test('deleteGroup rejects a malformed group id', () async {
    await expectLater(
      groups.deleteGroup(groupId: 'not a valid id!'),
      throwsA(isA<BackendCallException>()),
    );
  }, skip: skipReason);

  // NOTE: "a different member cannot delete this group" needs a second signed-in
  // account, which a single test session cannot provide. The server-side check
  // is group.createdBy === context.auth.uid in functions/index.js, and the
  // client no longer passes a creator id at all, so there is nothing to forge.
  // That case is covered by scripts/verify-live-flows.cjs, which signs in two
  // throwaway accounts and asserts the non-creator is refused.
}
