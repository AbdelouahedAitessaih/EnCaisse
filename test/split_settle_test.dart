import 'package:encaisse/core/utils/settle.dart';
import 'package:encaisse/core/utils/split.dart';
import 'package:encaisse/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 1, 1);

GroupMember _member(String uid) =>
    GroupMember(uid: uid, displayName: uid.toUpperCase(), joinedAt: _now);

Movement _movement({
  required MovementType type,
  required double amount,
  required String by,
  Map<String, double>? split,
}) => Movement(
  id: '$by-$amount-${type.name}',
  type: type,
  amount: amount,
  title: 't',
  category: 'other',
  createdBy: by,
  createdByName: by.toUpperCase(),
  createdAt: _now,
  updatedAt: _now,
  updatedBy: by,
  split: split,
);

void main() {
  group('equalSplit', () {
    test('gives leftover cents to the first members and sums exactly', () {
      final shares = equalSplit(10, ['a', 'b', 'c'], 'EUR');
      expect(shares, {'a': 3.34, 'b': 3.33, 'c': 3.33});
      expect(splitMatchesAmount(shares, 10, 'EUR'), isTrue);
    });

    test('respects zero-decimal currencies', () {
      final shares = equalSplit(100, ['a', 'b', 'c'], 'JPY');
      expect(shares, {'a': 34, 'b': 33, 'c': 33});
    });

    test('drops members whose share rounds to zero', () {
      expect(equalSplit(0.01, ['a', 'b'], 'EUR'), {'a': 0.01});
      expect(equalSplit(5, const [], 'EUR'), isEmpty);
    });

    test('splitMatchesAmount rejects mismatched shares', () {
      expect(splitMatchesAmount({'a': 4, 'b': 5}, 10, 'EUR'), isFalse);
    });
  });

  group('computeSettle with splits', () {
    final members = [_member('a'), _member('b')];

    test('legacy movements are attributed to their author', () {
      final summary = computeSettle(
        members: members,
        movements: [
          _movement(type: MovementType.deposit, amount: 100, by: 'a'),
          _movement(type: MovementType.deposit, amount: 50, by: 'b'),
        ],
      );
      expect(summary.transfers, hasLength(1));
      expect(summary.transfers.single.fromUid, 'b');
      expect(summary.transfers.single.toUid, 'a');
      expect(summary.transfers.single.amount, 25);
    });

    test('a split expense is charged to each participant', () {
      final summary = computeSettle(
        members: members,
        movements: [
          _movement(type: MovementType.deposit, amount: 100, by: 'a'),
          _movement(type: MovementType.deposit, amount: 100, by: 'b'),
          _movement(
            type: MovementType.expense,
            amount: 60,
            by: 'a',
            split: {'b': 60},
          ),
        ],
      );
      final nets = {for (final m in summary.memberNets) m.uid: m.net};
      expect(nets, {'a': 100, 'b': 40});
      expect(summary.transfers.single.fromUid, 'b');
      expect(summary.transfers.single.toUid, 'a');
      expect(summary.transfers.single.amount, 30);
    });

    test('deleted movements are ignored', () {
      final summary = computeSettle(
        members: members,
        movements: [
          _movement(type: MovementType.deposit, amount: 80, by: 'a'),
          _movement(type: MovementType.deposit, amount: 80, by: 'b'),
          Movement(
            id: 'gone',
            type: MovementType.expense,
            amount: 50,
            title: 't',
            category: 'other',
            createdBy: 'a',
            createdByName: 'A',
            createdAt: _now,
            updatedAt: _now,
            updatedBy: 'a',
            deleted: true,
          ),
        ],
      );
      expect(summary.isSettled, isTrue);
    });
  });
}
