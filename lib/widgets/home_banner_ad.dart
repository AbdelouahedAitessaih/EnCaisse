import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/providers.dart';

/// Banner ad for Home only. Uses TEST ad unit IDs from [AdMobConfig].
class HomeBannerAd extends ConsumerStatefulWidget {
  const HomeBannerAd({super.key});

  @override
  ConsumerState<HomeBannerAd> createState() => _HomeBannerAdState();
}

class _HomeBannerAdState extends ConsumerState<HomeBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final ads = ref.read(adServiceProvider);
    await ads.initialize();
    await ads.loadHomeBanner(
      onLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _ad = ad;
          _loaded = true;
        });
      },
      onFailed: (_) {
        if (!mounted) return;
        setState(() => _loaded = false);
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: AppColors.primaryLight,
        child: const Text(
          // ⚠️ TEST AD PLACEHOLDER — swap AdMobConfig before release
          'Ad space (test IDs) — replace AdMobConfig before release',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            '⚠️ Using AdMob TEST IDs — swap before release',
            style: TextStyle(fontSize: 10, color: AppColors.accent),
          ),
        ),
        SizedBox(
          width: _ad!.size.width.toDouble(),
          height: _ad!.size.height.toDouble(),
          child: AdWidget(ad: _ad!),
        ),
      ],
    );
  }
}
