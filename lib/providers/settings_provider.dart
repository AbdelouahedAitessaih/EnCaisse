import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeMode = 'settings_theme_mode';
const _kLocale = 'settings_locale';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      themeMode: _themeFromStorage(prefs.getString(_kThemeMode)),
      locale: _localeFromStorage(prefs.getString(_kLocale)),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_kLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  static ThemeMode _themeFromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Locale _localeFromStorage(String? raw) {
    switch (raw) {
      case 'fr':
        return const Locale('fr');
      case 'ar':
        return const Locale('ar');
      case 'es':
        return const Locale('es');
      case 'pt':
        return const Locale('pt');
      case 'zh':
        return const Locale('zh');
      case 'hi':
        return const Locale('hi');
      case 'ru':
        return const Locale('ru');
      case 'ja':
        return const Locale('ja');
      default:
        return const Locale('en');
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

const supportedLocales = <Locale>[
  Locale('en'),
  Locale('fr'),
  Locale('ar'),
  Locale('es'),
  Locale('pt'),
  Locale('zh'),
  Locale('hi'),
  Locale('ru'),
  Locale('ja'),
];
