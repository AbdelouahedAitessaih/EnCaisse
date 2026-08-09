import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/models.dart';

class GroupService {
  GroupService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  Stream<List<Group>> watchUserGroups(String uid) {
    return _db
        .collectionGroup('members')
        .where(FieldPath.documentId, isEqualTo: uid)
        .snapshots()
        .asyncMap((memberSnaps) async {
      final groups = <Group>[];
      for (final memberDoc in memberSnaps.docs) {
        final groupRef = memberDoc.reference.parent.parent;
        if (groupRef == null) continue;
        final groupSnap = await groupRef.get();
        if (groupSnap.exists) {
          groups.add(Group.fromDoc(groupSnap));
        }
      }
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return groups;
    });
  }

  /// Simpler membership query via users/{uid}/groupIds mirror + groups stream.
  /// Primary path: scan groups where members/{uid} exists using collection group.
  Stream<List<Group>> watchGroupsForUser(String uid) {
    return _groups.snapshots().asyncMap((snap) async {
      final result = <Group>[];
      for (final doc in snap.docs) {
        final member = await doc.reference.collection('members').doc(uid).get();
        if (member.exists) {
          result.add(Group.fromDoc(doc));
        }
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    });
  }

  Stream<Group?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Group.fromDoc(doc);
    });
  }

  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _groups
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map((snap) => snap.docs.map(GroupMember.fromDoc).toList());
  }

  Future<Group> createGroup({
    required String name,
    required String createdBy,
    required String displayName,
    String? photoUrl,
    String currency = 'MAD',
    double startingAmount = 0,
  }) async {
    final ref = _groups.doc();
    final now = DateTime.now();
    var inviteCode = generateInviteCode(length: AppConstants.inviteCodeLength);

    // Ensure unique invite code (best-effort — list may be restricted).
    for (var i = 0; i < 5; i++) {
      try {
        final existing = await _groups
            .where('inviteCode', isEqualTo: inviteCode)
            .limit(1)
            .get();
        if (existing.docs.isEmpty) break;
      } catch (_) {
        break;
      }
      inviteCode = generateInviteCode(length: AppConstants.inviteCodeLength);
    }

    final group = Group(
      id: ref.id,
      name: name.trim(),
      createdBy: createdBy,
      createdAt: now,
      inviteCode: inviteCode,
      currency: currency,
    );

    final batch = _db.batch();
    batch.set(ref, group.toMap());
    batch.set(
      ref.collection('members').doc(createdBy),
      GroupMember(
        uid: createdBy,
        displayName: displayName,
        joinedAt: now,
        photoUrl: photoUrl,
      ).toMap(),
    );
    // Membership index for efficient home list
    batch.set(
      _db.collection('users').doc(createdBy).collection('memberships').doc(ref.id),
      {
        'groupId': ref.id,
        'joinedAt': Timestamp.fromDate(now),
        'name': group.name,
      },
    );
    await batch.commit();

    // Starting balance after membership exists — rules require isGroupMember,
    // which cannot see docs written in the same batch.
    if (startingAmount > 0) {
      final movementRef = ref.collection('movements').doc();
      final auditRef = ref.collection('audit').doc();
      final movementTime = DateTime.now();
      final movement = Movement(
        id: movementRef.id,
        type: MovementType.deposit,
        amount: startingAmount.abs(),
        title: 'Starting balance',
        category: 'Other',
        createdBy: createdBy,
        createdByName: displayName,
        createdAt: movementTime,
        updatedAt: movementTime,
        updatedBy: createdBy,
        isStartingBalance: true,
      );
      final audit = AuditEntry(
        id: auditRef.id,
        movementId: movementRef.id,
        action: AuditAction.create,
        performedBy: createdBy,
        performedByName: displayName,
        timestamp: movementTime,
        before: null,
        after: movement.toAuditSnapshot(),
      );
      final startBatch = _db.batch();
      startBatch.set(movementRef, movement.toMap());
      startBatch.set(auditRef, audit.toMap());
      await startBatch.commit();
    }

    return group;
  }

  Future<Group> joinGroup({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final code = inviteCode.trim().toUpperCase();
    final query = await _groups
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('No group found for this invite code.');
    }

    final groupDoc = query.docs.first;
    final memberRef = groupDoc.reference.collection('members').doc(uid);
    final existing = await memberRef.get();
    if (existing.exists) {
      return Group.fromDoc(groupDoc);
    }

    final now = DateTime.now();
    final batch = _db.batch();
    batch.set(
      memberRef,
      GroupMember(
        uid: uid,
        displayName: displayName,
        joinedAt: now,
        photoUrl: photoUrl,
      ).toMap(),
    );
    batch.set(
      _db.collection('users').doc(uid).collection('memberships').doc(groupDoc.id),
      {
        'groupId': groupDoc.id,
        'joinedAt': Timestamp.fromDate(now),
        'name': groupDoc.data()['name'],
      },
    );
    await batch.commit();
    return Group.fromDoc(groupDoc);
  }

  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Group name is too short');
    }

    await _groups.doc(groupId).update({'name': trimmed});

    final members = await _groups.doc(groupId).collection('members').get();
    WriteBatch? batch;
    var ops = 0;
    Future<void> commitIfNeeded({bool force = false}) async {
      if (batch == null) return;
      if (!force && ops < 450) return;
      await batch!.commit();
      batch = null;
      ops = 0;
    }

    for (final member in members.docs) {
      batch ??= _db.batch();
      batch!.set(
        _db
            .collection('users')
            .doc(member.id)
            .collection('memberships')
            .doc(groupId),
        {'name': trimmed},
        SetOptions(merge: true),
      );
      ops++;
      await commitIfNeeded();
    }
    await commitIfNeeded(force: true);
  }

  Future<void> updateGroupPhoto({
    required String groupId,
    required String photoUrl,
  }) {
    return _groups.doc(groupId).update({'photoUrl': photoUrl});
  }

  Future<void> leaveGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupSnap = await _groups.doc(groupId).get();
    if (!groupSnap.exists) {
      throw StateError('Group not found');
    }
    final createdBy = groupSnap.data()?['createdBy'] as String?;
    if (createdBy == uid) {
      throw StateError('Creator cannot leave the group');
    }

    // Membership only — movements/audit history stay on the group.
    final batch = _db.batch();
    batch.delete(_groups.doc(groupId).collection('members').doc(uid));
    batch.delete(
      _db.collection('users').doc(uid).collection('memberships').doc(groupId),
    );
    await batch.commit();
  }

  Future<void> syncMemberProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final memberships = await _db
        .collection('users')
        .doc(uid)
        .collection('memberships')
        .get();
    WriteBatch? batch;
    var ops = 0;
    Future<void> commitIfNeeded({bool force = false}) async {
      if (batch == null) return;
      if (!force && ops < 450) return;
      await batch!.commit();
      batch = null;
      ops = 0;
    }

    for (final membership in memberships.docs) {
      batch ??= _db.batch();
      batch!.set(
        _groups.doc(membership.id).collection('members').doc(uid),
        {
          'displayName': displayName,
          'photoUrl': photoUrl,
        },
        SetOptions(merge: true),
      );
      ops++;
      await commitIfNeeded();
    }
    await commitIfNeeded(force: true);
  }

  Future<void> removeMember({
    required String groupId,
    required String memberUid,
    required String creatorUid,
  }) async {
    if (memberUid == creatorUid) {
      throw StateError('Cannot remove the group creator');
    }

    final batch = _db.batch();
    batch.delete(_groups.doc(groupId).collection('members').doc(memberUid));
    batch.delete(
      _db
          .collection('users')
          .doc(memberUid)
          .collection('memberships')
          .doc(groupId),
    );
    await batch.commit();
  }

  Future<void> deleteGroup({
    required String groupId,
    required String creatorUid,
  }) async {
    final groupRef = _groups.doc(groupId);
    final groupSnap = await groupRef.get();
    if (!groupSnap.exists) return;
    final createdBy = groupSnap.data()?['createdBy'] as String?;
    if (createdBy != creatorUid) {
      throw StateError('Only the creator can delete this group');
    }

    final members = await groupRef.collection('members').get();
    final movements = await groupRef.collection('movements').get();
    final audits = await groupRef.collection('audit').get();

    WriteBatch? batch;
    var ops = 0;

    Future<void> commitIfNeeded({bool force = false}) async {
      if (batch == null) return;
      if (!force && ops < 450) return;
      await batch!.commit();
      batch = null;
      ops = 0;
    }

    void enqueue(void Function(WriteBatch b) action) {
      batch ??= _db.batch();
      action(batch!);
      ops++;
    }

    for (final doc in movements.docs) {
      enqueue((b) => b.delete(doc.reference));
      await commitIfNeeded();
    }
    for (final doc in audits.docs) {
      enqueue((b) => b.delete(doc.reference));
      await commitIfNeeded();
    }

    // Remove non-creator members first, then the creator member, then the group.
    final creatorMember = members.docs.where((d) => d.id == creatorUid);
    final otherMembers = members.docs.where((d) => d.id != creatorUid);

    for (final doc in otherMembers) {
      enqueue((b) => b.delete(doc.reference));
      enqueue(
        (b) => b.delete(
          _db
              .collection('users')
              .doc(doc.id)
              .collection('memberships')
              .doc(groupId),
        ),
      );
      await commitIfNeeded();
    }
    for (final doc in creatorMember) {
      enqueue((b) => b.delete(doc.reference));
      enqueue(
        (b) => b.delete(
          _db
              .collection('users')
              .doc(doc.id)
              .collection('memberships')
              .doc(groupId),
        ),
      );
      await commitIfNeeded();
    }

    enqueue((b) => b.delete(groupRef));
    await commitIfNeeded(force: true);
  }

  Stream<List<Group>> watchMemberships(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('memberships')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final groups = <Group>[];
      for (final doc in snap.docs) {
        final groupSnap = await _groups.doc(doc.id).get();
        if (groupSnap.exists) {
          groups.add(Group.fromDoc(groupSnap));
        }
      }
      return groups;
    });
  }

  Future<void> setNotificationsMuted({
    required String groupId,
    required String uid,
    required bool muted,
  }) {
    return _groups
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .set({'notificationsMuted': muted}, SetOptions(merge: true));
  }

  Future<bool> isMember(String groupId, String uid) async {
    final snap =
        await _groups.doc(groupId).collection('members').doc(uid).get();
    return snap.exists;
  }
}
