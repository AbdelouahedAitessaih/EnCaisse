import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../providers/settings_provider.dart';

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
    final languages = <(Locale, String)>[
      (const Locale('en'), l10n.languageEnglish),
      (const Locale('fr'), l10n.languageFrench),
      (const Locale('ar'), l10n.languageArabic),
      (const Locale('es'), l10n.languageSpanish),
      (const Locale('pt'), l10n.languagePortuguese),
      (const Locale('zh'), l10n.languageChinese),
      (const Locale('hi'), l10n.languageHindi),
      (const Locale('ru'), l10n.languageRussian),
      (const Locale('ja'), l10n.languageJapanese),
    ];

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
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      (displayName.isNotEmpty ? displayName[0] : 'U')
                          .toUpperCase(),
                      style: const TextStyle(color: AppColors.primary),
                    )
                  : null,
            ),
            title: Text(displayName),
            subtitle: Text(email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          ...languages.map(
            (entry) => _LanguageTile(
              title: entry.$2,
              selected: settings.locale.languageCode == entry.$1.languageCode,
              onTap: () =>
                  ref.read(settingsProvider.notifier).setLocale(entry.$1),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
