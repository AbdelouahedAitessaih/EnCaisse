import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    required this.currency,
    required this.onTap,
    this.animateIn = false,
  });

  final Movement movement;
  final String currency;
  final VoidCallback onTap;
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDeposit = movement.type == MovementType.deposit;
    final color = isDeposit ? AppColors.deposit : AppColors.expense;
    final iconBg = isDeposit
        ? (isDark
            ? AppColors.deposit.withValues(alpha: 0.18)
            : AppColors.primaryLight)
        : (isDark
            ? AppColors.expense.withValues(alpha: 0.18)
            : AppColors.accentLight);
    final locale = Localizations.localeOf(context).toString();
    final date = formatMovementDate(movement.createdAt, locale: locale);
    final time = formatMovementTime(movement.createdAt, locale: locale);

    final child = Material(
      color: scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outline)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${movement.category} · ${movement.createdByName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$date · $time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (movement.hasReceipt) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            AppLocalizations.of(context).receipt,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                signedAmount(movement.amount, movement.type.value,
                    currency: currency),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!animateIn) return child;

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.08, 0), end: Offset.zero),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, offset, c) {
        return FractionalTranslation(
          translation: offset,
          child: Opacity(
            opacity: 1 - offset.dx * 8,
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
