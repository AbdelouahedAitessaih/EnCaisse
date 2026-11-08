import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

/// Shared primitives for the EnCaisse design language.
///
/// The rules these encode:
///  * a card is a bordered surface, never a shadowed floating box;
///  * money is set in tabular figures and carries its sign and tone, so a row
///    can be read without decoding colour;
///  * icon-only controls keep a 48dp target and always carry a semantic label.

/// Bordered surface. The default grouping device — whitespace and hairlines
/// instead of elevation.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppRadii.md,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border
          ? BorderSide(color: borderColor ?? scheme.outline)
          : BorderSide.none,
    );

    return Material(
      color: color ?? scheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase label that separates sections without a heavy rule.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A money figure. Always signed, always tabular, always paired with a tone
/// that also survives greyscale because the sign carries the meaning.
class AppAmount extends StatelessWidget {
  const AppAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.showSign = true,
    this.color,
    this.semantic,
  });

  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showSign;
  final Color? color;
  final AppSemantic? semantic;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatted,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style ?? _defaultStyle(context),
      // Money always reads left-to-right, even inside an Arabic layout.
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.end,
    );
  }

  TextStyle _defaultStyle(BuildContext context) {
    final tones = semantic ?? context.semantic;
    return (Theme.of(
          context,
        ).textTheme.titleMedium)?.asMoneyInline(color: color ?? _tone(tones)) ??
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFeatures: kTabularFigures,
          color: color ?? _tone(tones),
        );
  }

  Color? _tone(AppSemantic tones) =>
      color ??
      (amount < 0
          ? tones.negativeInk
          : amount > 0
          ? tones.positiveInk
          : null);

  String get formatted =>
      '${showSign && amount > 0 ? '+' : ''}${formatMoney(amount, currency: currency)}';
}

/// Label + value pair used in stat rows. Values are tabular.
class AppStat extends StatelessWidget {
  const AppStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontFeatures: kTabularFigures,
          ),
        ),
      ],
    );
  }
}

/// Icon-only control with a guaranteed 48dp target and a mandatory tooltip.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.size = AppSizes.iconMd,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: size),
          color: color ?? theme.colorScheme.onSurfaceVariant,
          style: IconButton.styleFrom(
            minimumSize: const Size(AppTapTarget.min, AppTapTarget.min),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Destructive action. Kept visually distinct from every other control so it
/// can never be mistaken for a primary or secondary action.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !loading;
    final fg = enabled ? scheme.error : scheme.onSurfaceVariant;

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Text(label);

    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: child,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(
          color: enabled
              ? scheme.error.withValues(alpha: 0.45)
              : scheme.outline,
        ),
        minimumSize: const Size.fromHeight(AppSizes.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Neutral pill used for status and metadata.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.color,
    this.background,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: background ?? context.semantic.neutralSurface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: AppSpacing.xs + 1),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page gutter, so every screen aligns to the same edges.
class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: child,
    );
  }
}
