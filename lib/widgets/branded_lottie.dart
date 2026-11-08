import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'spot_illustration.dart';
import 'zellige_pattern.dart';

/// Branded Lottie with CustomPainter fallback if asset fails.
class BrandedLottie extends StatelessWidget {
  const BrandedLottie({
    super.key,
    required this.asset,
    this.height = 180,
    this.repeat = true,
  });

  final String asset;
  final double height;
  final bool repeat;

  static const _spots = <String, SpotKind>{
    'assets/lottie/onboarding_1.json': SpotKind.caisse,
    'assets/lottie/onboarding_2.json': SpotKind.audit,
    'assets/lottie/onboarding_3.json': SpotKind.invite,
    'assets/lottie/empty_group.json': SpotKind.groups,
    'assets/lottie/empty_movements.json': SpotKind.movements,
    'assets/lottie/empty.json': SpotKind.inbox,
    'assets/lottie/success.json': SpotKind.success,
  };

  @override
  Widget build(BuildContext context) {
    final spot = _spots[asset];
    if (spot != null) {
      return SizedBox(
        height: height,
        child: Center(
          child: SpotIllustration(
            kind: spot,
            size: height,
            animate: repeat || spot == SpotKind.success,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Lottie.asset(
        asset,
        fit: BoxFit.contain,
        repeat: repeat,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: ZelligePattern(size: height * 0.85)),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = 'assets/lottie/empty.json',
    this.action,
  });

  final String title;
  final String subtitle;
  final String asset;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandedLottie(asset: asset, height: 140),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        );

        if (constraints.maxHeight.isFinite) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.92),
      child: const Center(
        child: BrandedLottie(
          asset: 'assets/lottie/success.json',
          height: 160,
          repeat: false,
        ),
      ),
    );
  }
}
