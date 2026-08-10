import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class EncaisseRefreshIndicator extends StatelessWidget {
  const EncaisseRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: scheme.surface,
      displacement: 48,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
