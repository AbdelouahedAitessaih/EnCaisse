import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/movement_service.dart';
import '../../widgets/compact_dialog.dart';
import '../../widgets/receipt_image.dart';

class MovementDetailScreen extends ConsumerWidget {
  const MovementDetailScreen({
    super.key,
    required this.groupId,
    required this.movementId,
  });

  final String groupId;
  final String movementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final movementsAsync = ref.watch(movementsProvider(groupId));
    final movements = movementsAsync.value ?? [];
    final movement = movements.where((m) => m.id == movementId).firstOrNull;
    final group = ref.watch(groupProvider(groupId)).value;
    final auditAsync = ref.watch(
      movementAuditProvider((groupId: groupId, movementId: movementId)),
    );
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(currentUserProfileProvider).value;
    final currency = group?.currency ?? 'MAD';
    final members =
        ref.watch(groupMembersProvider(groupId)).value ?? const <GroupMember>[];
    final scheme = Theme.of(context).colorScheme;

    if (movement == null) {
      // A cold open has no snapshot yet, so treating "not loaded" as "not found"
      // flashed a dead movement at the user every time the screen was opened.
      // Only a settled list that genuinely lacks the id is a missing movement.
      if (movementsAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (movementsAsync.hasError) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.errorWithDetails(
                      userFacingError(movementsAsync.error!),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(movementsProvider(groupId)),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.movementNotFound)),
      );
    }

    // Read from the theme: the static brand green only reaches 3.0:1 against the
    // dark scaffold, which made the largest figure on the screen hard to read.
    final tones = context.semantic;
    final color = movement.type == MovementType.deposit
        ? tones.positive
        : tones.negative;
    final isCreator = user != null && group?.createdBy == user.uid;
    final canManage = !movement.isStartingBalance || isCreator;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          movement.isStartingBalance ? l10n.startingBalance : l10n.movement,
        ),
        actions: [
          if (!movement.deleted && canManage)
            IconButton(
              tooltip: l10n.editMovement,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/groups/$groupId/movements/$movementId/edit'),
            ),
          if (!movement.deleted && canManage)
            IconButton(
              tooltip: l10n.delete,
              icon: Icon(Icons.delete_outline, color: tones.negative),
              onPressed: () => _confirmDelete(
                context,
                ref,
                movement,
                user?.uid,
                profile?.displayName ?? user?.displayName ?? l10n.member,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            movement.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (movement.isStartingBalance) ...[
            const SizedBox(height: 8),
            Text(
              isCreator ? l10n.onlyYouEditStarting : l10n.onlyCreatorEditAmount,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            signedAmount(
              movement.amount,
              movement.type.value,
              currency: currency,
            ),
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: color, fontSize: 36),
          ),
          if (movement.isForeignCurrency) ...[
            const SizedBox(height: 4),
            Text(
              l10n.paidInCurrency(
                formatMoney(
                  movement.originalAmount!,
                  currency: movement.originalCurrency!,
                ),
                movement.exchangeRate?.toString() ?? '—',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n.category,
            value: l10n.categoryLabel(movement.category),
          ),
          _InfoRow(
            label: l10n.type,
            value: movement.type == MovementType.deposit
                ? l10n.deposit
                : l10n.expense,
          ),
          _InfoRow(label: l10n.createdBy, value: movement.createdByName),
          _InfoRow(
            label: l10n.dateLabel,
            value: formatMovementDate(
              movement.createdAt,
              locale: Localizations.localeOf(context).toString(),
            ),
          ),
          _InfoRow(
            label: l10n.timeLabel,
            value: formatMovementTime(
              movement.createdAt,
              locale: Localizations.localeOf(context).toString(),
            ),
          ),
          if (movement.recurringId != null)
            _InfoRow(label: l10n.repeatLabel, value: l10n.recurringBadge),
          if (movement.hasSplit) ...[
            const SizedBox(height: 12),
            Text(
              movement.type == MovementType.expense
                  ? l10n.splitTitleExpense
                  : l10n.splitTitleDeposit,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (final share in movement.split!.entries)
              _InfoRow(
                label:
                    members
                        .where((m) => m.uid == share.key)
                        .map((m) => m.displayName)
                        .firstOrNull ??
                    l10n.formerMember,
                value: formatMoney(share.value, currency: currency),
              ),
          ],
          if (movement.hasReceipt) ...[
            const SizedBox(height: 20),
            Text(l10n.receipt, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ReceiptImage(url: movement.receiptUrl!),
          ],
          if (movement.deleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tones.negativeSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movement.canUndo
                    ? l10n.softDeletedCanUndo
                    : l10n.softDeletedExpired,
                style: TextStyle(color: tones.negativeInk),
              ),
            ),
            if (movement.canUndo && user != null && canManage) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(movementServiceProvider)
                        .undoSoftDelete(
                          groupId: groupId,
                          existing: movement,
                          uid: user.uid,
                          displayName:
                              profile?.displayName ??
                              user.displayName ??
                              l10n.member,
                        );
                    HapticFeedback.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.movementRestored)),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    final message = e is InsufficientBalanceException
                        ? l10n.insufficientBalance
                        : userFacingError(e);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                child: Text(l10n.undoDelete),
              ),
            ],
          ],
          const SizedBox(height: 32),
          Text(l10n.auditTrail, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.auditTrailSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          auditAsync.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(color: scheme.primary),
              ),
            ),
            error: (e, _) => Text(l10n.couldNotLoadAudit(userFacingError(e))),
            data: (entries) {
              if (entries.isEmpty) {
                return Text(l10n.noAuditYet);
              }
              return Column(
                children: entries.map((e) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: scheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ActionBadge(action: e.action),
                            const Spacer(),
                            Text(
                              formatMovementDateTime(
                                e.timestamp,
                                locale: Localizations.localeOf(
                                  context,
                                ).toString(),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e.performedByName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (e.after != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _summarize(e.after!, l10n, currency),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Movement movement,
    String? uid,
    String displayName,
  ) async {
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showCompactDialog<bool>(
      context: context,
      builder: (ctx) => CompactAlertDialog(
        title: Text(
          movement.isStartingBalance
              ? l10n.deleteStartingBalance
              : l10n.deleteMovement,
        ),
        content: Text(l10n.softDeleteHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: context.semantic.negativeInk),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    // This screen is popped before Undo can be tapped, so its ref and context
    // are gone by then; hold on to what the action needs.
    final service = ref.read(movementServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleted = await service.softDeleteMovement(
        groupId: groupId,
        existing: movement,
        uid: uid,
        displayName: displayName,
      );

      HapticFeedback.heavyImpact();
      if (!context.mounted) return;
      context.pop();

      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(l10n.movementDeletedUndo),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async {
              try {
                await service.undoSoftDelete(
                  groupId: groupId,
                  existing: deleted,
                  uid: uid,
                  displayName: displayName,
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      e is InsufficientBalanceException
                          ? l10n.insufficientBalance
                          : l10n.errorWithDetails(userFacingError(e)),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final message = e is InsufficientBalanceException
          ? l10n.insufficientBalance
          : userFacingError(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _summarize(
    Map<String, dynamic> data,
    AppLocalizations l10n,
    String currency,
  ) {
    final rawType = data['type'] as String? ?? '';
    final type = switch (rawType) {
      'deposit' => l10n.deposit,
      'expense' => l10n.expense,
      _ => rawType,
    };
    final raw = data['amount'];
    final amount = raw is num
        ? formatMoney(raw.toDouble(), currency: currency)
        : (raw ?? '');
    final title = data['title'] ?? '';
    final deleted = data['deleted'] == true;
    return '$title · $type · $amount${deleted ? ' · ${l10n.deletedMarker}' : ''}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.action});

  final AuditAction action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tones = context.semantic;
    final (label, bg, fg) = switch (action) {
      AuditAction.create => (
        l10n.actionCreate,
        tones.positiveSurface,
        tones.positiveInk,
      ),
      AuditAction.update => (
        l10n.actionUpdate,
        scheme.surface,
        scheme.onSurface.withValues(alpha: 0.7),
      ),
      AuditAction.delete => (
        l10n.actionDelete,
        tones.negativeSurface,
        tones.negativeInk,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
