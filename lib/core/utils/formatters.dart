import 'dart:math';

import 'package:intl/intl.dart';

String generateInviteCode({int length = 6}) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
}

String formatMoney(num amount, {String currency = 'MAD'}) {
  final abs = amount.abs();
  final formatted = abs.toStringAsFixed(2);
  final sign = amount < 0 ? '-' : '';
  return '$sign$formatted $currency';
}

String signedAmount(num amount, String type, {String currency = 'MAD'}) {
  final signed = type == 'expense' ? -amount.abs() : amount.abs();
  final prefix = signed >= 0 ? '+' : '';
  return '$prefix${formatMoney(signed, currency: currency)}';
}

/// Full calendar date, e.g. 9 Aug 2026
String formatMovementDate(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date.toLocal());
}

/// Time of day, e.g. 18:41
String formatMovementTime(DateTime date, {String? locale}) {
  return DateFormat.Hm(locale).format(date.toLocal());
}

/// Date + time for details, e.g. 9 Aug 2026 · 18:41
String formatMovementDateTime(DateTime date, {String? locale}) {
  return '${formatMovementDate(date, locale: locale)} · ${formatMovementTime(date, locale: locale)}';
}
