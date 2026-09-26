import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/settle.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';

class GroupInsightsSection extends StatelessWidget {
  const GroupInsightsSection({
    super.key,
    required this.balance,
    required this.settle,
    required this.currency,
    this.showSettle = true,
  });

  final BalanceSummary balance;
  final SettleSummary settle;
  final String currency;
  final bool showSettle;

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
                const SizedBox(height: 12),
                if (settle.isSettled)
                  Text(
                    l10n.settleSettled,
                    style: const TextStyle(color: AppColors.deposit),
                  )
                else
                  ...settle.transfers.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
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
                    );
                  }),
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
                            '${l10n.memberNet}: '
                            '${formatMoney(m.net, currency: currency)}',
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
