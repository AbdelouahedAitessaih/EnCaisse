/// App-wide constants.
library;

abstract final class AppConstants {
  static const String appName = 'EnCaisse';
  static const String tagline = 'EnCaisse, ensemble.';
  static const int inviteCodeLength = 6;

  /// Landing page served by Firebase Hosting (docs/play-store/join.html).
  static String inviteLink(String code) =>
      'https://encaisse-3c7fb.web.app/join/$code';
  static const Duration softDeleteWindow = Duration(hours: 24);
  static const int groupsBeforeInterstitial = 3;
  static const int movementsBeforeReview = 5;

  /// Category keys used for storage. Display labels are localized via AppLocalizations.
  static const List<String> categoryKeys = [
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

  /// Backward compatibility — returns English keys.
  @Deprecated('Use AppLocalizations extension instead')
  static const List<String> categories = categoryKeys;
}

/// Production AdMob IDs (Android app Ready in AdMob).
/// Banner: Home. Interstitial: after creating the 3rd group.
abstract final class AdMobConfig {
  /// Android app ID — also set in AndroidManifest.xml
  static const String androidAppId = 'ca-app-pub-7691333173853968~2642191347';

  /// iOS AdMob app ID — create a dedicated iOS app in AdMob and replace.
  /// Until then, uses the same publisher app entry as Android (ads may be limited on iOS).
  static const String iosAppId = 'ca-app-pub-7691333173853968~2642191347';

  /// Banner on Home screen only
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/9244806876';

  /// iOS banner unit — replace with AdMob iOS unit when available.
  static const String bannerAdUnitIdIos =
      'ca-app-pub-7691333173853968/9244806876';

  /// Interstitial after creating 3rd group
  static const String interstitialAdUnitIdAndroid =
      'ca-app-pub-7691333173853968/2450619655';

  /// iOS interstitial unit — replace with AdMob iOS unit when available.
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
