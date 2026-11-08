import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'backend_service.dart';

/// Thrown when a movement would make the group balance negative.
class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();

  @override
  String toString() => 'insufficient_balance';
}

/// What was actually paid when a movement was typed in another currency.
class ForeignAmount {
  const ForeignAmount({
    required this.currency,
    required this.amount,
    required this.rate,
  });

  final String currency;
  final double amount;

  /// Group-currency units per one unit of [currency].
  final double rate;

  Map<String, dynamic> toPayload() => {
    'currency': currency,
    'amount': amount,
    'rate': rate,
  };
}

/// Reads live data from Firestore; all ledger writes go through trusted
/// callable functions, which apply balance checks and audit records atomically.
class MovementService {
  MovementService({FirebaseFirestore? firestore, BackendService? backend})
    : _db = firestore ?? FirebaseFirestore.instance,
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
        .map((snap) => snap.docs.map(Movement.fromDoc).toList())
        .handleError((e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return <Movement>[];
          }
          throw e;
        });
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
        })
        .handleError((e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return <AuditEntry>[];
          }
          throw e;
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
    Map<String, double>? split,
    ForeignAmount? original,
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
      'split': split,
      'original': original?.toPayload(),
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
      split: split,
      originalCurrency: original?.currency,
      originalAmount: original?.amount,
      exchangeRate: original?.rate,
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
    Map<String, double>? split,
    ForeignAmount? original,
  }) async {
    final effectiveType = existing.isStartingBalance
        ? MovementType.deposit
        : type;
    final plain = existing.isStartingBalance;
    await _call('updateMovement', {
      'groupId': groupId,
      'movementId': existing.id,
      'type': effectiveType.value,
      'amount': amount.abs(),
      'title': existing.isStartingBalance ? 'Starting balance' : title.trim(),
      'category': existing.isStartingBalance ? 'Other' : category,
      'displayName': displayName,
      if (!existing.isStartingBalance) 'receiptUrl': receiptUrl,
      'split': plain ? null : split,
      'original': plain ? null : original?.toPayload(),
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
      receiptUrl: existing.isStartingBalance
          ? existing.receiptUrl
          : receiptUrl ?? existing.receiptUrl,
      deleted: existing.deleted,
      deletedAt: existing.deletedAt,
      isStartingBalance: existing.isStartingBalance,
      split: plain ? null : split,
      originalCurrency: plain ? null : original?.currency,
      originalAmount: plain ? null : original?.amount,
      exchangeRate: plain ? null : original?.rate,
      recurringId: existing.recurringId,
    );
  }

  Stream<List<RecurringMovement>> watchRecurring(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('recurring')
        .orderBy('nextRunAt')
        .snapshots()
        .map((snap) => snap.docs.map(RecurringMovement.fromDoc).toList());
  }

  Future<void> createRecurring({
    required String groupId,
    required MovementType type,
    required double amount,
    required String title,
    required String category,
    required String displayName,
    required RecurrenceFrequency frequency,
    required DateTime firstRunAt,
    Map<String, double>? split,
  }) async {
    await _backend.call('createRecurring', {
      'groupId': groupId,
      'recurringId': _db
          .collection('groups')
          .doc(groupId)
          .collection('recurring')
          .doc()
          .id,
      'type': type.value,
      'amount': amount.abs(),
      'title': title.trim(),
      'category': category,
      'displayName': displayName,
      'split': split,
      'frequency': frequency.value,
      'firstRunAtMillis': firstRunAt.millisecondsSinceEpoch,
    });
  }

  Future<void> deleteRecurring({
    required String groupId,
    required String recurringId,
  }) async {
    await _backend.call('deleteRecurring', {
      'groupId': groupId,
      'recurringId': recurringId,
    });
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
