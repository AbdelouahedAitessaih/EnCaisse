import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Thrown when an operation would make the group balance negative.
class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();

  @override
  String toString() => 'insufficient_balance';
}

/// All movement writes are batched with an immutable audit entry.
class MovementService {
  MovementService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _movements(String groupId) =>
      _db.collection('groups').doc(groupId).collection('movements');

  CollectionReference<Map<String, dynamic>> _audit(String groupId) =>
      _db.collection('groups').doc(groupId).collection('audit');

  static double signedDelta(MovementType type, double amount) =>
      type == MovementType.expense ? -amount.abs() : amount.abs();

  /// Balance after excluding [excludeId] and optionally applying [extraSigned].
  Future<void> _assertNonNegativeBalance(
    String groupId, {
    String? excludeId,
    double extraSigned = 0,
  }) async {
    final snap = await _movements(groupId).get();
    final active = <Movement>[];
    for (final doc in snap.docs) {
      final m = Movement.fromDoc(doc);
      if (m.deleted) continue;
      if (excludeId != null && m.id == excludeId) continue;
      active.add(m);
    }
    final projected =
        BalanceSummary.fromMovements(active).total + extraSigned;
    if (projected < -1e-9) {
      throw const InsufficientBalanceException();
    }
  }

  Stream<List<Movement>> watchMovements(String groupId) {
    return _movements(groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Movement.fromDoc).toList());
  }

  Stream<List<AuditEntry>> watchAuditForMovement(
    String groupId,
    String movementId,
  ) {
    // Filter only (no orderBy) so no composite index is required.
    // Sort newest-first on the client.
    return _audit(groupId)
        .where('movementId', isEqualTo: movementId)
        .snapshots()
        .map((snap) {
      final entries = snap.docs.map(AuditEntry.fromDoc).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    });
  }

  Future<Movement> createMovement({
    required String groupId,
    required MovementType type,
    required double amount,
    required String title,
    required String category,
    required String uid,
    required String displayName,
    String? receiptUrl,
  }) async {
    await _assertNonNegativeBalance(
      groupId,
      extraSigned: signedDelta(type, amount),
    );

    final movementRef = _movements(groupId).doc();
    final auditRef = _audit(groupId).doc();
    final now = DateTime.now();

    final movement = Movement(
      id: movementRef.id,
      type: type,
      amount: amount.abs(),
      title: title.trim(),
      category: category,
      createdBy: uid,
      createdByName: displayName,
      createdAt: now,
      updatedAt: now,
      updatedBy: uid,
      receiptUrl: receiptUrl,
      deleted: false,
    );

    final audit = AuditEntry(
      id: auditRef.id,
      movementId: movementRef.id,
      action: AuditAction.create,
      performedBy: uid,
      performedByName: displayName,
      timestamp: now,
      before: null,
      after: movement.toAuditSnapshot(),
    );

    final batch = _db.batch();
    batch.set(movementRef, movement.toMap());
    batch.set(auditRef, audit.toMap());
    await batch.commit();
    return movement;
  }

  Future<Movement> updateMovement({
    required String groupId,
    required Movement existing,
    required MovementType type,
    required double amount,
    required String title,
    required String category,
    required String uid,
    required String displayName,
    String? receiptUrl,
    required String groupCreatedBy,
  }) async {
    if (existing.isStartingBalance && uid != groupCreatedBy) {
      throw StateError(
        'Only the person who created this caisse can edit the starting balance.',
      );
    }

    final effectiveType =
        existing.isStartingBalance ? MovementType.deposit : type;
    await _assertNonNegativeBalance(
      groupId,
      excludeId: existing.id,
      extraSigned: signedDelta(effectiveType, amount),
    );

    final movementRef = _movements(groupId).doc(existing.id);
    final auditRef = _audit(groupId).doc();
    final now = DateTime.now();

    final updated = Movement(
      id: existing.id,
      type: effectiveType,
      amount: amount.abs(),
      title: existing.isStartingBalance ? 'Starting balance' : title.trim(),
      category: existing.isStartingBalance ? 'Other' : category,
      createdBy: existing.createdBy,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
      updatedAt: now,
      updatedBy: uid,
      receiptUrl: existing.isStartingBalance
          ? existing.receiptUrl
          : (receiptUrl ?? existing.receiptUrl),
      deleted: existing.deleted,
      deletedAt: existing.deletedAt,
      isStartingBalance: existing.isStartingBalance,
    );

    final audit = AuditEntry(
      id: auditRef.id,
      movementId: existing.id,
      action: AuditAction.update,
      performedBy: uid,
      performedByName: displayName,
      timestamp: now,
      before: existing.toAuditSnapshot(),
      after: updated.toAuditSnapshot(),
    );

    final batch = _db.batch();
    batch.set(movementRef, updated.toMap());
    batch.set(auditRef, audit.toMap());
    await batch.commit();
    return updated;
  }

  /// Soft-delete. Audit action is delete. Undo flips deleted back to false.
  Future<Movement> softDeleteMovement({
    required String groupId,
    required Movement existing,
    required String uid,
    required String displayName,
    required String groupCreatedBy,
  }) async {
    if (existing.isStartingBalance && uid != groupCreatedBy) {
      throw StateError(
        'Only the person who created this caisse can delete the starting balance.',
      );
    }

    // Removing a deposit (or starting balance) lowers the total.
    await _assertNonNegativeBalance(
      groupId,
      excludeId: existing.id,
    );

    final movementRef = _movements(groupId).doc(existing.id);
    final auditRef = _audit(groupId).doc();
    final now = DateTime.now();

    final deleted = Movement(
      id: existing.id,
      type: existing.type,
      amount: existing.amount,
      title: existing.title,
      category: existing.category,
      createdBy: existing.createdBy,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
      updatedAt: now,
      updatedBy: uid,
      receiptUrl: existing.receiptUrl,
      deleted: true,
      deletedAt: now,
      isStartingBalance: existing.isStartingBalance,
    );

    final audit = AuditEntry(
      id: auditRef.id,
      movementId: existing.id,
      action: AuditAction.delete,
      performedBy: uid,
      performedByName: displayName,
      timestamp: now,
      before: existing.toAuditSnapshot(),
      after: deleted.toAuditSnapshot(),
    );

    final batch = _db.batch();
    batch.set(movementRef, deleted.toMap());
    batch.set(auditRef, audit.toMap());
    await batch.commit();
    return deleted;
  }

  Future<Movement> undoSoftDelete({
    required String groupId,
    required Movement existing,
    required String uid,
    required String displayName,
    required String groupCreatedBy,
  }) async {
    if (!existing.canUndo) {
      throw StateError('Undo window of 24 hours has expired.');
    }
    if (existing.isStartingBalance && uid != groupCreatedBy) {
      throw StateError(
        'Only the person who created this caisse can restore the starting balance.',
      );
    }

    await _assertNonNegativeBalance(
      groupId,
      extraSigned: signedDelta(existing.type, existing.amount),
    );

    final movementRef = _movements(groupId).doc(existing.id);
    final auditRef = _audit(groupId).doc();
    final now = DateTime.now();

    final restored = Movement(
      id: existing.id,
      type: existing.type,
      amount: existing.amount,
      title: existing.title,
      category: existing.category,
      createdBy: existing.createdBy,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
      updatedAt: now,
      updatedBy: uid,
      receiptUrl: existing.receiptUrl,
      deleted: false,
      deletedAt: null,
      isStartingBalance: existing.isStartingBalance,
    );

    final audit = AuditEntry(
      id: auditRef.id,
      movementId: existing.id,
      action: AuditAction.update,
      performedBy: uid,
      performedByName: displayName,
      timestamp: now,
      before: existing.toAuditSnapshot(),
      after: restored.toAuditSnapshot(),
    );

    final batch = _db.batch();
    batch.set(movementRef, restored.toMap());
    batch.set(auditRef, audit.toMap());
    await batch.commit();
    return restored;
  }
}
