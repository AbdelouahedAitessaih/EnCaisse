import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_components.dart';
import '../core/utils/formatters.dart';
import '../core/utils/settle.dart';
import '../l10n/engagement_copy.dart';
import '../l10n/app_localizations.dart';
import '../l10n/category_localizations.dart';
import '../models/models.dart';

EngagementCopy _copy(BuildContext context) => EngagementCopy.of(context);

class GroupInsightsSection extends StatelessWidget {
  const GroupInsightsSection({
    super.key,
    required this.balance,
    required this.settle,
    required this.currency,
    this.showSettle = true,
    this.currentUid,
    this.settlements = const [],
    this.settlementsError,
    this.onRetrySettlements,
    this.settlingTransferKey,
    this.busySettlementIds = const <String>{},
    this.onRecordPayment,
    this.onMarkReceived,
    this.onRequestPayment,
    this.onConfirmSettlement,
    this.onCancelSettlement,
  });

  final BalanceSummary balance;
  final SettleSummary settle;
  final String currency;
  final bool showSettle;
  final String? currentUid;
  final List<Settlement> settlements;

  /// Set when the settlement history could not be read. Kept separate from an
  /// empty list so a backend failure is never shown as "all settled".
  final String? settlementsError;

  /// Offered next to [settlementsError] so a failed history read is recoverable
  /// without leaving the screen. Without it the only way back is to re-enter.
  final VoidCallback? onRetrySettlements;

  /// Non-null while a record-payment write is in flight. The button is disabled
  /// for every transfer in that time, because the server would read a second
  /// tap as a second payment for the same pair.
  final String? settlingTransferKey;

  /// Settlement ids with a confirm or cancel write in flight. Disabling only
  /// the row that is being written keeps the rest of the history responsive.
  final Set<String> busySettlementIds;
  final Future<void> Function(SettleTransfer transfer)? onRecordPayment;

  /// Offered to the recipient: records money already received, confirmed at once.
  final Future<void> Function(SettleTransfer transfer)? onMarkReceived;

