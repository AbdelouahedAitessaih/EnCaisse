import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'backend_service.dart';

/// Thrown when a movement would make the group balance negative.
class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();

  @override
  String toString() => 'insufficient_balance';
}

/// Reads live data from Firestore; all ledger writes go through trusted
/// callable functions, which apply balance checks and audit records atomically.
class MovementService {
  MovementService({
    FirebaseFirestore? firestore,
    BackendService? backend,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _backend = backend ?? BackendService();

  final FirebaseFirestore _db;
  final BackendService _backend;

  CollectionReference<Map<String, dynamic>> _movements(String groupId) =>
      _db.collection('groups').doc(groupId).collection('movements');

  CollectionReference<Map<String, dynamic>> _audit(String groupId) =>
      _db.collection('groups').doc(groupId).collection('audit');

  static double signedDelta(MovementType type, double amount) =>
      type == MovementType.expense ? -amount.abs() : amount.abs();

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _backend.call(functionName, payload);
    } on BackendCallException catch (e) {
      if (e.code == 'failed-precondition' &&
          e.message.toLowerCase().contains('balance')) {
        throw const InsufficientBalanceException();
      }
      rethrow;
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
    final movementId = _movements(groupId).doc().id;
    final result = await _call('createMovement', {
      'groupId': groupId,
      'movementId': movementId,
      'type': type.value,
      'amount': amount.abs(),
      'title': title.trim(),
      'category': category,
      'displayName': displayName,
      'receiptUrl': receiptUrl,
    });
    final now = _serverTime(result);
    return Movement(
      id: result['movementId'] as String? ?? movementId,
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
    );
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
  }) async {
    final effectiveType =
        existing.isStartingBalance ? MovementType.deposit : type;
    await _call('updateMovement', {
      'groupId': groupId,
      'movementId': existing.id,
      'type': effectiveType.value,
      'amount': amount.abs(),
      'title': existing.isStartingBalance ? 'Starting balance' : title.trim(),
      'category': existing.isStartingBalance ? 'Other' : category,
      'displayName': displayName,
      if (!existing.isStartingBalance) 'receiptUrl': receiptUrl,
    });
    return Movement(
      id: existing.id,
      type: effectiveType,
      amount: amount.abs(),
      title: existing.isStartingBalance ? 'Starting balance' : title.trim(),
      category: existing.isStartingBalance ? 'Other' : category,
      createdBy: existing.createdBy,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      updatedBy: uid,
      receiptUrl:
          existing.isStartingBalance ? existing.receiptUrl : receiptUrl ?? existing.receiptUrl,
      deleted: existing.deleted,
      deletedAt: existing.deletedAt,
      isStartingBalance: existing.isStartingBalance,
    );
  }

  Future<Movement> softDeleteMovement({
    required String groupId,
    required Movement existing,
    required String uid,
    required String displayName,
  }) async {
    final result = await _call('softDeleteMovement', {
      'groupId': groupId,
      'movementId': existing.id,
      'displayName': displayName,
    });
    final now = _serverTime(result);
    return Movement(
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
  }

  Future<Movement> undoSoftDelete({
    required String groupId,
    required Movement existing,
    required String uid,
    required String displayName,
  }) async {
    final result = await _call('undoSoftDelete', {
      'groupId': groupId,
      'movementId': existing.id,
      'displayName': displayName,
    });
    final now = _serverTime(result);
    return Movement(
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
      isStartingBalance: existing.isStartingBalance,
    );
  }

  DateTime _serverTime(Map<String, dynamic> result) {
    final millis = (result['timestampMillis'] as num?)?.toInt();
    return millis == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
