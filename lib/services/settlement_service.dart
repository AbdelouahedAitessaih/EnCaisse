import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'backend_service.dart';

class SettlementService {
  SettlementService({FirebaseFirestore? firestore, BackendService? backend})
      : _db = firestore ?? FirebaseFirestore.instance,
        _backend = backend ?? BackendService();

  final FirebaseFirestore _db;
  final BackendService _backend;

  CollectionReference<Map<String, dynamic>> _settlements(String groupId) =>
      _db.collection('groups').doc(groupId).collection('settlements');

  Stream<List<Settlement>> watchSettlements(String groupId) {
    return _settlements(groupId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(Settlement.fromDoc).toList());
  }

  Future<void> recordPayment({
    required String groupId,
    required String fromUid,
    required String toUid,
    required double amount,
  }) async {
    final settlementId = _settlements(groupId).doc().id;
    await _backend.call('recordSettlement', {
      'groupId': groupId,
      'settlementId': settlementId,
      'fromUid': fromUid,
      'toUid': toUid,
      'amount': amount,
    });
  }

  Future<void> confirmReceived({
    required String groupId,
    required String settlementId,
  }) async {
    await _backend.call('confirmSettlement', {
      'groupId': groupId,
      'settlementId': settlementId,
    });
  }

  Future<void> cancelPayment({
    required String groupId,
    required String settlementId,
  }) async {
    await _backend.call('cancelSettlement', {
      'groupId': groupId,
      'settlementId': settlementId,
    });
  }
}
