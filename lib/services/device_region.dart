import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Resolves the phone country from SIM / network / system region.
/// Language alone is never treated as a country (English ≠ United States).
class DeviceRegion {
  DeviceRegion._();

  static const _channel = MethodChannel('encaisse/device_region');
  static Future<String?>? _pending;
  static String? _cached;

  static Future<void> preload() async {
    await countryCode();
  }

  static Future<String?> countryCode() {
    if (_cached != null) return Future.value(_cached);
    return _pending ??= _resolve().whenComplete(() => _pending = null);
  }

  static Future<String?> timeZoneId() async {
    try {
      return await _channel.invokeMethod<String>('getTimeZoneId');
    } catch (e) {
      debugPrint('DeviceRegion native timezone failed: $e');
      return null;
    }
  }

  static Future<String?> _resolve() async {
    try {
      final native = await _channel.invokeMethod<String>('getCountryCode');
      final code = _normalize(native);
      if (code != null) {
        _cached = code;
        return _cached;
      }
    } catch (e) {
      debugPrint('DeviceRegion native country failed: $e');
    }

    for (final locale in PlatformDispatcher.instance.locales) {
      final code = _normalize(locale.countryCode);
      if (code != null) {
        _cached = code;
        return _cached;
      }
    }
    return null;
  }

  static String? _normalize(String? raw) {
    final code = raw?.trim().toUpperCase();
    if (code == null || code.length != 2) return null;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) return null;
    return code;
  }
}
