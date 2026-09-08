import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../providers/settings_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const _rememberMeKey = 'auth_remember_me';
  static const _rememberedEmailKey = 'auth_remembered_email';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            email: _email.text,
            password: _password.text,
            displayName: _name.text,
          );
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_rememberedEmailKey, _email.text.trim());
      TextInput.finishAutofillContext(shouldSave: true);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final l10n = AppLocalizations.of(context);
    final s = e.toString();
    if (s.contains('email-already-in-use')) {
      return l10n.emailAlreadyInUse;
    }
    if (s.contains('weak-password')) {
      return l10n.weakPassword;
    }
    if (s.contains('REPLACE_WITH') || s.contains('placeholder')) {
      return l10n.firebaseNotConfigured;
    }
    if (s.contains('missing-id-token') ||
        s.contains('clientConfigurationError') ||
        s.contains('google-sign-in-config') ||
        s.contains('serverClientId') ||
        s.contains('SHA-1') ||
        s.contains('Account reauth failed') ||
        s.contains('[16]') ||
        s.contains('10:') ||
        s.contains('ApiException: 10')) {
      return l10n.googleSignInConfigError;
    }
    if (s.contains('GoogleSignInExceptionCode.canceled') ||
        s.contains('sign_in_canceled')) {
      return l10n.googleSignInCanceled;
    }
    if (s.contains('GoogleSignIn') || s.contains('google')) {
      return l10n.googleSignInFailed;
    }
    return l10n.signUpFailed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.joinEncaisse,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.signUpSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(labelText: l10n.displayName),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) {
                        return l10n.enterName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.newUsername,
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(labelText: l10n.email),
                    validator: (v) {
                      if (v == null || !v.contains('@')) {
                        return l10n.validEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loading ? null : _submit(),
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      suffixIcon: IconButton(
                        tooltip:
                            _obscure ? l10n.showPassword : l10n.hidePassword,
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return l10n.passwordMin;
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.createAccount),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.or),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _google,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(l10n.continueWithGoogle),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(l10n.haveAccount),
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
