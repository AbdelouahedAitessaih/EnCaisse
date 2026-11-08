import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import '../l10n/engagement_copy.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class GroupBalancePreview extends ConsumerWidget {
  const GroupBalancePreview({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = group.currency;
    final largeText = MediaQuery.textScalerOf(context).scale(16) >= 20;

    final movements = ref.watch(movementsProvider(group.id)).value ?? const [];
    final latest = movements.where((movement) => !movement.deleted).firstOrNull;
    final uid = ref.watch(authStateProvider).value?.uid;
    final copy = EngagementCopy.of(context);
    final members = group.isPersonal || uid == null
        ? const []
        : ref.watch(settleProvider(group.id)).memberNets;
    final current = members.where((member) => member.uid == uid).firstOrNull;
    final label = latest == null
        ? AppLocalizations.of(context).noMovementsSubtitle
        : current == null
        ? null
        : current.delta.abs() < 0.01
        ? copy.youAreSettled
        : '${current.delta < 0 ? copy.youOwe : copy.youAreOwed} '
              '${formatMoney(current.delta.abs(), currency: currency)}';
    final tones = context.semantic;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: current == null || current.delta.abs() < 0.01
          ? Theme.of(context).colorScheme.primary
          : current.delta < 0
          ? tones.negativeInk
          : tones.positiveInk,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label, style: style),
        if (latest != null) ...[
          const SizedBox(height: 2),
          Text(
            '${copy.recent}: ${latest.title} · ${formatMovementDate(latest.createdAt, locale: Localizations.localeOf(context).toString())}',
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
