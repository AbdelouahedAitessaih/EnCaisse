import '../../models/models.dart';

/// One member's contribution position in the shared pot.
class MemberNet {
  const MemberNet({
    required this.uid,
    required this.displayName,
    required this.deposits,
    required this.expenses,
    required this.net,
    required this.delta,
  });

  final String uid;
  final String displayName;
  final double deposits;
  final double expenses;

  /// Deposits − expenses for this member.
  final double net;

  /// [net] − equal share of group balance. Positive = owed by others.
  final double delta;
}

/// Minimal transfer to even member positions.
class SettleTransfer {
  const SettleTransfer({
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.amount,
  });

  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final double amount;
}

class SettleSummary {
  const SettleSummary({
    required this.memberNets,
    required this.transfers,
  });

  final List<MemberNet> memberNets;
  final List<SettleTransfer> transfers;

  bool get isSettled => transfers.isEmpty;
}

/// Equal-share settle for a shared caisse (not itemized IOU split).
SettleSummary computeSettle({
  required List<GroupMember> members,
  required List<Movement> movements,
  List<Settlement> settlements = const [],
}) {
  if (members.isEmpty) {
    return const SettleSummary(memberNets: [], transfers: []);
  }

  final depositsBy = <String, double>{};
  final expensesBy = <String, double>{};
  for (final m in members) {
    depositsBy[m.uid] = 0;
    expensesBy[m.uid] = 0;
  }

  for (final mov in movements) {
    if (mov.deleted) continue;
    if (!depositsBy.containsKey(mov.createdBy)) {
      depositsBy[mov.createdBy] = 0;
      expensesBy[mov.createdBy] = 0;
    }
    if (mov.type == MovementType.deposit) {
      depositsBy[mov.createdBy] =
          (depositsBy[mov.createdBy] ?? 0) + mov.amount.abs();
    } else {
      expensesBy[mov.createdBy] =
          (expensesBy[mov.createdBy] ?? 0) + mov.amount.abs();
    }
  }

  for (final payment in settlements) {
    if (payment.status != SettlementStatus.confirmed) continue;
    depositsBy[payment.fromUid] =
        (depositsBy[payment.fromUid] ?? 0) + payment.amount.abs();
    expensesBy[payment.toUid] =
        (expensesBy[payment.toUid] ?? 0) + payment.amount.abs();
  }

  final names = <String, String>{
    for (final m in members) m.uid: m.displayName,
  };
  for (final mov in movements) {
    if (mov.deleted) continue;
    names.putIfAbsent(
      mov.createdBy,
      () => mov.createdByName.trim().isNotEmpty
          ? mov.createdByName
          : mov.createdBy,
    );
  }
  for (final payment in settlements) {
    if (payment.status != SettlementStatus.confirmed) continue;
    names.putIfAbsent(payment.fromUid, () => payment.fromName);
    names.putIfAbsent(payment.toUid, () => payment.toName);
  }

  final uids = {...depositsBy.keys, ...expensesBy.keys, ...names.keys};
  final nets = <MemberNet>[];
  var totalNet = 0.0;
  for (final uid in uids) {
    final d = depositsBy[uid] ?? 0;
    final e = expensesBy[uid] ?? 0;
    final net = d - e;
    totalNet += net;
    nets.add(
      MemberNet(
        uid: uid,
        displayName: names[uid] ?? uid,
        deposits: d,
        expenses: e,
        net: net,
        delta: 0,
      ),
    );
  }

  final n = nets.length;
  final fairShare = n == 0 ? 0.0 : totalNet / n;
  final withDelta = nets
      .map(
        (m) => MemberNet(
          uid: m.uid,
          displayName: m.displayName,
          deposits: m.deposits,
          expenses: m.expenses,
          net: m.net,
          delta: m.net - fairShare,
        ),
      )
      .toList()
    ..sort((a, b) => b.delta.compareTo(a.delta));

  final creditors = withDelta
      .where((m) => m.delta > 0.009)
      .map((m) => MapEntry(m, m.delta))
      .toList();
  final debtors = withDelta
      .where((m) => m.delta < -0.009)
      .map((m) => MapEntry(m, -m.delta))
      .toList();

  final transfers = <SettleTransfer>[];
  var i = 0;
  var j = 0;
  while (i < debtors.length && j < creditors.length) {
    final pay = debtors[i].value < creditors[j].value
        ? debtors[i].value
        : creditors[j].value;
    if (pay >= 0.01) {
      transfers.add(
        SettleTransfer(
          fromUid: debtors[i].key.uid,
          fromName: debtors[i].key.displayName,
          toUid: creditors[j].key.uid,
          toName: creditors[j].key.displayName,
          amount: double.parse(pay.toStringAsFixed(2)),
        ),
      );
    }
    debtors[i] = MapEntry(debtors[i].key, debtors[i].value - pay);
    creditors[j] = MapEntry(creditors[j].key, creditors[j].value - pay);
    if (debtors[i].value < 0.01) i++;
    if (creditors[j].value < 0.01) j++;
  }

  return SettleSummary(memberNets: withDelta, transfers: transfers);
}
