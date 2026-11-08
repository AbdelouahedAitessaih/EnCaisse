import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/engagement_copy.dart';
import '../../widgets/app_components.dart';
import '../../core/utils/user_error.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/image_picker_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/authorized_image.dart';
import '../../widgets/animated_balance.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/compact_dialog.dart';
import '../../widgets/encaisse_refresh.dart';
import '../../widgets/feature_tour.dart';
import '../../widgets/home_banner_ad.dart';
import '../../widgets/movement_tile.dart';
import '../../providers/settings_provider.dart';

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
  final _searchController = TextEditingController();
  String _search = '';
  bool _tourScheduled = false;
  bool _deleting = false;
  bool _confirmingDelete = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid != null) {
        ref
            .read(notificationServiceProvider)
            .recordGroupViewed(uid: uid, groupId: widget.groupId);
      }
    });
  }

  String get groupId => widget.groupId;

  void _copyInviteCode(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.inviteCodeCopied(code))));
  }

  void _shareInvite(BuildContext context, Group group) {
    final l10n = AppLocalizations.of(context);
    SharePlus.instance.share(
      ShareParams(
        text: l10n.shareInviteLinkText(
          group.name,
          AppConstants.inviteLink(group.inviteCode),
          group.inviteCode,
        ),
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
                    color: Theme.of(context).colorScheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
    final tones = context.semantic;
    final action = await showModalBottomSheet<_GroupMenuAction>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(
                  group.isPersonal ? l10n.renameCaisse : l10n.renameGroup,
                ),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.rename),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(
                  group.isPersonal
                      ? l10n.changeCaissePhoto
                      : l10n.changeGroupPhoto,
                ),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.photo),
              ),
              if (!group.isPersonal)
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(l10n.manageMembers),
                  onTap: () => Navigator.pop(ctx, _GroupMenuAction.members),
                ),
              ListTile(
                leading: const Icon(Icons.table_view_outlined),
                title: Text(l10n.exportCsv),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.exportCsv),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(l10n.exportPdf),
                onTap: () => Navigator.pop(ctx, _GroupMenuAction.exportPdf),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: _deleting ? scheme.outline : tones.negative,
                ),
                title: Text(
                  _deleting
                      ? (group.isPersonal
                            ? l10n.caisseDeleting
                            : l10n.groupDeleting)
                      : (group.isPersonal
                            ? l10n.deleteCaisse
                            : l10n.deleteGroup),
                  style: TextStyle(
                    color: _deleting
                        ? scheme.onSurfaceVariant
                        : tones.negativeInk,
                  ),
                ),
                enabled: !_deleting,
                onTap: _deleting
                    ? null
                    : () => Navigator.pop(ctx, _GroupMenuAction.delete),
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
      case _GroupMenuAction.exportCsv:
        await _export(context, ref, group, members, pdf: false);
      case _GroupMenuAction.exportPdf:
        await _export(context, ref, group, members, pdf: true);
      case _GroupMenuAction.delete:
        await _confirmDeleteGroup(context, ref, group);
    }
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    Group group,
    List<GroupMember> members, {
    required bool pdf,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final balance = ref.read(balanceProvider(group.id));
    try {
      // A still-loading stream reports an empty list, which produces a
      // header-only file that would then be announced as a successful share.
      // Await the first snapshot, and let a failed read surface as an error,
      // instead of exporting a file the streams could not back.
      final movements = await ref.read(movementsProvider(group.id).future);
      final settlements = await ref.read(settlementsProvider(group.id).future);
      final export = ref.read(exportServiceProvider);
      if (pdf) {
        await export.sharePdf(
          group: group,
          movements: movements,
          members: members,
          balance: balance,
          settlements: settlements,
        );
      } else {
        await export.shareCsv(
          group: group,
          movements: movements,
          members: members,
          settlements: settlements,
        );
      }
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.exportShared)));
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
        );
      }
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
        builder: (ctx) => _RenameGroupPage(
          initialName: group.name,
          isPersonal: group.isPersonal,
        ),
      ),
    );
    if (name == null || !context.mounted) return;
    if (name.length < 2 || name == group.name) return;

    try {
      await ref
          .read(groupServiceProvider)
          .updateGroupName(groupId: group.id, name: name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              group.isPersonal ? l10n.caisseRenamed : l10n.groupRenamed,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
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
                          backgroundColor: context.semantic.positiveSurface,
                          backgroundImage:
                              member.photoUrl != null &&
                                  !member.photoUrl!.startsWith('storage://') &&
                                  !member.photoUrl!.contains(
                                    'firebasestorage.googleapis.com',
                                  )
                              ? NetworkImage(member.photoUrl!)
                              : null,
                          child: member.photoUrl == null
                              ? Text(
                                  member.displayName.isNotEmpty
                                      ? member.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: context.semantic.positiveInk,
                                  ),
                                )
                              : member.photoUrl!.startsWith('storage://') ||
                                    member.photoUrl!.contains(
                                      'firebasestorage.googleapis.com',
                                    )
                              ? ClipOval(
                                  child: AuthorizedImage(
                                    url: member.photoUrl!,
                                    width: 40,
                                    height: 40,
                                  ),
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
                                            style: TextStyle(
                                              color:
                                                  context.semantic.negativeInk,
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.memberRemoved),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.errorWithDetails(
                                              userFacingError(e),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  l10n.removeMember,
                                  style: TextStyle(
                                    color: context.semantic.negativeInk,
                                  ),
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
    final file = await pickGalleryImage(imageQuality: 80, maxWidth: 1280);
    if (file == null || !context.mounted) return;

    try {
      final url = await ref
          .read(storageServiceProvider)
          .uploadGroupImage(groupId: group.id, localPath: file.path);
      await ref
          .read(groupServiceProvider)
          .updateGroupPhoto(groupId: group.id, photoUrl: url);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              group.isPersonal
                  ? l10n.caissePhotoUpdated
                  : l10n.groupPhotoUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
        );
      }
    }
  }

  Future<void> _onGroupPhotoTap(
    BuildContext context,
    WidgetRef ref,
    Group group, {
    required bool isCreator,
  }) async {
    if (group.photoUrl != null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InteractiveViewer(
                child: AuthorizedImage(
                  url: group.photoUrl!,
                  fit: BoxFit.contain,
                ),
              ),
              if (isCreator)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _changeGroupPhoto(context, ref, group);
                  },
                  child: Text(
                    group.isPersonal
                        ? AppLocalizations.of(context).changeCaissePhoto
                        : AppLocalizations.of(context).changeGroupPhoto,
                  ),
                ),
            ],
          ),
        ),
      );
      return;
    }
    if (isCreator) {
      await _changeGroupPhoto(context, ref, group);
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
              style: TextStyle(color: context.semantic.negativeInk),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref
          .read(groupServiceProvider)
          .leaveGroup(groupId: group.id, uid: user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.leftGroup)));
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails(userFacingError(e)))),
        );
      }
    }
  }

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    // A rapid second tap must not stack a second confirmation dialog or fire a
    // second delete request while the first is still in flight.
    if (_deleting || _confirmingDelete) return;
    final l10n = AppLocalizations.of(context);
    // The delete itself is authorised server-side from the caller's ID token,
    // so this only bails out when there is no signed-in user to send it with.
    if (ref.read(authStateProvider).value == null) return;

    setState(() => _confirmingDelete = true);
    final bool? ok;
    try {
      ok = await showCompactDialog<bool>(
        context: context,
        builder: (ctx) => CompactAlertDialog(
          title: Text(
            group.isPersonal
                ? l10n.deleteCaisseConfirm
                : l10n.deleteGroupConfirm,
          ),
          content: Text(
            group.isPersonal ? l10n.deleteCaisseHint : l10n.deleteGroupHint,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                group.isPersonal ? l10n.deleteCaisse : l10n.deleteGroup,
                style: TextStyle(color: context.semantic.negativeInk),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _confirmingDelete = false);
    }
    if (ok != true || !mounted || !context.mounted) return;

    // Leave for home straight away; the group is hidden there while the
    // server deletes it. This screen is gone by the time the call returns, so
    // everything the outcome needs is captured from the app-wide scope now.
    _deleting = true;
    final container = ProviderScope.containerOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final pending = container.read(pendingGroupDeletionsProvider.notifier);
    final deletedMessage = group.isPersonal
        ? l10n.caisseDeleted
        : l10n.groupDeleted;
    pending.add(group.id);
    context.go('/home');
    messenger.showSnackBar(SnackBar(content: Text(deletedMessage)));

    try {
      await container.read(groupServiceProvider).deleteGroup(groupId: group.id);
      container.invalidate(userGroupsProvider);
    } catch (e) {
      // The backend can commit the Firestore delete and still fail to return a
      // response (timeout, dropped connection). Only bring the group back when
      // it still exists.
      final stillExists = await container
          .read(groupServiceProvider)
          .groupExists(group.id)
          .catchError((_) => true);
      if (!stillExists) {
        container.invalidate(userGroupsProvider);
      } else {
        pending.remove(group.id);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails(userFacingError(e))),
            duration: const Duration(seconds: 6),
          ),
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
      list = list.where(
        (m) =>
            m.createdBy == _userFilter ||
            (m.split?.containsKey(_userFilter) ?? false),
      );
    }
    final query = _search.trim().toLowerCase();
    if (query.isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      list = list.where(
        (m) =>
            m.title.toLowerCase().contains(query) ||
            m.category.toLowerCase().contains(query) ||
            l10n.categoryLabel(m.category).toLowerCase().contains(query) ||
            m.createdByName.toLowerCase().contains(query) ||
            m.amount.toStringAsFixed(2).contains(query),
      );
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

  Future<void> _showFilterSheet({
    required List<String> categories,
    required List<({String uid, String name})> users,
    required bool showUsers,
  }) async {
    final result =
        await showModalBottomSheet<
          ({String? category, String? user, DateTimeRange? date})
        >(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => _MovementFilterSheet(
            categories: categories,
            users: users,
            showUsers: showUsers,
            category: _categoryFilter,
            user: _userFilter,
            date: _dateFilter,
          ),
        );
    if (result != null && mounted) {
      setState(() {
        _categoryFilter = result.category;
        _userFilter = result.user;
        _dateFilter = result.date;
      });
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
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      error: (e, _) {
        final isPermissionDenied =
            e is FirebaseException && e.code == 'permission-denied';
        if (isPermissionDenied) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/home');
            }
          });
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(
              AppLocalizations.of(context).errorWithDetails(userFacingError(e)),
            ),
          ),
        );
      },
      data: (group) {
        if (group == null) {
          // The backend commits the Firestore delete before the callable
          // returns, so this stream emits null while our own request is still
          // in flight. Rendering "group not found" here is what flashed a dead
          // group at the user for a frame before navigating home; show the
          // pending deletion instead.
          if (_deleting) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context).groupDeleting),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context).groupNotFound),
            ),
          );
        }

        final allActive = (movementsAsync.value ?? [])
            .where((m) => !m.deleted)
            .toList();
        // Keep soft-deleted only while undo is still possible.
        final listSource = (movementsAsync.value ?? [])
            .where((m) => !m.deleted || m.canUndo)
            .toList();
        final visible = _applyFilters(listSource);
        final categories = {
          ...allActive.map((m) => m.category),
          if (_categoryFilter != null) ...[_categoryFilter!],
        }.toList()..sort();
        final userOptions = <({String uid, String name})>[];
        final seenUids = <String>{};
        for (final m in members) {
          if (seenUids.add(m.uid)) {
            userOptions.add((uid: m.uid, name: m.displayName));
          }
        }
        for (final mov in allActive) {
          if (seenUids.add(mov.createdBy)) {
            userOptions.add((uid: mov.createdBy, name: mov.createdByName));
          }
        }
        userOptions.sort((a, b) => a.name.compareTo(b.name));
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        final hasMovementFilters =
            !movementsAsync.isLoading && allActive.isNotEmpty;
        final availableActionWidth = MediaQuery.sizeOf(context).width - 32;
        final largeText = MediaQuery.textScalerOf(context).scale(16) >= 20;
        final actionWidth = largeText
            ? availableActionWidth
            : (hasMovementFilters
                  ? (availableActionWidth - 12) / 2
                  : availableActionWidth);
        final isCreator = user != null && group.createdBy == user.uid;
        final tones = context.semantic;
        final copy = EngagementCopy.of(context);
        // The caller's own position, kept visually separate from the group
        // balance so "what the caisse holds" is never confused with "what I am
        // owed or owe".
        final settle = ref.watch(settleProvider(groupId));
        // settleProvider folds a failed settlements read into an empty list, so
        // a backend failure would otherwise render a confident "You are settled
        // up". Watch the stream itself and never claim a clear position without
        // the data behind it.
        final settlementsAsync = ref.watch(settlementsProvider(groupId));
        final settleError = settlementsAsync.hasError
            ? userFacingError(settlementsAsync.error!)
            : null;
        final myNet = user == null || group.isPersonal
            ? null
            : settle.memberNets
                  .where((m) => m.uid == user.uid)
                  .map((m) => m.delta)
                  .firstOrNull;

        if (!_tourScheduled) {
          _tourScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            FeatureTour.showGroupTourIfNeeded(
              context,
              ref.read(sharedPreferencesProvider),
              isPersonal: group.isPersonal,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                // Mirror in RTL so "back" still points the way the reader reads.
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward
                    : Icons.arrow_back,
              ),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
              if (!group.isPersonal)
                IconButton(
                  tooltip: l10n.inviteFriends,
                  onPressed: () => _showInviteSheet(context, group),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
              PopupMenuButton<_GroupAction>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                icon: const Icon(Icons.more_vert),
                onSelected: (action) async {
                  switch (action) {
                    case _GroupAction.recurring:
                      context.push('/groups/$groupId/recurring');
                    case _GroupAction.mute:
                      if (user == null) return;
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
                    case _GroupAction.manage:
                      _showManageMenu(context, ref, group, members);
                    case _GroupAction.leave:
                      _confirmLeaveGroup(context, ref, group);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _GroupAction.recurring,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_repeat_outlined),
                      title: Text(l10n.recurringTitle),
                    ),
                  ),
                  if (!group.isPersonal && user != null)
                    PopupMenuItem(
                      value: _GroupAction.mute,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          myMember?.notificationsMuted == true
                              ? Icons.notifications_outlined
                              : Icons.notifications_off_outlined,
                        ),
                        title: Text(
                          myMember?.notificationsMuted == true
                              ? l10n.unmuteNotifications
                              : l10n.muteNotifications,
                        ),
                      ),
                    ),
                  if (isCreator)
                    PopupMenuItem(
                      value: _GroupAction.manage,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.tune),
                        title: Text(
                          group.isPersonal
                              ? l10n.manageCaisse
                              : l10n.manageGroup,
                        ),
                      ),
                    )
                  else if (user != null)
                    PopupMenuItem(
                      value: _GroupAction.leave,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          l10n.leaveGroup,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                ],
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
                        _GroupPhotoBanner(
                          photoUrl: group.photoUrl,
                          canEdit: isCreator,
                          onTap: () => _onGroupPhotoTap(
                            context,
                            ref,
                            group,
                            isCreator: isCreator,
                          ),
                          changeHint: l10n.tapPhotoToChange,
                          viewHint: l10n.tapPhotoToView,
                          addHint: l10n.addPhoto,
                        ),
                        if (group.isPersonal) ...[
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Chip(
                              avatar: const Icon(Icons.person, size: 16),
                              label: Text(l10n.personalBadge),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        AppSurface(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.balance,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // balanceProvider collapses a loading and a failed
                              // read into 0.00, which is indistinguishable from a
                              // genuinely empty caisse. Never render a number the
                              // app does not actually have.
                              if (movementsAsync.isLoading)
                                const SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              else if (movementsAsync.hasError)
                                Text(
                                  userFacingError(movementsAsync.error!),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: scheme.error),
                                )
                              else
                                AnimatedBalance(
                                  value: balance.total,
                                  currency: group.currency,
                                ),
                              if (settleError != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.smd,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.errorContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.field,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cloud_off_outlined,
                                        size: 18,
                                        color: scheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          settleError,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: scheme.onErrorContainer,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => ref.invalidate(
                                          settlementsProvider(groupId),
                                        ),
                                        child: Text(l10n.retry),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (myNet != null &&
                                  myNet.abs() >= 0.01) ...[
                                const SizedBox(height: AppSpacing.sm),
                                _PositionRow(
                                  label: myNet > 0
                                      ? copy.youAreOwed
                                      : copy.youOwe,
                                  amount: myNet.abs(),
                                  currency: group.currency,
                                  positive: myNet > 0,
                                  negative: myNet < 0,
                                ),
                              ] else if (myNet != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                _PositionRow(
                                  label: copy.youAreSettled,
                                  amount: 0,
                                  currency: group.currency,
                                  positive: false,
                                  negative: false,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppStat(
                                      label: l10n.inLabel,
                                      value: formatMoney(
                                        balance.deposits,
                                        currency: group.currency,
                                      ),
                                      valueColor: tones.positiveInk,
                                    ),
                                  ),
                                  Container(
                                    width: AppSizes.hairline,
                                    height: 28,
                                    color: scheme.outline,
                                  ),
                                  Expanded(
                                    child: AppStat(
                                      label: l10n.outLabel,
                                      value: formatMoney(
                                        balance.expenses,
                                        currency: group.currency,
                                      ),
                                      valueColor: tones.negativeInk,
                                    ),
                                  ),
                                  if (!group.isPersonal) ...[
                                    const SizedBox(width: AppSpacing.smd),
                                    Container(
                                      width: AppSizes.hairline,
                                      height: 28,
                                      color: scheme.outline,
                                    ),
                                    const SizedBox(width: AppSpacing.smd),
                                    AppStat(
                                      label: l10n.members,
                                      value: '${members.length}',
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              SizedBox(
                                width: actionWidth,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/groups/$groupId/insights'),
                                  icon: const Icon(Icons.insights_outlined),
                                  label: Text(l10n.insightsTitle),
                                ),
                              ),
                              if (hasMovementFilters)
                                SizedBox(
                                  width: actionWidth,
                                  child: _MovementFilters(
                                    l10n: l10n,
                                    users: userOptions,
                                    categoryFilter: _categoryFilter,
                                    userFilter: _userFilter,
                                    dateFilter: _dateFilter,
                                    onOpen: () => _showFilterSheet(
                                      categories: categories,
                                      users: userOptions,
                                      showUsers: !group.isPersonal,
                                    ),
                                    onClearCategory: () =>
                                        setState(() => _categoryFilter = null),
                                    onClearUser: () =>
                                        setState(() => _userFilter = null),
                                    onClearDate: () =>
                                        setState(() => _dateFilter = null),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!group.isPersonal && members.length < 2) ...[
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
                                              color: context.semantic.positive,
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
                                      icon: Icon(Icons.copy),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    IconButton(
                                      tooltip: l10n.share,
                                      onPressed: () =>
                                          _shareInvite(context, group),
                                      icon: Icon(Icons.ios_share),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Search stays directly above the list it filters.
                        if (hasMovementFilters) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) =>
                                setState(() => _search = value),
                            decoration: InputDecoration(
                              hintText: l10n.searchMovements,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _search.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: l10n.clearFilters,
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(() {
                                        _search = '';
                                        _searchController.clear();
                                      }),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: HomeBannerAd(),
                  ),
                ),
                if (movementsAsync.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else if (movementsAsync.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 40,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.errorWithDetails(
                              userFacingError(movementsAsync.error!),
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                ref.invalidate(movementsProvider(groupId)),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
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
                              _search = '';
                              _searchController.clear();
                            }),
                            child: Text(l10n.clearFilters),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                    }, childCount: visible.length),
                  ),
                // Room for the add button so it never hides the last amount.
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: l10n.addMovement,
            onPressed: () => _showAddMovementSheet(context, groupId, l10n),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddMovementSheet(
    BuildContext pageContext,
    String groupId,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: pageContext,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.addMovement,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  minTileHeight: 64,
                  leading: CircleAvatar(
                    backgroundColor: context.semantic.positiveSurface,
                    child: Icon(
                      Icons.arrow_downward,
                      color: context.semantic.positive,
                    ),
                  ),
                  title: Text(l10n.deposit),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    pageContext.push(
                      '/groups/$groupId/movements/new',
                      extra: MovementType.deposit,
                    );
                  },
                ),
                ListTile(
                  minTileHeight: 64,
                  leading: CircleAvatar(
                    backgroundColor: context.semantic.negativeSurface,
                    child: Icon(
                      Icons.arrow_upward,
                      color: context.semantic.negative,
                    ),
                  ),
                  title: Text(l10n.expense),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    pageContext.push(
                      '/groups/$groupId/movements/new',
                      extra: MovementType.expense,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _GroupMenuAction { rename, photo, members, exportCsv, exportPdf, delete }

class _RenameGroupPage extends StatefulWidget {
  const _RenameGroupPage({required this.initialName, this.isPersonal = false});

  final String initialName;
  final bool isPersonal;

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
        title: Text(widget.isPersonal ? l10n.renameCaisse : l10n.renameGroup),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
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

/// The caller's position in the caisse: owed, owing, or settled. Rendered as a
/// distinct strip rather than another figure in the stat row, because it
/// answers a different question than the group balance does.
class _PositionRow extends StatelessWidget {
  const _PositionRow({
    required this.label,
    required this.amount,
    required this.currency,
    required this.positive,
    required this.negative,
  });

  final String label;
  final double amount;
  final String currency;
  final bool positive;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final tones = context.semantic;
    final settled = !positive && !negative;
    final ink = positive
        ? tones.positiveInk
        : (negative
              ? tones.negativeInk
              : Theme.of(context).colorScheme.onSurfaceVariant);
    final surface = positive
        ? tones.positiveSurface
        : (negative ? tones.negativeSurface : tones.neutralSurface);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: Row(
        children: [
          Icon(
            positive
                ? Icons.call_received
                : (negative ? Icons.call_made : Icons.check_circle_outline),
            size: 18,
            color: settled ? tones.positiveInk : ink,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ink),
            ),
          ),
          if (amount > 0)
            AppAmount(
              amount: amount,
              currency: currency,
              color: ink,
              showSign: false,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ink,
                fontFeatures: kTabularFigures,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _MovementFilters extends StatelessWidget {
  const _MovementFilters({
    required this.l10n,
    required this.users,
    required this.categoryFilter,
    required this.userFilter,
    required this.dateFilter,
    required this.onOpen,
    required this.onClearCategory,
    required this.onClearUser,
    required this.onClearDate,
  });

  final AppLocalizations l10n;
  final List<({String uid, String name})> users;
  final String? categoryFilter;
  final String? userFilter;
  final DateTimeRange? dateFilter;
  final VoidCallback onOpen;
  final VoidCallback onClearCategory;
  final VoidCallback onClearUser;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final selectedUserName = users
        .where((u) => u.uid == userFilter)
        .map((u) => u.name)
        .firstOrNull;
    final activeCount = [
      categoryFilter,
      userFilter,
      dateFilter,
    ].where((value) => value != null).length;
    final chips = <Widget>[];
    if (categoryFilter != null) {
      chips.add(
        _ActiveFilterChip(label: categoryFilter!, onDeleted: onClearCategory),
      );
    }
    if (userFilter != null && selectedUserName != null) {
      chips.add(
        _ActiveFilterChip(label: selectedUserName, onDeleted: onClearUser),
      );
    }
    if (dateFilter != null) {
      chips.add(
        _ActiveFilterChip(
          label:
              '${formatMovementDate(dateFilter!.start, locale: locale)} – '
              '${formatMovementDate(dateFilter!.end, locale: locale)}',
          onDeleted: onClearDate,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.filters),
                if (activeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activeCount',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 2, children: chips),
        ],
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onDeleted});
  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => InputChip(
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    onDeleted: onDeleted,
    deleteIcon: const Icon(Icons.close_rounded, size: 16),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}

class _MovementFilterSheet extends StatefulWidget {
  const _MovementFilterSheet({
    required this.categories,
    required this.users,
    required this.showUsers,
    required this.category,
    required this.user,
    required this.date,
  });

  final List<String> categories;
  final List<({String uid, String name})> users;
  final bool showUsers;
  final String? category;
  final String? user;
  final DateTimeRange? date;

  @override
  State<_MovementFilterSheet> createState() => _MovementFilterSheetState();
}

class _MovementFilterSheetState extends State<_MovementFilterSheet> {
  late String? _category = widget.category;
  late String? _user = widget.user;
  late DateTimeRange? _date = widget.date;

  AppLocalizations get l10n => AppLocalizations.of(context);
  int get _count =>
      [_category, _user, _date].where((value) => value != null).length;

  DateTimeRange _thisMonthRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  DateTimeRange _last30DaysRange() {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    return DateTimeRange(
      start: end.subtract(const Duration(days: 29)),
      end: end,
    );
  }

  bool _sameCalendarDays(DateTimeRange? first, DateTimeRange second) =>
      first != null &&
      first.start.year == second.start.year &&
      first.start.month == second.start.month &&
      first.start.day == second.start.day &&
      first.end.year == second.end.year &&
      first.end.month == second.end.month &&
      first.end.day == second.end.day;

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _date,
      helpText: l10n.filterChooseDates,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _apply() => Navigator.of(
    context,
  ).pop((category: _category, user: _user, date: _date));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = _date == null
        ? l10n.filterDate
        : '${formatMovementDate(_date!.start, locale: locale)} – '
              '${formatMovementDate(_date!.end, locale: locale)}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .78,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.filters, style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                _FilterSection(
                  title: l10n.category,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChoice(
                        label: l10n.filterAll,
                        selected: _category == null,
                        onTap: () => setState(() => _category = null),
                      ),
                      ...widget.categories.map(
                        (category) => _FilterChoice(
                          label: category,
                          selected: _category == category,
                          onTap: () => setState(() => _category = category),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showUsers) ...[
                  const SizedBox(height: 18),
                  _FilterSection(
                    title: l10n.filterUser,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChoice(
                          label: l10n.filterAll,
                          selected: _user == null,
                          onTap: () => setState(() => _user = null),
                        ),
                        ...widget.users.map(
                          (user) => _FilterChoice(
                            label: user.name,
                            selected: _user == user.uid,
                            onTap: () => setState(() => _user = user.uid),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _FilterSection(
                  title: l10n.filterDate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChoice(
                            label: l10n.filterAnyTime,
                            selected: _date == null,
                            onTap: () => setState(() => _date = null),
                          ),
                          _FilterChoice(
                            label: l10n.filterThisMonth,
                            selected: _sameCalendarDays(
                              _date,
                              _thisMonthRange(),
                            ),
                            onTap: () =>
                                setState(() => _date = _thisMonthRange()),
                          ),
                          _FilterChoice(
                            label: l10n.filterLast30Days,
                            selected: _sameCalendarDays(
                              _date,
                              _last30DaysRange(),
                            ),
                            onTap: () =>
                                setState(() => _date = _last30DaysRange()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _chooseDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _date == null ||
                                  _sameCalendarDays(_date, _thisMonthRange()) ||
                                  _sameCalendarDays(_date, _last30DaysRange())
                              ? l10n.filterChooseDates
                              : dateLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: _count == 0
                          ? null
                          : () => setState(() {
                              _category = null;
                              _user = null;
                              _date = null;
                            }),
                      child: Text(l10n.clearFilters),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _apply,
                      child: Text(l10n.applyFilters),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      child,
    ],
  );
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: ChoiceChip(
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _GroupPhotoBanner extends StatelessWidget {
  const _GroupPhotoBanner({
    required this.photoUrl,
    required this.canEdit,
    required this.onTap,
    required this.changeHint,
    required this.viewHint,
    required this.addHint,
  });

  final String? photoUrl;
  final bool canEdit;
  final VoidCallback onTap;
  final String changeHint;
  final String viewHint;
  final String addHint;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;
    if (!hasPhoto && !canEdit) {
      return const SizedBox.shrink();
    }
    if (!hasPhoto) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
            label: Text(addHint),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AuthorizedImage(
                    url: photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _) => Container(
                      color: AppColors.primaryLight,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      color: Colors.black54,
                      child: Text(
                        canEdit ? changeHint : viewHint,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _GroupAction { recurring, mute, manage, leave }
