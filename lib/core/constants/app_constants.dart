/// App-wide constants. Credentials and ad IDs are placeholders — swap before release.
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

/// ⚠️ REPLACE BEFORE RELEASE — AdMob test IDs only.
/// Get real IDs from https://admob.google.com
abstract final class AdMobConfig {
  /// Android app ID — also set in AndroidManifest.xml
  static const String androidAppId =
      'ca-app-pub-7691333173853968~2642191347';

  /// iOS app ID — also set in Info.plist
  /// TODO: create an iOS app in AdMob and replace if different from Android.
  static const String iosAppId =
      'ca-app-pub-7691333173853968~2642191347';

  /// Banner on Home screen only
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/9244806876';
  /// Same unit until a dedicated iOS Banner is created in AdMob.
  static const String bannerAdUnitIdIos =
      'ca-app-pub-7691333173853968/9244806876';

  /// Interstitial after creating 3rd group
  static const String interstitialAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/2450619655';
  /// Same unit until a dedicated iOS Interstitial is created in AdMob.
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
