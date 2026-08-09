import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/animated_balance.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/compact_dialog.dart';
import '../../widgets/encaisse_refresh.dart';
import '../../widgets/movement_tile.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  String? _categoryFilter;
  String? _userFilter;
  DateTimeRange? _dateFilter;
  bool _closingGroup = false;

  String get groupId => widget.groupId;

  void _copyInviteCode(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.inviteCodeCopied(code))),
    );
  }

  void _shareInvite(BuildContext context, Group group) {
    final l10n = AppLocalizations.of(context);
    SharePlus.instance.share(
      ShareParams(
        text: l10n.shareInviteText(group.name, group.inviteCode),
        subject: l10n.joinOnEncaisse(group.name),
      ),
    );
  }

  void _showInviteSheet(BuildContext context, Group group) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.inviteFriends,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.shareThisCode,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  group.inviteCode,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 6,
                        fontSize: 36,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _copyInviteCode(context, group.inviteCode);
                        },
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.copyCode),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _shareInvite(context, group);
                        },
                        icon: const Icon(Icons.ios_share),
                        label: Text(l10n.share),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showManageMenu(
    BuildContext context,
    WidgetRef ref,
    Group group,
    List<GroupMember> members,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_GroupMenuAction>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.renameGroup),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.rename),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(l10n.changeGroupPhoto),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.photo),
              ),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(l10n.manageMembers),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.members),
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.accent),
                title: Text(
                  l10n.deleteGroup,
                  style: const TextStyle(color: AppColors.accent),
                ),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.delete),
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || action == null) return;

    switch (action) {
      case _GroupMenuAction.rename:
        await _showRenameDialog(context, ref, group);
      case _GroupMenuAction.photo:
        await _changeGroupPhoto(context, ref, group);
      case _GroupMenuAction.members:
        _showMembersSheet(context, ref, group, members);
      case _GroupMenuAction.delete:
        await _confirmDeleteGroup(context, ref, group);
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Full-screen dialog avoids bottom-sheet layout bugs on some devices
    // (barrier shown, content never laid out).
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _RenameGroupPage(initialName: group.name),
      ),
    );
    if (name == null || !context.mounted) return;
    if (name.length < 2 || name == group.name) return;

    try {
      await ref.read(groupServiceProvider).updateGroupName(
            groupId: group.id,
            name: name,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.groupRenamed)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  void _showMembersSheet(
    BuildContext context,
    WidgetRef ref,
    Group group,
    List<GroupMember> members,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.manageMembers,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isCreator = member.uid == group.createdBy;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: member.photoUrl != null
                              ? NetworkImage(member.photoUrl!)
                              : null,
                          child: member.photoUrl == null
                              ? Text(
                                  member.displayName.isNotEmpty
                                      ? member.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: AppColors.primary),
                                )
                              : null,
                        ),
                        title: Text(member.displayName),
                        subtitle: isCreator ? Text(l10n.creator) : null,
                        trailing: isCreator
                            ? null
                            : TextButton(
                                onPressed: () async {
                                  final confirm = await showCompactDialog<bool>(
                                    context: context,
                                    builder: (dCtx) => CompactAlertDialog(
                                      title: Text(l10n.removeMember),
                                      content: Text(
                                        l10n.removeMemberConfirm(
                                          member.displayName,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dCtx, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dCtx, true),
                                          child: Text(
                                            l10n.removeMember,
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true || !context.mounted) {
                                    return;
                                  }
                                  try {
                                    await ref
                                        .read(groupServiceProvider)
                                        .removeMember(
                                          groupId: group.id,
                                          memberUid: member.uid,
                                          creatorUid: group.createdBy,
                                        );
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.memberRemoved),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.errorWithDetails('$e'),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  l10n.removeMember,
                                  style: const TextStyle(color: AppColors.accent),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeGroupPhoto(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (file == null || !context.mounted) return;

    try {
      final url = await ref.read(storageServiceProvider).uploadGroupImage(
            groupId: group.id,
            localPath: file.path,
          );
      await ref.read(groupServiceProvider).updateGroupPhoto(
            groupId: group.id,
            photoUrl: url,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.groupPhotoUpdated)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  Future<void> _confirmLeaveGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final ok = await showCompactDialog<bool>(
      context: context,
      builder: (ctx) => CompactAlertDialog(
        title: Text(l10n.leaveGroup),
        content: Text(l10n.leaveGroupHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.leaveGroup,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref.read(groupServiceProvider).leaveGroup(
            groupId: group.id,
            uid: user.uid,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.leftGroup)),
        );
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final ok = await showCompactDialog<bool>(
      context: context,
      builder: (ctx) => CompactAlertDialog(
        title: Text(l10n.deleteGroupConfirm),
        content: Text(l10n.deleteGroupHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.deleteGroup,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    setState(() => _closingGroup = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(groupServiceProvider).deleteGroup(
            groupId: group.id,
            creatorUid: user.uid,
          );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.groupDeleted)),
      );
      context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _closingGroup = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  List<Movement> _applyFilters(List<Movement> source) {
    Iterable<Movement> list = source.where((m) => !m.deleted);
    if (_categoryFilter != null) {
      list = list.where((m) => m.category == _categoryFilter);
    }
    if (_userFilter != null) {
      list = list.where((m) => m.createdBy == _userFilter);
    }
    if (_dateFilter != null) {
      final start = DateTime(
        _dateFilter!.start.year,
        _dateFilter!.start.month,
        _dateFilter!.start.day,
      );
      final end = DateTime(
        _dateFilter!.end.year,
        _dateFilter!.end.month,
        _dateFilter!.end.day,
        23,
        59,
        59,
        999,
      );
      list = list.where(
        (m) => !m.createdAt.isBefore(start) && !m.createdAt.isAfter(end),
      );
    }
    return list.toList();
  }

  bool get _hasFilters =>
      _categoryFilter != null || _userFilter != null || _dateFilter != null;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateFilter,
      helpText: AppLocalizations.of(context).filterDate,
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupProvider(groupId));
    final movementsAsync = ref.watch(movementsProvider(groupId));
    final balance = ref.watch(balanceProvider(groupId));
    final members = ref.watch(groupMembersProvider(groupId)).value ?? [];
    final user = ref.watch(authStateProvider).value;
    final myMember = members.where((m) => m.uid == user?.uid).firstOrNull;

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(AppLocalizations.of(context).errorWithDetails('$e')),
        ),
      ),
      data: (group) {
        if (group == null) {
          if (_closingGroup) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(AppLocalizations.of(context).groupNotFound)),
          );
        }

        final allActive = (movementsAsync.value ?? [])
            .where((m) => !m.deleted)
            .toList();
        final visible = _applyFilters(movementsAsync.value ?? []);
        final categories = {
          ...allActive.map((m) => m.category),
          if (_categoryFilter != null) _categoryFilter!,
        }.toList()
          ..sort();
        final userOptions = <({String uid, String name})>[];
        final seenUids = <String>{};
        for (final m in members) {
          if (seenUids.add(m.uid)) {
            userOptions.add((uid: m.uid, name: m.displayName));
          }
        }
        for (final mov in allActive) {
          if (seenUids.add(mov.createdBy)) {
            userOptions.add(
              (uid: mov.createdBy, name: mov.createdByName),
            );
          }
        }
        userOptions.sort((a, b) => a.name.compareTo(b.name));
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isCreator = user != null && group.createdBy == user.uid;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Text(group.name),
            actions: [
              IconButton(
                tooltip: myMember?.notificationsMuted == true
                    ? l10n.unmuteNotifications
                    : l10n.muteNotifications,
                onPressed: user == null
                    ? null
                    : () async {
                        final muted = !(myMember?.notificationsMuted ?? false);
                        await ref
                            .read(groupServiceProvider)
                            .setNotificationsMuted(
                              groupId: groupId,
                              uid: user.uid,
                              muted: muted,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                muted
                                    ? l10n.notificationsMuted
                                    : l10n.notificationsEnabled,
                              ),
                            ),
                          );
                        }
                      },
                icon: Icon(
                  myMember?.notificationsMuted == true
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_outlined,
                ),
              ),
              IconButton(
                tooltip: l10n.inviteFriends,
                onPressed: () => _showInviteSheet(context, group),
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
              if (isCreator)
                IconButton(
                  tooltip: l10n.manageGroup,
                  onPressed: () =>
                      _showManageMenu(context, ref, group, members),
                  icon: const Icon(Icons.more_vert),
                )
              else if (user != null)
                IconButton(
                  tooltip: l10n.leaveGroup,
                  onPressed: () => _confirmLeaveGroup(context, ref, group),
                  icon: const Icon(Icons.logout),
                ),
            ],
          ),
          body: EncaisseRefreshIndicator(
            onRefresh: () async {
              ref.invalidate(movementsProvider(groupId));
              ref.invalidate(groupProvider(groupId));
              await ref.read(movementsProvider(groupId).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        if (group.photoUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 7,
                              child: Image.network(
                                group.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A31)
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.balance,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              AnimatedBalance(
                                value: balance.total,
                                currency: group.currency,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      label: l10n.inLabel,
                                      value: formatMoney(
                                        balance.deposits,
                                        currency: group.currency,
                                      ),
                                      color: AppColors.deposit,
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: l10n.outLabel,
                                      value: formatMoney(
                                        balance.expenses,
                                        currency: group.currency,
                                      ),
                                      color: AppColors.expense,
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: l10n.members,
                                      value: '${members.length}',
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                l10n.inviteCode,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.shareCodeSoFriends,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      group.inviteCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            letterSpacing: 4,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l10n.copyCode,
                                    onPressed: () => _copyInviteCode(
                                      context,
                                      group.inviteCode,
                                    ),
                                    icon: const Icon(Icons.copy),
                                    color: AppColors.primary,
                                  ),
                                  IconButton(
                                    tooltip: l10n.share,
                                    onPressed: () =>
                                        _shareInvite(context, group),
                                    icon: const Icon(Icons.ios_share),
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!movementsAsync.isLoading && allActive.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _MovementFilters(
                        l10n: l10n,
                        categories: categories,
                        users: userOptions,
                        categoryFilter: _categoryFilter,
                        userFilter: _userFilter,
                        dateFilter: _dateFilter,
                        hasFilters: _hasFilters,
                        onCategory: (value) =>
                            setState(() => _categoryFilter = value),
                        onUser: (value) => setState(() => _userFilter = value),
                        onDateTap: _pickDateRange,
                        onClearDate: () => setState(() => _dateFilter = null),
                        onClearAll: () => setState(() {
                          _categoryFilter = null;
                          _userFilter = null;
                          _dateFilter = null;
                        }),
                      ),
                    ),
                  ),
                if (movementsAsync.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (allActive.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      title: l10n.noMovementsYet,
                      subtitle: l10n.noMovementsSubtitle,
                      asset: 'assets/lottie/empty_movements.json',
                    ),
                  )
                else if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noMatchingMovements,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => setState(() {
                              _categoryFilter = null;
                              _userFilter = null;
                              _dateFilter = null;
                            }),
                            child: Text(l10n.clearFilters),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final movement = visible[index];
                        return MovementTile(
                          key: ValueKey(
                            '${movement.id}_${movement.updatedAt.millisecondsSinceEpoch}',
                          ),
                          movement: movement,
                          currency: group.currency,
                          animateIn: index == 0,
                          onTap: () => context.push(
                            '/groups/$groupId/movements/${movement.id}',
                          ),
                        );
                      },
                      childCount: visible.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/groups/$groupId/movements/new'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

enum _GroupMenuAction { rename, photo, members, delete }

class _RenameGroupPage extends StatefulWidget {
  const _RenameGroupPage({required this.initialName});

  final String initialName;

  @override
  State<_RenameGroupPage> createState() => _RenameGroupPageState();
}

class _RenameGroupPageState extends State<_RenameGroupPage> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.renameGroup),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.renameGroupHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.groupName),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return l10n.enterName;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _MovementFilters extends StatelessWidget {
  const _MovementFilters({
    required this.l10n,
    required this.categories,
    required this.users,
    required this.categoryFilter,
    required this.userFilter,
    required this.dateFilter,
    required this.hasFilters,
    required this.onCategory,
    required this.onUser,
    required this.onDateTap,
    required this.onClearDate,
    required this.onClearAll,
  });

  static const _filterAll = '__all__';

  final AppLocalizations l10n;
  final List<String> categories;
  final List<({String uid, String name})> users;
  final String? categoryFilter;
  final String? userFilter;
  final DateTimeRange? dateFilter;
  final bool hasFilters;
  final ValueChanged<String?> onCategory;
  final ValueChanged<String?> onUser;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final selectedUserName = userFilter == null
        ? null
        : users
            .where((u) => u.uid == userFilter)
            .map((u) => u.name)
            .firstOrNull;
    final dateLabel = dateFilter == null
        ? l10n.filterDate
        : '${formatMovementDate(dateFilter!.start, locale: locale)}'
            ' – ${formatMovementDate(dateFilter!.end, locale: locale)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PopupMenuButton<String>(
                // PopupMenuItem value:null never fires onSelected — use sentinel.
                onSelected: (value) =>
                    onCategory(value == _filterAll ? null : value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _filterAll,
                    child: Text(l10n.filterAll),
                  ),
                  ...categories.map(
                    (c) => PopupMenuItem(value: c, child: Text(c)),
                  ),
                ],
                child: _FilterPill(
                  label: categoryFilter ?? l10n.category,
                  selected: categoryFilter != null,
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    onUser(value == _filterAll ? null : value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _filterAll,
                    child: Text(l10n.filterAll),
                  ),
                  ...users.map(
                    (u) => PopupMenuItem(
                      value: u.uid,
                      child: Text(u.name),
                    ),
                  ),
                ],
                child: _FilterPill(
                  label: selectedUserName ?? l10n.filterUser,
                  selected: userFilter != null,
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDateTap,
                onLongPress: dateFilter != null ? onClearDate : null,
                borderRadius: BorderRadius.circular(8),
                child: _FilterPill(
                  label: dateLabel,
                  selected: dateFilter != null,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onClearAll,
                  child: Text(l10n.clearFilters),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.icon,
  });

  final String label;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.primary : scheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? AppColors.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? AppColors.primary : scheme.onSurface,
                  ),
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.expand_more,
            size: 18,
            color: selected ? AppColors.primary : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
