import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

/// Animated count-up / count-down for balance changes.
class AnimatedBalance extends StatelessWidget {
  const AnimatedBalance({
    super.key,
    required this.value,
    required this.currency,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  final double value;
  final String currency;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final baseStyle = style ??
        Theme.of(context).textTheme.displayLarge?.copyWith(
              color: value >= 0 ? AppColors.primary : AppColors.accent,
            );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text(
          formatMoney(animated, currency: currency, locale: locale),
          style: baseStyle,
        );
      },
    );
  }
}
