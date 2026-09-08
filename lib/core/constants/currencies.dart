import 'package:intl/intl.dart';

/// Currencies available when creating a group.
abstract final class AppCurrencies {
  static const List<String> codes = [
    'USD',
    'GBP',
    'EUR',
    'CHF',
    'CAD',
    'MAD',
    'AED',
    'SAR',
    'EGP',
    'TND',
    'DZD',
    'MXN',
    'ARS',
    'COP',
    'CLP',
    'BRL',
    'CNY',
    'HKD',
    'TWD',
    'INR',
    'RUB',
    'JPY',
  ];

  /// Zero-decimal currencies (ISO 4217).
  static const Set<String> zeroDecimal = {'JPY', 'CLP'};

  /// ISO country → currency. Only official mappings for currencies we list.
  static const Map<String, String> countryToCurrency = {
    // USD
    'US': 'USD',
    'AS': 'USD',
    'BQ': 'USD',
    'EC': 'USD',
    'FM': 'USD',
    'GU': 'USD',
    'IO': 'USD',
    'MH': 'USD',
    'MP': 'USD',
    'PA': 'USD',
    'PR': 'USD',
    'PW': 'USD',
    'SV': 'USD',
    'TC': 'USD',
    'TL': 'USD',
    'UM': 'USD',
    'VG': 'USD',
    'VI': 'USD',
    // GBP
    'GB': 'GBP',
    'GG': 'GBP',
    'IM': 'GBP',
    'JE': 'GBP',
    // EUR
    'AD': 'EUR',
    'AT': 'EUR',
    'AX': 'EUR',
    'BE': 'EUR',
    'BL': 'EUR',
    'CY': 'EUR',
    'DE': 'EUR',
    'EE': 'EUR',
    'ES': 'EUR',
    'FI': 'EUR',
    'FR': 'EUR',
    'GF': 'EUR',
    'GP': 'EUR',
    'GR': 'EUR',
    'HR': 'EUR',
    'IE': 'EUR',
    'IT': 'EUR',
    'LT': 'EUR',
    'LU': 'EUR',
    'LV': 'EUR',
    'MC': 'EUR',
    'ME': 'EUR',
    'MF': 'EUR',
    'MQ': 'EUR',
    'MT': 'EUR',
    'NL': 'EUR',
    'PM': 'EUR',
    'PT': 'EUR',
    'RE': 'EUR',
    'SI': 'EUR',
    'SK': 'EUR',
    'SM': 'EUR',
    'VA': 'EUR',
    'XK': 'EUR',
    'YT': 'EUR',
    // Other listed currencies
    'CH': 'CHF',
    'LI': 'CHF',
    'CA': 'CAD',
    'MA': 'MAD',
    'EH': 'MAD',
    'AE': 'AED',
    'SA': 'SAR',
    'EG': 'EGP',
    'TN': 'TND',
    'DZ': 'DZD',
    'MX': 'MXN',
    'AR': 'ARS',
    'CO': 'COP',
    'CL': 'CLP',
    'BR': 'BRL',
    'CN': 'CNY',
    'HK': 'HKD',
    'TW': 'TWD',
    'IN': 'INR',
    'RU': 'RUB',
    'JP': 'JPY',
  };

  /// Currency for an ISO country. Returns null when the country is unknown
  /// so the UI does not invent USD from an English language setting.
  static String? codeForCountry(String? countryCode) {
    final country = countryCode?.trim().toUpperCase();
    if (country == null || country.isEmpty) return null;
    final code = countryToCurrency[country];
    if (code != null && codes.contains(code)) return code;
    return null;
  }

  static int decimalDigits(String code) =>
      zeroDecimal.contains(code.toUpperCase()) ? 0 : 2;

  /// Localized label, e.g. "EUR (€) — Euro" in the current UI language.
  static String label(String code, String locale) {
    final upper = code.toUpperCase();
    try {
      final format = NumberFormat.currency(
        name: upper,
        locale: locale,
        decimalDigits: decimalDigits(upper),
      );
      final symbol = format.currencySymbol.trim();
      final name = format.currencyName?.trim();
      final symbolPart =
          symbol.isNotEmpty && symbol != upper ? ' ($symbol)' : '';
      if (name != null && name.isNotEmpty && name.toUpperCase() != upper) {
        return '$upper$symbolPart — $name';
      }
      return '$upper$symbolPart';
    } catch (_) {
      return upper;
    }
  }

  /// Codes ordered with the preferred currency first, then the rest A–Z.
  static List<String> codesPreferredFirst(String? preferred) {
    final rest = codes.where((c) => c != preferred).toList()..sort();
    if (preferred != null && codes.contains(preferred)) {
      return [preferred, ...rest];
    }
    return List<String>.from(codes)..sort();
  }
}
