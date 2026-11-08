import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'backend_service.dart';

class GroupService {
  GroupService({FirebaseFirestore? firestore, BackendService? backend})
    : _db = firestore ?? FirebaseFirestore.instance,
      _backend = backend ?? BackendService();

  final FirebaseFirestore _db;
  final BackendService _backend;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  Stream<List<Group>> watchUserGroups(String uid) {
    return _db
        .collectionGroup('members')
        .where(FieldPath.documentId, isEqualTo: uid)
        .snapshots()
        .asyncMap((memberSnaps) async {
          final groupSnaps = await Future.wait(
            memberSnaps.docs.map((memberDoc) async {
              final groupRef = memberDoc.reference.parent.parent;
              return groupRef?.get();
            }),
          );
          final groups = groupSnaps
              .whereType<DocumentSnapshot<Map<String, dynamic>>>()
              .where((groupSnap) => groupSnap.exists)
              .map(Group.fromDoc)
              .toList();
          groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return groups;
        });
  }

  Stream<Group?> watchGroup(String groupId) {
    return _groups
        .doc(groupId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return Group.fromDoc(doc);
        })
        .handleError((e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return null;
          }
          throw e;
        });
  }

  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _groups
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map((snap) => snap.docs.map(GroupMember.fromDoc).toList())
        .handleError((e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return <GroupMember>[];
          }
          throw e;
        });
  }

  Future<Group> createGroup({
    required String name,
    required String createdBy,
    required String displayName,
    String? photoUrl,
    String currency = 'MAD',
    double startingAmount = 0,
    bool isPersonal = false,
  }) async {
    final result = await _backend.call('createGroup', {
      'name': name.trim(),
      'displayName': displayName.trim(),
      'photoUrl': photoUrl,
      'currency': currency,
      'startingAmount': startingAmount,
      'isPersonal': isPersonal,
    });
    return _groupFromCallable(result);
  }

  /// Opens or creates the user's solo personal caisse.
  Future<Group> ensurePersonalGroup({
    required String uid,
    required String displayName,
    required String personalName,
    String? photoUrl,
    String currency = 'MAD',
  }) async {
    final memberships = await _db
        .collection('users')
        .doc(uid)
        .collection('memberships')
        .get();
    for (final doc in memberships.docs) {
      final groupId = doc.id;
      final groupSnap = await _groups.doc(groupId).get();
      if (!groupSnap.exists) continue;
      final group = Group.fromDoc(groupSnap);
      if (group.isPersonal && group.createdBy == uid) {
        return group;
      }
    }
    return createGroup(
      name: personalName,
      createdBy: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      currency: currency,
      isPersonal: true,
    );
  }

  Future<Group> joinGroup({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final result = await _backend.call('joinGroup', {
      'inviteCode': inviteCode.trim().toUpperCase(),
      'displayName': displayName.trim(),
      'photoUrl': photoUrl,
    });
    return _groupFromCallable(result);
  }

  Group _groupFromCallable(Map<String, dynamic> data) => Group(
    id: data['id'] as String? ?? '',
    name: data['name'] as String? ?? '',
    createdBy: data['createdBy'] as String? ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (data['createdAtMillis'] as num?)?.toInt() ?? 0,
    ),
    inviteCode: data['inviteCode'] as String? ?? '',
    currency: data['currency'] as String? ?? 'MAD',
    photoUrl: data['photoUrl'] as String?,
    isPersonal: data['isPersonal'] as bool? ?? false,
  );

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
        {'displayName': displayName, 'photoUrl': photoUrl},
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

  /// Deleting a group sweeps every movement, audit entry, settlement and
  /// storage object server-side, so it gets a much longer budget than a normal
  /// write instead of inheriting the short interactive-call timeout.
  ///
  /// No creator id is accepted: ownership is proven by the caller's ID token
  /// and checked against the group document by the function, so passing a uid
  /// here would only look like it was being verified when it is ignored.
  Future<void> deleteGroup({required String groupId}) async {
    await _backend.call('deleteGroup', {
      'groupId': groupId,
    }, timeout: const Duration(seconds: 120));
  }

  /// Server read, so a just-deleted group is not reported from the cache.
  /// Members lose read access once a group is gone, which counts as deleted.
  Future<bool> groupExists(String groupId) async {
    try {
      final snap = await _groups
          .doc(groupId)
          .get(const GetOptions(source: Source.server));
      return snap.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'not-found') return false;
      rethrow;
    }
  }

  Stream<List<Group>> watchMemberships(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('memberships')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final groupSnaps = await Future.wait(
            snap.docs.map((doc) => _groups.doc(doc.id).get()),
          );
          return groupSnaps
              .where((groupSnap) => groupSnap.exists)
              .map(Group.fromDoc)
              .toList();
        });
  }

  Future<void> setNotificationsMuted({
    required String groupId,
    required String uid,
    required bool muted,
  }) {
    return _groups.doc(groupId).collection('members').doc(uid).set({
      'notificationsMuted': muted,
    }, SetOptions(merge: true));
  }

  Future<bool> isMember(String groupId, String uid) async {
    final snap = await _groups
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .get();
    return snap.exists;
  }
}
