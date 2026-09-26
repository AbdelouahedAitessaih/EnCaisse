import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/group_insights_section.dart';

class GroupInsightsScreen extends ConsumerWidget {
  const GroupInsightsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final group = ref.watch(groupProvider(groupId)).value;
    final balance = ref.watch(balanceProvider(groupId));
    final settle = ref.watch(settleProvider(groupId));
    final currency = group?.currency ?? 'MAD';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insightsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (group != null) ...[
            Text(
              group.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.balance}: ${formatMoney(balance.total, currency: currency)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          GroupInsightsSection(
            balance: balance,
            settle: settle,
            currency: currency,
            showSettle: group?.isPersonal != true,
          ),
        ],
      ),
    );
  }
}
