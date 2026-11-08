import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/backend_service.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key, this.initialCode});

  /// Prefilled from an invite link.
  final String? initialCode;

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.initialCode ?? '');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final group = await ref
          .read(groupServiceProvider)
          .joinGroup(
            inviteCode: _code.text,
            uid: user.uid,
            displayName:
                profile?.displayName ?? user.displayName ?? l10n.member,
            photoUrl: profile?.photoUrl ?? user.photoURL,
          );

      HapticFeedback.mediumImpact();
      if (mounted) {
        // Keep Home under the group so the back button works.
        context.go('/home');
        context.push('/groups/${group.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is BackendCallException && e.code == 'not-found'
              ? l10n.noGroupForCode
              : userFacingError(e);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joinAGroup),
        // Opened from an invite link there is nothing underneath to pop to.
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/home'),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.enterInviteCode,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.askForCode(AppConstants.inviteCodeLength),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(
                      AppConstants.inviteCodeLength,
                    ),
                  ],
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(letterSpacing: 6),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.inviteCode,
                    hintText: 'ABC123',
                  ),
                  validator: (v) {
                    if (v == null ||
                        v.trim().length != AppConstants.inviteCodeLength) {
                      return l10n.enterCodeLength(
                        AppConstants.inviteCodeLength,
                      );
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _join,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.joinGroup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
