import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _busy = false;

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verificationEmailSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final ok =
          await ref.read(authServiceProvider).reloadAndCheckEmailVerified();
      if (!mounted) return;
      if (ok) {
        // Let userChanges + GoRouter refresh pick up emailVerified before navigate.
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.emailNotVerifiedYet)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle),
        actions: [
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go('/welcome');
                  },
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                size: 72, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              l10n.verifyEmailBody(email),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _busy ? null : _check,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.checkVerification),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _resend,
              child: Text(l10n.resendVerification),
            ),
          ],
        ),
      ),
    );
  }
}
