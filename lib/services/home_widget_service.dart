import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes a plain-text summary of the user's caisses to the Android
/// home-screen widget (`BalanceWidgetProvider`).
class HomeWidgetService {
  static const _androidProvider = 'com.encaisse.encaisse.BalanceWidgetProvider';
  static const _titleKey = 'widget_title';
  static const _bodyKey = 'widget_body';
  static const _updatedKey = 'widget_updated';

  String? _lastPublished;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> publish({
    required String title,
    required String body,
    required String updated,
  }) async {
    if (!_supported) return;
    final signature = '$title\u0000$body';
    if (signature == _lastPublished) return;
    _lastPublished = signature;
    try {
      await HomeWidget.saveWidgetData<String>(_titleKey, title);
      await HomeWidget.saveWidgetData<String>(_bodyKey, body);
      await HomeWidget.saveWidgetData<String>(_updatedKey, updated);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider);
    } catch (e) {
      _lastPublished = null;
      debugPrint('Home widget update failed: $e');
    }
  }

  /// Wipes balances from the home screen, e.g. after sign-out, so they are
  /// not left visible on a shared device.
  Future<void> clear() async {
    if (!_supported) return;
    _lastPublished = null;
    try {
      await HomeWidget.saveWidgetData<String>(_titleKey, null);
      await HomeWidget.saveWidgetData<String>(_bodyKey, null);
      await HomeWidget.saveWidgetData<String>(_updatedKey, null);
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider);
    } catch (e) {
      debugPrint('Home widget clear failed: $e');
    }
  }
}
