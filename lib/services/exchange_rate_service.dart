import 'dart:convert';

import 'package:http/http.dart' as http;

/// Indicative exchange rates used to prefill the rate when a movement is typed
/// in another currency. The person can always overwrite the rate, so a failed
/// lookup returns null instead of throwing.
class ExchangeRateService {
  ExchangeRateService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, ({DateTime fetchedAt, Map<String, double> rates})> _cache =
      {};

  static const _ttl = Duration(hours: 6);

  /// Units of [to] for one unit of [from], or null when unavailable.
  Future<double?> rate({required String from, required String to}) async {
    final base = from.toUpperCase();
    final target = to.toUpperCase();
    if (base == target) return 1;
    final cached = _cache[base];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < _ttl) {
      return cached.rates[target];
    }
    try {
      final response = await _client
          .get(Uri.parse('https://open.er-api.com/v6/latest/$base'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map ||
          body['result'] != 'success' ||
          body['rates'] is! Map) {
        return null;
      }
      final rates = <String, double>{};
      (body['rates'] as Map).forEach((key, value) {
        if (key is String && value is num && value > 0) {
          rates[key] = value.toDouble();
        }
      });
      _cache[base] = (fetchedAt: DateTime.now(), rates: rates);
      return rates[target];
    } catch (_) {
      return null;
    }
  }
}
