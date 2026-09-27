import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/settle.dart';
import '../l10n/engagement_copy.dart';
import '../l10n/app_localizations.dart';
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
    this.onRecordPayment,
    this.onConfirmSettlement,
    this.onCancelSettlement,
  });

  final BalanceSummary balance;
  final SettleSummary settle;
  final String currency;
  final bool showSettle;
  final String? currentUid;
  final List<Settlement> settlements;
  final Future<void> Function(SettleTransfer transfer)? onRecordPayment;
  final Future<void> Function(Settlement settlement)? onConfirmSettlement;
  final Future<void> Function(Settlement settlement)? onCancelSettlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cats = balance.byCategory.entries
        .where((e) => e.value.abs() > 0.001)
        .toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

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
                const SizedBox(height: 4),
                Text(
                  _copy(context).settlementExplanation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (settle.isSettled &&
                    balance.deposits == 0 &&
                    balance.expenses == 0)
                  Text(
                    l10n.noMovementsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if (settle.isSettled)
                  Text(
                    l10n.settleSettled,
                    style: const TextStyle(color: AppColors.deposit),
                  )
                else
                  ...settle.transfers.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.swap_horiz, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${l10n.settleOwes(t.fromName, t.toName)} · '
                                  '${formatMoney(t.amount, currency: currency)}',
                                ),
                              ),
                            ],
                          ),
                          if (currentUid == t.fromUid && onRecordPayment != null)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton.icon(
                                onPressed: () => onRecordPayment!(t),
                                icon: const Icon(Icons.payments_outlined),
                                label: Text(_copy(context).recordPayment),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                if (settlements.isNotEmpty) ...[
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isConfirmed
                                ? Icons.check_circle
                                : isCancelled
                                    ? Icons.cancel_outlined
                                    : Icons.schedule,
                            size: 18,
                            color: isConfirmed
                                ? AppColors.deposit
                                : isCancelled
                                    ? scheme.outline
                                    : scheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_copy(context).paymentLine(payment.fromName, payment.toName)} · '
                                  '${formatMoney(payment.amount, currency: currency)}',
                                ),
                                Text(
                                  isConfirmed
                                      ? _copy(context).paymentConfirmed
                                      : isCancelled
                                          ? _copy(context).paymentCancelled
                                          : _copy(context).awaitingConfirmation,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (!isConfirmed &&
                                    !isCancelled &&
                                    currentUid == payment.toUid &&
                                    onConfirmSettlement != null)
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          onConfirmSettlement!(payment),
                                      icon: const Icon(Icons.done_all),
                                      label: Text(_copy(context).confirmReceived),
                                    ),
                                  ),
                                if (!isConfirmed &&
                                    !isCancelled &&
                                    (currentUid == payment.fromUid ||
                                        currentUid == payment.toUid) &&
                                    onCancelSettlement != null)
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton(
                                      onPressed: () =>
                                          onCancelSettlement!(payment),
                                      child: Text(_copy(context).cancelPayment),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
                                ? _copy(context).youAreSettled
                                : '${m.delta < 0 ? _copy(context).memberOwes : _copy(context).memberIsOwed} '
                                    '${formatMoney(m.delta.abs(), currency: currency)}',
                            style: TextStyle(
                              color: m.delta >= 0
                                  ? AppColors.deposit
                                  : AppColors.expense,
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
                              cats[i].key,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatMoney(
                              cats[i].value.abs(),
                              currency: currency,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
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
    const palette = [
      AppColors.primary,
      AppColors.deposit,
      AppColors.expense,
      AppColors.accent,
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFFFA726),
      Color(0xFF8D6E63),
    ];
    return palette[i % palette.length];
  }
}
