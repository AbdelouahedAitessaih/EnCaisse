import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../l10n/category_localizations.dart';
import '../models/models.dart';
import 'app_components.dart';

/// One movement in a list.
///
/// The row answers "what happened, and how much" without decoration: an arrow
/// and the sign carry the direction, the amount is set largest in tabular
/// figures on the trailing edge, and metadata stays quiet underneath. Rows are
/// separated by a hairline rather than being individually carded.
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tones = context.semantic;
    final isDeposit = movement.type == MovementType.deposit;
    final accent = isDeposit ? tones.positive : tones.negative;
    final surface = isDeposit ? tones.positiveSurface : tones.negativeSurface;
    final locale = Localizations.localeOf(context).toString();
    final largeText = MediaQuery.textScalerOf(context).scale(16) >= 18;
    final date = formatMovementDate(movement.createdAt, locale: locale);
    final hasReceipt = movement.hasReceipt;

    final l10n = AppLocalizations.of(context);
    final foreign = movement.isForeignCurrency
        ? formatMoney(
            movement.originalAmount!,
            currency: movement.originalCurrency!,
            locale: locale,
          )
        : null;
    final meta = [
      l10n.categoryLabel(movement.category),
      date,
      // On compact rows the original amount sits under the converted one.
      if (foreign != null && largeText) foreign,
      if (movement.hasSplit) l10n.splitCount(movement.split!.length),
      if (movement.recurringId != null) l10n.recurringBadge,
      if (hasReceipt) l10n.receipt,
    ].join(' · ');

    final signedAmount = isDeposit ? movement.amount : -movement.amount;
    final ink = isDeposit ? tones.positiveInk : tones.negativeInk;
    // The direction arrows and the slide-in origin have to mirror in Arabic.
    final rtl = Directionality.of(context) == TextDirection.rtl;

    Widget buildAmount(TextStyle? style) => AppAmount(
      amount: signedAmount,
      currency: currency,
      semantic: tones,
      style: style ?? theme.textTheme.titleMedium?.asMoneyInline(color: ink),
    );

    final title = Text(
      movement.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium,
    );

    final metaLine = Row(
      children: [
        if (hasReceipt) ...[
          Icon(Icons.attach_file, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Flexible(
          child: Text(
            meta,
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: AppSizes.avatarMd,
          height: AppSizes.avatarMd,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.field),
          ),
          child: Icon(
            isDeposit
                ? (rtl ? Icons.south_west : Icons.south_east)
                : (rtl ? Icons.north_west : Icons.north_east),
            color: accent,
            size: AppSizes.iconMd,
          ),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              const SizedBox(height: AppSpacing.xxs),
              metaLine,
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (!largeText)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildAmount(null),
              if (foreign != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(foreign, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
      ],
    );

    final child = Material(
      color: scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.smd,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outline)),
          ),
          child: largeText
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: AppSpacing.sm),
                        buildAmount(
                          theme.textTheme.titleLarge?.asMoneyInline(color: ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    metaLine,
                  ],
                )
              : body,
        ),
      ),
    );

    if (!animateIn) return child;

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(rtl ? -0.06 : 0.06, 0), end: Offset.zero),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, offset, c) {
        return FractionalTranslation(
          translation: offset,
          child: Opacity(opacity: 1 - offset.dx.abs() * 10, child: c),
        );
      },
      child: child,
    );
  }
}
