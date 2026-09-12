import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/providers.dart';

/// Banner ad on Home. Uses production AdMob unit IDs from [AdMobConfig].
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
        setState(() {
          _ad = null;
          _loaded = false;
        });
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
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: _ad!.size.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: _ad!.size.width.toDouble(),
              height: _ad!.size.height.toDouble(),
              child: AdWidget(ad: _ad!),
            ),
          ),
        ),
      ),
    );
  }
}
