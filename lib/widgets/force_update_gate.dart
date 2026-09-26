import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../services/app_update_service.dart';

/// Blocks or prompts for app updates based on Firestore `config/appUpdate`
/// and Google Play in-app updates.
class ForceUpdateGate extends ConsumerStatefulWidget {
  const ForceUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends ConsumerState<ForceUpdateGate> {
  AppUpdateDecision? _decision;
  bool _checking = true;
  bool _updating = false;
  bool _softPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (!ref.read(firebaseReadyProvider)) {
      if (mounted) setState(() => _checking = false);
      return;
    }
    try {
      final decision =
          await ref.read(appUpdateServiceProvider).checkForUpdate();
      if (!mounted) return;
      setState(() {
        _decision = decision;
        _checking = false;
      });
      if (decision.action == AppUpdateAction.softUpdate && !_softPromptShown) {
        _softPromptShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showSoftPrompt());
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _showSoftPrompt() async {
    if (!mounted || _decision == null) return;
    final l10n = AppLocalizations.of(context);
    final message = _decision!.config.message?.trim().isNotEmpty == true
        ? _decision!.config.message!
        : l10n.updateAvailableBody;

    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAvailableTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.updateLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.updateNow),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      await _runUpdate(immediate: false);
    }
  }

  Future<void> _runUpdate({required bool immediate}) async {
    setState(() => _updating = true);
    try {
      await ref.read(appUpdateServiceProvider).startUpdate(
            immediate: immediate,
            config: _decision?.config,
          );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return widget.child;

    final decision = _decision;
    if (decision == null || decision.action != AppUpdateAction.forceUpdate) {
      return widget.child;
    }

    final l10n = AppLocalizations.of(context);
    final defaultMsg = Theme.of(context).platform == TargetPlatform.iOS
        ? l10n.forceUpdateBodyIos
        : l10n.forceUpdateBody;
    final message = decision.config.message?.trim().isNotEmpty == true
        ? decision.config.message!
        : defaultMsg;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Material(
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.system_update_alt,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.forceUpdateTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _updating
                          ? null
                          : () => _runUpdate(immediate: true),
                      child: _updating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.updateNow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
