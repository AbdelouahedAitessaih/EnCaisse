import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _startingAmount = TextEditingController();
  String _currency = 'MAD';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _startingAmount.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null) return;

    final startingRaw = _startingAmount.text.trim().replaceAll(',', '.');
    final startingAmount = startingRaw.isEmpty
        ? 0.0
        : double.tryParse(startingRaw) ?? -1;
    if (startingAmount < 0) {
      setState(() => _error = AppLocalizations.of(context).validStartingAmount);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final group = await ref.read(groupServiceProvider).createGroup(
            name: _name.text,
            createdBy: user.uid,
            displayName: profile?.displayName ??
                user.displayName ??
                AppLocalizations.of(context).member,
            photoUrl: profile?.photoUrl ?? user.photoURL,
            currency: _currency,
            startingAmount: startingAmount,
          );

      final newCount = (profile?.groupsCreatedCount ?? 0) + 1;
      await ref.read(authServiceProvider).updateUserFields(user.uid, {
        'groupsCreatedCount': newCount,
      });

      // Interstitial only after creating the 3rd group
      if (newCount == AppConstants.groupsBeforeInterstitial) {
        await ref.read(adServiceProvider).showInterstitialIfReady();
      }

      HapticFeedback.mediumImpact();
      if (mounted) {
        // Keep Home under the group so the back button works.
        context.go('/home');
        context.push('/groups/${group.id}');
      }    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAGroup)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.nameYourCaisse,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.inviteCodeHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.groupName,
                    hintText: l10n.groupNameHint,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return l10n.enterGroupName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: InputDecoration(labelText: l10n.currency),
                  items: const [
                    DropdownMenuItem(value: 'MAD', child: Text('MAD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _currency = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startingAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.startingAmountOptional,
                    hintText: '0.00',
                    suffixText: _currency,
                    helperText: l10n.startingAmountHelper,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: _loading ? null : _create,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.createGroup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
