import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
        .map((snap) => snap.docs.map(Settlement.fromDoc).toList())
        .handleError((Object e, StackTrace s) {
          // Swallowing this made a denied or failed read look exactly like
          // "no settlements yet", which hid a real backend problem behind an
          // empty list. Log it and let the stream fail loudly instead.
          debugPrint('watchSettlements($groupId) failed: $e');
          throw e;
        });
  }

  Future<void> recordPayment({
    required String groupId,
    required String fromUid,
    required String toUid,
    required double amount,
    bool asRecipient = false,
  }) async {
    final settlementId = _settlements(groupId).doc().id;
    await _backend.call('recordSettlement', {
      'groupId': groupId,
      'settlementId': settlementId,
      'fromUid': fromUid,
      'toUid': toUid,
      'amount': amount,
      if (asRecipient) 'asRecipient': true,
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
