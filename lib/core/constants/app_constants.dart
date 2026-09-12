/// App-wide constants.
library;

abstract final class AppConstants {
  static const String appName = 'EnCaisse';
  static const String tagline = 'EnCaisse, ensemble.';
  static const int inviteCodeLength = 6;
  static const Duration softDeleteWindow = Duration(hours: 24);
  static const int groupsBeforeInterstitial = 3;
  static const int movementsBeforeReview = 5;

  static const List<String> categories = [
    'Food',
    'Transport',
    'Rent',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Health',
    'Travel',
    'Salary',
    'Gift',
    'Other',
  ];
}

/// Production AdMob IDs (Android app Ready in AdMob).
/// Banner: Home. Interstitial: after creating the 3rd group.
abstract final class AdMobConfig {
  /// Android app ID — also set in AndroidManifest.xml
  static const String androidAppId =
      'ca-app-pub-7691333173853968~2642191347';

  /// iOS app ID — same until a dedicated iOS AdMob app exists.
  static const String iosAppId =
      'ca-app-pub-7691333173853968~2642191347';

  /// Banner on Home screen only
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/9244806876';
  static const String bannerAdUnitIdIos =
      'ca-app-pub-7691333173853968/9244806876';

  /// Interstitial after creating 3rd group
  static const String interstitialAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/2450619655';
  static const String interstitialAdUnitIdIos =
      'ca-app-pub-7691333173853968/2450619655';
}

/// ⚠️ REPLACE — drop real Firebase config files:
/// - android/app/google-services.json
/// - ios/Runner/GoogleService-Info.plist
/// Then run: flutterfire configure
abstract final class FirebaseSetupNotes {
  static const String placeholderNotice =
      'Firebase credentials are placeholders. Replace google-services.json and '
      'GoogleService-Info.plist with your Firebase project files before running.';
}
