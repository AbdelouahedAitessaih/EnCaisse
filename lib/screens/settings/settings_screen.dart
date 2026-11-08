import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/engagement_copy.dart';
import '../../providers/providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_lock_gate.dart';
import '../../widgets/feature_tour.dart';
import '../../widgets/authorized_image.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(currentUserProfileProvider).value;
    final user = ref.watch(authStateProvider).value;
    final displayName = (profile?.displayName.trim().isNotEmpty == true)
        ? profile!.displayName
        : (user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!
              : (user?.email?.split('@').first ?? l10n.member));
    final email = (profile?.email.trim().isNotEmpty == true)
        ? profile!.email
        : (user?.email ?? '');
    final photoUrl = profile?.photoUrl ?? user?.photoURL;
    final notificationCopy = EngagementCopy.of(context);
    // Each language is listed under its own name so someone stuck in a
    // language they cannot read can still find theirs.
    final languages = <(Locale?, String, String?)>[
      (null, l10n.languageSystem, null),
      (const Locale('en'), 'English', l10n.languageEnglish),
      (const Locale('fr'), 'Français', l10n.languageFrench),
      (const Locale('ar'), 'العربية', l10n.languageArabic),
      (const Locale('es'), 'Español', l10n.languageSpanish),
      (const Locale('pt'), 'Português', l10n.languagePortuguese),
      (const Locale('zh'), '中文', l10n.languageChinese),
      (const Locale('hi'), 'हिन्दी', l10n.languageHindi),
      (const Locale('ru'), 'Русский', l10n.languageRussian),
      (const Locale('ja'), '日本語', l10n.languageJapanese),
    ];
    bool isSelected((Locale?, String, String?) entry) => entry.$1 == null
        ? settings.locale == null
        : settings.locale?.languageCode == entry.$1!.languageCode;
    final current = languages.firstWhere(
      isSelected,
      orElse: () => languages.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.profile, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  photoUrl != null &&
                      !photoUrl.startsWith('storage://') &&
                      !photoUrl.contains('firebasestorage.googleapis.com')
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null
                  ? Text(
                      (displayName.isNotEmpty ? displayName[0] : 'U')
                          .toUpperCase(),
                      style: const TextStyle(color: AppColors.primary),
                    )
                  : (photoUrl.startsWith('storage://') ||
                            photoUrl.contains('firebasestorage.googleapis.com')
                        ? ClipOval(
                            child: AuthorizedImage(
                              url: photoUrl,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : null),
            ),
            title: Text(displayName),
            subtitle: Text(email),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
            ),
            onTap: () => context.push('/profile'),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: Text(l10n.howToUse),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
            ),
            onTap: () async {
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setBool(kTourHomeDoneKey, false);
              await prefs.setBool(kTourGroupDoneKey, false);
              if (!context.mounted) return;
              await FeatureTour.showTour(
                context,
                steps: [
                  (
                    title: l10n.tourHome1Title,
                    body: l10n.tourHome1Body,
                    icon: Icons.home_outlined,
                  ),
                  (
                    title: l10n.tourHome2Title,
                    body: l10n.tourHome2Body,
                    icon: Icons.person_outline,
                  ),
                  (
                    title: l10n.tourHome3Title,
                    body: l10n.tourHome3Body,
                    icon: Icons.group_add_outlined,
                  ),
                  (
                    title: l10n.tourGroup1Title,
                    body: l10n.tourGroup1Body,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  (
                    title: l10n.tourGroup2Title,
                    body: l10n.tourGroup2Body,
                    icon: Icons.add_circle_outline,
                  ),
                  (
                    title: l10n.tourGroup3Title,
                    body: l10n.tourGroup3Body,
                    icon: Icons.insights_outlined,
                  ),
                ],
              );
              await prefs.setBool(kTourHomeDoneKey, true);
              await prefs.setBool(kTourGroupDoneKey, true);
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.notifications,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: profile?.activityNotificationsEnabled ?? true,
            title: Text(notificationCopy.activityNotifications),
            subtitle: Text(notificationCopy.activityNotificationsHint),
            onChanged: user == null || profile == null
                ? null
                : (enabled) => ref
                      .read(notificationServiceProvider)
                      .setNotificationPreferences(
                        uid: user.uid,
                        activityEnabled: enabled,
                        remindersEnabled: profile.remindersEnabled,
                      ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: profile?.remindersEnabled ?? true,
            title: Text(notificationCopy.reminderNotifications),
            subtitle: Text(notificationCopy.reminderNotificationsHint),
            onChanged: user == null || profile == null
                ? null
                : (enabled) => ref
                      .read(notificationServiceProvider)
                      .setNotificationPreferences(
                        uid: user.uid,
                        activityEnabled: profile.activityNotificationsEnabled,
                        remindersEnabled: enabled,
                      ),
          ),
          const SizedBox(height: 16),
          Text(l10n.security, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: settings.appLockEnabled,
            title: Text(l10n.appLock),
            subtitle: Text(l10n.appLockHint),
            onChanged: (enabled) async {
              final notifier = ref.read(settingsProvider.notifier);
              if (!enabled) {
                await notifier.setAppLockEnabled(false);
                return;
              }
              final authenticator = ref.read(appLockAuthenticatorProvider);
              if (!await authenticator.isAvailable()) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.appLockUnavailable)),
                  );
                }
                return;
              }
              // Proving it works once before turning it on avoids locking
              // someone out with a lock they cannot open.
              if (await authenticator.authenticate(l10n.appLockReason)) {
                await notifier.setAppLockEnabled(true);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(l10n.appearance, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.themeMode, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.themeSystem),
                icon: const Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.themeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l10n.themeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value.first);
            },
          ),
          const SizedBox(height: 32),
          Text(l10n.language, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.translate),
            title: Text(current.$2),
            subtitle: current.$3 == null || current.$3 == current.$2
                ? null
                : Text(current.$3!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (sheetContext) => SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  children: [
                    for (final entry in languages)
                      _LanguageTile(
                        title: entry.$2,
                        subtitle: entry.$3 == entry.$2 ? null : entry.$3,
                        selected: isSelected(entry),
                        onTap: () {
                          final notifier = ref.read(settingsProvider.notifier);
                          if (entry.$1 == null) {
                            notifier.setFollowSystemLocale();
                          } else {
                            notifier.setLocale(entry.$1!);
                          }
                          Navigator.pop(sheetContext);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: AppColors.textSecondary),
            title: Text(l10n.signOut),
            onTap: () => _signOut(context, ref),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              _accountDeletionCopy(context).$1,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(_accountDeletionCopy(context).$2),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final uid = ref.read(authStateProvider).value?.uid;
  if (uid != null) {
    await ref.read(notificationServiceProvider).clearTokenOnSignOut(uid);
  }
  await ref.read(authServiceProvider).signOut();
  if (context.mounted) context.go('/welcome');
}

(String, String, String, String) _accountDeletionCopy(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return (
    l10n.deleteAccountTitle,
    l10n.deleteAccountSubtitle,
    l10n.deleteAccountConfirm,
    l10n.deleteAccountWarning,
  );
}

Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
  final copy = _accountDeletionCopy(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(copy.$3),
      content: Text(copy.$4),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(copy.$1),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(backendServiceProvider).call('deleteAccount', const {});
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) context.go('/welcome');
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userFacingError(error))));
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
