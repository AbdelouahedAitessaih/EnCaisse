import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_constants.dart';

/// AdMob banners + interstitials (production unit IDs in [AdMobConfig]).
class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    await _loadInterstitial();
  }

  String get _bannerUnitId {
    if (kIsWeb) return '';
    return Platform.isIOS
        ? AdMobConfig.bannerAdUnitIdIos
        : AdMobConfig.bannerAdUnitIdAndroid;
  }

  String get _interstitialUnitId {
    if (kIsWeb) return '';
    return Platform.isIOS
        ? AdMobConfig.interstitialAdUnitIdIos
        : AdMobConfig.interstitialAdUnitIdAndroid;
  }

  BannerAd? get bannerAd => _bannerAd;

  Future<BannerAd?> loadHomeBanner({
    required void Function(BannerAd ad) onLoaded,
    void Function(LoadAdError error)? onFailed,
  }) async {
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed?.call(error);
        },
      ),
      request: const AdRequest(),
    );
    await ad.load();
    _bannerAd = ad;
    return ad;
  }

  Future<void> _loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial only at natural break points (e.g. after 3rd group).
  Future<void> showInterstitialIfReady() async {
    final ad = _interstitialAd;
    if (ad == null) {
      await _loadInterstitial();
      return;
    }
    await ad.show();
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
