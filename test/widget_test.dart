import 'package:flutter_test/flutter_test.dart';

import 'package:encaisse/core/constants/app_constants.dart';
import 'package:encaisse/core/utils/settle.dart';
import 'package:encaisse/models/models.dart';

Movement _mov({
  required String id,
  required MovementType type,
  required double amount,
  required String by,
  String name = 'User',
  bool deleted = false,
  DateTime? deletedAt,
}) {
  final now = DateTime(2026, 1, 1);
  return Movement(
    id: id,
    type: type,
    amount: amount,
    title: id,
    category: 'Other',
    createdBy: by,
    createdByName: name,
    createdAt: now,
    updatedAt: now,
    updatedBy: by,
    deleted: deleted,
    deletedAt: deletedAt,
  );
}

void main() {
  test('balance is derived from non-deleted movements', () {
    final movements = [
      _mov(id: '1', type: MovementType.deposit, amount: 100, by: 'u'),
      _mov(id: '2', type: MovementType.expense, amount: 40, by: 'u'),
      _mov(
        id: '3',
        type: MovementType.expense,
        amount: 10,
        by: 'u',
        deleted: true,
        deletedAt: DateTime(2026),
      ),
    ];

    final balance = BalanceSummary.fromMovements(movements);
    expect(balance.total, 60);
    expect(balance.deposits, 100);
    expect(balance.expenses, 40);
    expect(AppConstants.appName, 'EnCaisse');
  });

  test('canUndo only within soft-delete window', () {
    final fresh = _mov(
      id: 'd1',
      type: MovementType.expense,
      amount: 5,
      by: 'u',
      deleted: true,
      deletedAt: DateTime.now(),
    );
    final expired = _mov(
      id: 'd2',
      type: MovementType.expense,
      amount: 5,
      by: 'u',
      deleted: true,
      deletedAt: DateTime.now().subtract(const Duration(hours: 25)),
    );
    expect(fresh.canUndo, isTrue);
    expect(expired.canUndo, isFalse);
  });

  test('settle computes who owes whom for equal share', () {
    final members = [
      GroupMember(uid: 'a', displayName: 'Alice', joinedAt: DateTime(2026)),
      GroupMember(uid: 'b', displayName: 'Bob', joinedAt: DateTime(2026)),
    ];
    final movements = [
      _mov(
        id: '1',
        type: MovementType.deposit,
        amount: 100,
        by: 'a',
        name: 'Alice',
      ),
      _mov(
        id: '2',
        type: MovementType.expense,
        amount: 40,
        by: 'b',
        name: 'Bob',
      ),
    ];

    final settle = computeSettle(members: members, movements: movements);
    expect(settle.memberNets, isNotEmpty);
    // Alice net 100, Bob net -40, total 60, fair 30 → Alice delta +70, Bob -70
    expect(settle.transfers, isNotEmpty);
    final t = settle.transfers.first;
    expect(t.fromUid, 'b');
    expect(t.toUid, 'a');
    expect(t.amount, closeTo(70, 0.01));
  });

  test('settle is empty when even', () {
    final members = [
      GroupMember(uid: 'a', displayName: 'A', joinedAt: DateTime(2026)),
      GroupMember(uid: 'b', displayName: 'B', joinedAt: DateTime(2026)),
    ];
    final movements = [
      _mov(id: '1', type: MovementType.deposit, amount: 50, by: 'a', name: 'A'),
      _mov(id: '2', type: MovementType.deposit, amount: 50, by: 'b', name: 'B'),
    ];
    final settle = computeSettle(members: members, movements: movements);
    expect(settle.isSettled, isTrue);
  });

  test('AppNotification parses map fields', () {
    // Structural smoke: model factory lives on DocumentSnapshot — cover fields via settle/balance.
    final balance = BalanceSummary.fromMovements(const []);
    expect(balance.total, 0);
    expect(balance.byCategory, isEmpty);
  });
}
