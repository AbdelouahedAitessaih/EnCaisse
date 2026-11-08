import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

/// Device authentication for the app lock. Kept behind a small seam so
/// widget tests can run without the platform channel.
class AppLockAuthenticator {
  const AppLockAuthenticator();

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await LocalAuthentication().isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// True when unlocked. A device that no longer has any lock configured
  /// unlocks too: refusing would trap the person outside their own data.
  Future<bool> authenticate(String reason) async {
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      return e.code == LocalAuthExceptionCode.noCredentialsSet ||
          e.code == LocalAuthExceptionCode.noBiometricHardware;
    } catch (_) {
      return false;
    }
  }
}

final appLockAuthenticatorProvider = Provider<AppLockAuthenticator>(
  (ref) => const AppLockAuthenticator(),
);

/// Covers the app with a lock screen at launch and after it has been in the
/// background for [relockAfter], when App lock is on.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  static const relockAfter = Duration(seconds: 30);

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  late bool _locked = ref.read(settingsProvider).appLockEnabled;
  DateTime? _backgroundedAt;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system prompt itself pauses the app; that must not count as leaving.
    if (_authenticating) return;
    if (!ref.read(settingsProvider).appLockEnabled) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null &&
          DateTime.now().difference(since) >= AppLockGate.relockAfter) {
        setState(() => _locked = true);
        _unlock();
      }
    }
  }

  Future<void> _unlock() async {
    if (_authenticating || !mounted) return;
    final l10n = AppLocalizations.of(context);
    _authenticating = true;
    var ok = false;
    try {
      ok = await ref
          .read(appLockAuthenticatorProvider)
          .authenticate(l10n.appLockReason);
    } finally {
      _authenticating = false;
    }
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(settingsProvider).appLockEnabled;
    final showLock = enabled && _locked;
    return Stack(
      children: [
        widget.child,
        if (showLock) Positioned.fill(child: _LockScreen(onUnlock: _unlock)),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.appLockTitle,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.appLockUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
