import 'dart:math';

import '../constants/currencies.dart';

int _factor(String currency) =>
    pow(10, AppCurrencies.decimalDigits(currency)).toInt();

/// [amount] in whole minor units of [currency] (cents, or yen).
int toMinorUnits(double amount, String currency) =>
    (amount * _factor(currency)).round();

/// [amount] rounded to the precision [currency] supports.
double roundToCurrency(double amount, String currency) =>
    toMinorUnits(amount, currency) / _factor(currency);

/// Splits [amount] equally between [uids] in whole minor units. The leftover
/// cents go to the first members, so the shares always add up to exactly
/// [amount]; members whose share rounds to zero are left out.
Map<String, double> equalSplit(
  double amount,
  List<String> uids,
  String currency,
) {
  if (uids.isEmpty) return const {};
  final factor = _factor(currency);
  final totalMinor = toMinorUnits(amount, currency);
  final base = totalMinor ~/ uids.length;
  var remainder = totalMinor - base * uids.length;
  final result = <String, double>{};
  for (final uid in uids) {
    var minor = base;
    if (remainder > 0) {
      minor++;
      remainder--;
    }
    if (minor > 0) result[uid] = minor / factor;
  }
  return result;
}

/// True when [shares] add up to exactly [amount] in minor units.
bool splitMatchesAmount(
  Map<String, double> shares,
  double amount,
  String currency,
) {
  final total = shares.values.fold<int>(
    0,
    (sum, share) => sum + toMinorUnits(share, currency),
  );
  return total == toMinorUnits(amount, currency);
}