  /// Offered to the recipient: shares a reminder with the person who owes.
  final void Function(SettleTransfer transfer)? onRequestPayment;
  final Future<void> Function(Settlement settlement)? onConfirmSettlement;
  final Future<void> Function(Settlement settlement)? onCancelSettlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tones = context.semantic;
    final cats =
        balance.byCategory.entries.where((e) => e.value > 0.001).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSettle)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settleTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.settleSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!settle.isSettled) ...[
                  const SizedBox(height: 4),
                  Text(
                    _copy(context).settlementExplanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                if (settle.isSettled &&
                    balance.deposits == 0 &&
                    balance.expenses == 0)
                  Text(
                    l10n.noMovementsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if (settle.isSettled)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: context.semantic.positiveInk,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.settleSettled,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: context.semantic.positiveInk),
                        ),
                      ),
                    ],
                  )
                else
                  ...settle.transfers.map((t) {
                    final iAmOwing = currentUid == t.fromUid;
                    final iAmOwed = currentUid == t.toUid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        decoration: BoxDecoration(
                          color: context.semantic.neutralSurface,
                          borderRadius: BorderRadius.circular(AppRadii.field),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // WHO owes WHOM, on separate lines so the
                            // direction is never ambiguous.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    t.fromName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Icon(
                                    // The settlement flows payer -> recipient,
                                    // so the arrow has to mirror in RTL or it
                                    // points at the wrong person.
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.arrow_back
                                        : Icons.arrow_forward,
                                    size: 18,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    t.toName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: AppAmount(
                                      amount: t.amount,
                                      currency: currency,
                                      showSign: false,
                                      color: context.semantic.negativeInk,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontFeatures: kTabularFigures,
                                            color: context.semantic.negativeInk,
                                          ),
                                    ),
                                  ),
                                ),
                                if (iAmOwing || iAmOwed)
                                  AppPill(
                                    label: iAmOwing
                                        ? _copy(context).youOwe
                                        : _copy(context).youAreOwed,
                                    color: context.semantic.negativeInk,
                                    background:
                                        context.semantic.negativeSurface,
                                  ),
                              ],
                            ),
                            if (iAmOwing && onRecordPayment != null) ...[
                              const SizedBox(height: AppSpacing.smd),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: settlingTransferKey != null
                                      ? null
                                      : () => onRecordPayment!(t),
                                  icon: const Icon(
                                    Icons.payments_outlined,
                                    size: 18,
                                  ),
                                  label: Text(_copy(context).recordPayment),
                                ),
                              ),
                            ],
                            if (iAmOwed &&
                                (onMarkReceived != null ||
                                    onRequestPayment != null)) ...[
                              const SizedBox(height: AppSpacing.smd),
                              Row(
                                children: [
                                  if (onMarkReceived != null)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: settlingTransferKey != null
                                            ? null
                                            : () => onMarkReceived!(t),
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                        ),
                                        label: Text(
                                          l10n.markReceived,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  if (onMarkReceived != null &&
                                      onRequestPayment != null)
                                    const SizedBox(width: AppSpacing.sm),
                                  if (onRequestPayment != null)
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () => onRequestPayment!(t),
                                        icon: const Icon(
                                          Icons.send_outlined,
                                          size: 18,
                                        ),
                                        label: Text(
                                          l10n.requestPayment,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                if (settlementsError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.smd),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: scheme.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            settlementsError!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.error),
                          ),
                        ),
                        if (onRetrySettlements != null)
                          TextButton(
                            onPressed: onRetrySettlements,
                            child: Text(AppLocalizations.of(context).retry),
                          ),
                      ],
                    ),
                  )
                else if (settlements.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    _copy(context).settlementHistory,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...settlements.take(5).map((payment) {
                    final isConfirmed =
                        payment.status == SettlementStatus.confirmed;
                    final isCancelled =
                        payment.status == SettlementStatus.cancelled;
                    final statusInk = isConfirmed
                        ? context.semantic.positiveInk
                        : isCancelled
                        ? scheme.onSurfaceVariant
                        : context.semantic.warningInk;
                    final statusBg = isConfirmed
                        ? context.semantic.positiveSurface
                        : isCancelled
                        ? context.semantic.neutralSurface
                        : context.semantic.warningSurface;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          border: Border.all(color: scheme.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isConfirmed
                                      ? Icons.check_circle
                                      : isCancelled
                                      ? Icons.cancel_outlined
                                      : Icons.schedule,
                                  size: 18,
                                  color: statusInk,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _copy(context).paymentLine(
                                      payment.fromName,
                                      payment.toName,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                AppAmount(
                                  amount: payment.amount,
                                  currency: currency,
                                  showSign: false,
                                  color: statusInk,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: statusInk,
                                        fontWeight: FontWeight.w700,
                                        fontFeatures: kTabularFigures,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                AppPill(
                                  label: isConfirmed
                                      ? _copy(context).paymentConfirmed
                                      : isCancelled
                                      ? _copy(context).paymentCancelled
                                      : _copy(context).awaitingConfirmation,
                                  color: statusInk,
                                  background: statusBg,
                                ),
                                const Spacer(),
                                if (!isConfirmed &&
                                    !isCancelled &&
                                    currentUid == payment.toUid &&
                                    onConfirmSettlement != null)
                                  TextButton.icon(
                                    onPressed:
                                        busySettlementIds.contains(payment.id)
                                        ? null
                                        : () => onConfirmSettlement!(payment),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: Text(_copy(context).confirmReceived),
                                  ),
                                if (!isConfirmed &&
                                    !isCancelled &&
                                    currentUid == payment.fromUid &&
                                    onCancelSettlement != null)
                                  TextButton.icon(
                                    onPressed:
                                        busySettlementIds.contains(payment.id)
                                        ? null
                                        : () => onCancelSettlement!(payment),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: Text(l10n.cancel),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                if (settle.memberNets.isNotEmpty) ...[
                  const Divider(height: 24),
                  ...settle.memberNets.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m.delta.abs() < 0.01
                                ? l10n.memberSettled
                                : '${m.delta < 0 ? _copy(context).memberOwes : _copy(context).memberIsOwed} '
                                      '${formatMoney(m.delta.abs(), currency: currency)}',
                            style: TextStyle(
                              color: m.delta >= 0
                                  ? tones.positiveInk
                                  : tones.negativeInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        if (cats.isNotEmpty) ...[
          if (showSettle) const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chartsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.categoryBreakdown,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: [
                        for (var i = 0; i < cats.length && i < 8; i++)
                          PieChartSectionData(
                            value: cats[i].value.abs(),
                            title: '',
                            color: _colorAt(i),
                            radius: 52,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  for (var i = 0; i < cats.length && i < 8; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _colorAt(i),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.categoryLabel(cats[i].key),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatMoney(
                              cats[i].value.abs(),
                              currency: currency,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _colorAt(int i) {
    // Neighbouring slices must never share a hue.
    const palette = [
      AppColors.primary,
      AppColors.accent,
      Color(0xFFE0A94A),
      Color(0xFF5C6BC0),
      Color(0xFF3A9BDC),
      Color(0xFF9C5BB5),
      Color(0xFF5CC7A5),
      Color(0xFF8D6E63),
    ];
    return palette[i % palette.length];
  }
}
