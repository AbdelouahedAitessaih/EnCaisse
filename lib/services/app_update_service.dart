import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateConfig {
  const AppUpdateConfig({
    required this.minVersionCode,
    required this.latestVersionCode,
    required this.forceUpdate,
    this.message,
    this.playStoreUrl,
    this.appStoreUrl,
  });

  final int minVersionCode;
  final int latestVersionCode;
  final bool forceUpdate;
  final String? message;
  final String? playStoreUrl;
  final String? appStoreUrl;

  factory AppUpdateConfig.fromMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    return AppUpdateConfig(
      minVersionCode: (map['minVersionCode'] as num?)?.toInt() ?? 1,
      latestVersionCode: (map['latestVersionCode'] as num?)?.toInt() ?? 1,
      forceUpdate: map['forceUpdate'] as bool? ?? false,
      message: map['message'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      appStoreUrl: map['appStoreUrl'] as String?,
    );
  }
}

enum AppUpdateAction {
  none,
  softUpdate,
  forceUpdate,
}

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.action,
    required this.config,
    required this.currentVersionCode,
    required this.currentVersionName,
  });

  final AppUpdateAction action;
  final AppUpdateConfig config;
  final int currentVersionCode;
  final String currentVersionName;
}

class AppUpdateService {
  AppUpdateService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const playStorePackageUrl =
      'https://play.google.com/store/apps/details?id=com.encaisse.encaisse';

  /// Set real App Store ID in Firestore `config/appUpdate.appStoreUrl` when live.
  static const appStoreSearchUrl =
      'https://apps.apple.com/search?term=EnCaisse';

  Future<AppUpdateDecision> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentCode = int.tryParse(info.buildNumber) ?? 1;
    final config = await _loadConfig();

    final AppUpdateAction action;
    if (currentCode < config.minVersionCode ||
        (config.forceUpdate && currentCode < config.latestVersionCode)) {
      action = AppUpdateAction.forceUpdate;
    } else if (currentCode < config.latestVersionCode) {
      action = AppUpdateAction.softUpdate;
    } else {
      action = AppUpdateAction.none;
    }

    return AppUpdateDecision(
      action: action,
      config: config,
      currentVersionCode: currentCode,
      currentVersionName: info.version,
    );
  }

  Future<AppUpdateConfig> _loadConfig() async {
    try {
      final snap = await _db.collection('config').doc('appUpdate').get();
      if (!snap.exists) {
        return const AppUpdateConfig(
          minVersionCode: 1,
          latestVersionCode: 1,
          forceUpdate: false,
        );
      }
      return AppUpdateConfig.fromMap(snap.data());
    } catch (e, st) {
      debugPrint('App update config load failed: $e\n$st');
      return const AppUpdateConfig(
        minVersionCode: 1,
        latestVersionCode: 1,
        forceUpdate: false,
      );
    }
  }

  /// Prefer Play in-app update on Android; open the correct store otherwise.
  Future<bool> startUpdate({
    required bool immediate,
    AppUpdateConfig? config,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          if (immediate && info.immediateUpdateAllowed) {
            final result = await InAppUpdate.performImmediateUpdate();
            return result == AppUpdateResult.success;
          }
          if (!immediate && info.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
            return true;
          }
          if (info.immediateUpdateAllowed) {
            final result = await InAppUpdate.performImmediateUpdate();
            return result == AppUpdateResult.success;
          }
          if (info.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
            return true;
          }
        }
      } catch (e, st) {
        debugPrint('In-app update failed, opening store: $e\n$st');
      }
    }
    return openStore(config: config);
  }

  Future<bool> openStore({AppUpdateConfig? config, String? url}) async {
    final resolved = url?.trim().isNotEmpty == true
        ? url!.trim()
        : storeUrlForPlatform(config);
    final uri = Uri.parse(resolved);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  String storeUrlForPlatform(AppUpdateConfig? config) {
    if (!kIsWeb && Platform.isIOS) {
      final ios = config?.appStoreUrl?.trim();
      if (ios != null && ios.isNotEmpty) return ios;
      return appStoreSearchUrl;
    }
    final play = config?.playStoreUrl?.trim();
    if (play != null && play.isNotEmpty) return play;
    return playStorePackageUrl;
  }

  @Deprecated('Use openStore')
  Future<bool> openPlayStore({String? url}) => openStore(url: url);
}
