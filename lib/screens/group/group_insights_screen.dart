import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/settle.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/engagement_copy.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
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
    final settlements = ref.watch(settlementsProvider(groupId)).value ?? const [];
    final user = ref.watch(authStateProvider).value;
    final currency = group?.currency ?? 'MAD';
    final copy = EngagementCopy.of(context);

    Future<void> recordPayment(SettleTransfer transfer) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(copy.recordPayment),
          content: Text(copy.settlementExplanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(copy.recordPayment),
            ),
          ],
        ),
      );
      if (confirmed != true || user == null || !context.mounted) return;
      try {
        await ref.read(settlementServiceProvider).recordPayment(
              groupId: groupId,
              fromUid: user.uid,
              toUid: transfer.toUid,
              amount: transfer.amount,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(copy.paymentRecordedMessage)),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetails(userFacingError(error)))),
          );
        }
      }
    }

    Future<void> confirmPayment(Settlement payment) async {
      try {
        await ref.read(settlementServiceProvider).confirmReceived(
              groupId: groupId,
              settlementId: payment.id,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(copy.paymentConfirmedMessage)),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetails(userFacingError(error)))),
          );
        }
      }
    }

    Future<void> cancelPayment(Settlement payment) async {
      try {
        await ref.read(settlementServiceProvider).cancelPayment(
              groupId: groupId,
              settlementId: payment.id,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(copy.paymentCancelled)),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetails(userFacingError(error)))),
          );
        }
      }
    }

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
            currentUid: user?.uid,
            settlements: settlements,
            onRecordPayment: recordPayment,
            onConfirmSettlement: confirmPayment,
            onCancelSettlement: cancelPayment,
          ),
        ],
      ),
    );
  }
}
