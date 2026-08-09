import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
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
      final group = await ref.read(groupServiceProvider).joinGroup(
            inviteCode: _code.text,
            uid: user.uid,
            displayName:
                profile?.displayName ?? user.displayName ?? l10n.member,
            photoUrl: profile?.photoUrl ?? user.photoURL,
          );

      await ref.read(notificationServiceProvider).notifyGroupEvent(
            groupId: group.id,
            title: l10n.someoneJoined,
            body: l10n.memberJoinedBody(
              profile?.displayName ?? l10n.aMember,
              group.name,
            ),
            actorUid: user.uid,
            type: 'member_join',
          );

      HapticFeedback.mediumImpact();
      if (mounted) {
        // Keep Home under the group so the back button works.
        context.go('/home');
        context.push('/groups/${group.id}');
      }    } catch (e) {
      setState(() {
        _error = e.toString().contains('No group')
            ? l10n.noGroupForCode
            : e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinAGroup)),
      body: SafeArea(
        child: Padding(
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 6,
                      ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.inviteCode,
                    hintText: 'ABC123',
                  ),
                  validator: (v) {
                    if (v == null ||
                        v.trim().length != AppConstants.inviteCodeLength) {
                      return l10n.enterCodeLength(AppConstants.inviteCodeLength);
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const Spacer(),
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
