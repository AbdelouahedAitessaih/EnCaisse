import 'package:flutter_test/flutter_test.dart';

import 'package:encaisse/core/constants/app_constants.dart';
import 'package:encaisse/models/models.dart';

void main() {
  test('balance is derived from non-deleted movements', () {
    final movements = [
      Movement(
        id: '1',
        type: MovementType.deposit,
        amount: 100,
        title: 'In',
        category: 'Other',
        createdBy: 'u',
        createdByName: 'A',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        updatedBy: 'u',
      ),
      Movement(
        id: '2',
        type: MovementType.expense,
        amount: 40,
        title: 'Out',
        category: 'Food',
        createdBy: 'u',
        createdByName: 'A',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        updatedBy: 'u',
      ),
      Movement(
        id: '3',
        type: MovementType.expense,
        amount: 10,
        title: 'Deleted',
        category: 'Food',
        createdBy: 'u',
        createdByName: 'A',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        updatedBy: 'u',
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
}
