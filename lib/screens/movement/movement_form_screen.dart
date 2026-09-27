import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/image_picker_utils.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/engagement_copy.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../providers/settings_provider.dart';
import '../../services/movement_service.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/branded_lottie.dart';
import '../../widgets/home_banner_ad.dart';
import '../../widgets/receipt_image.dart';

class MovementFormScreen extends ConsumerStatefulWidget {
  const MovementFormScreen({
    super.key,
    required this.groupId,
    this.movementId,
    this.initialType,
  });

  final String groupId;
  final String? movementId;
  final MovementType? initialType;

  bool get isEditing => movementId != null;

  @override
  ConsumerState<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends ConsumerState<MovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  late MovementType _type = widget.initialType ?? MovementType.expense;
  String _category = AppConstants.categories.first;
  String? _receiptPath;
  bool _loading = false;
  bool _showSuccess = false;
  String? _error;
  Movement? _existing;
  bool _initialized = false;
  Map<String, dynamic>? _lastExpense;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.isEditing) return;
      final prefs = ref.read(sharedPreferencesProvider);
      final uid = ref.read(authStateProvider).value?.uid;
      final recent = uid == null
          ? null
          : prefs.getString(
                  'recent_movement_category_${uid}_${widget.groupId}',
                ) ??
                prefs.getString('recent_movement_category');
      final recentType = uid == null
          ? null
          : prefs.getString('recent_movement_type_${uid}_${widget.groupId}');
      if (widget.initialType == null && recentType != null) {
        _type = recentType == MovementType.expense.name
            ? MovementType.expense
            : MovementType.deposit;
      }
      final rawTemplate = uid == null
          ? null
          : prefs.getString('recent_expense_${uid}_${widget.groupId}');
      if (rawTemplate != null) {
        try {
          final decoded = jsonDecode(rawTemplate);
          if (decoded is Map<String, dynamic>) {
            _lastExpense = decoded;
          }
        } catch (_) {}
      }
      if (recent != null && AppConstants.categories.contains(recent)) {
        setState(() => _category = recent);
      } else if (_lastExpense?['category'] is String &&
          AppConstants.categories.contains(_lastExpense!['category'])) {
        setState(() => _category = _lastExpense!['category'] as String);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _hydrate(Movement m) {
    if (_initialized) return;
    _existing = m;
    _title.text = m.title;
    _amount.text = m.amount.toStringAsFixed(2);
    _type = m.type;
    _category = m.category;
    _receiptPath = m.receiptUrl;
    _initialized = true;
  }

  Future<void> _pickReceipt() async {
    final file = await pickGalleryImage(imageQuality: 75, maxWidth: 1600);
    if (file != null) {
      setState(() => _receiptPath = file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);

    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.enterValidAmountGtZero);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final displayName =
          profile?.displayName ?? user.displayName ?? l10n.member;
      final service = ref.read(movementServiceProvider);

      var receiptUrl = _receiptPath;
      if (receiptUrl != null &&
          !receiptUrl.startsWith('http://') &&
          !receiptUrl.startsWith('https://')) {
        receiptUrl = await ref
            .read(storageServiceProvider)
            .uploadReceipt(groupId: widget.groupId, localPath: receiptUrl);
      }

      if (widget.isEditing && _existing != null) {
        await service.updateMovement(
          groupId: widget.groupId,
          existing: _existing!,
          type: _type,
          amount: amount,
          title: _title.text,
          category: _category,
          uid: user.uid,
          displayName: displayName,
          receiptUrl: receiptUrl,
        );
      } else {
        await service.createMovement(
          groupId: widget.groupId,
          type: _type,
          amount: amount,
          title: _title.text,
          category: _category,
          uid: user.uid,
          displayName: displayName,
          receiptUrl: receiptUrl,
        );

        await ref.read(reviewServiceProvider).recordSuccessfulMovement();
      }

      try {
        await ref
            .read(sharedPreferencesProvider)
            .setString('recent_movement_category', _category);
        await ref
            .read(sharedPreferencesProvider)
            .setString(
              'recent_movement_category_${user.uid}_${widget.groupId}',
              _category,
            );
        await ref
            .read(sharedPreferencesProvider)
            .setString(
              'recent_movement_type_${user.uid}_${widget.groupId}',
              _type.name,
            );
        if (!widget.isEditing && _type == MovementType.expense) {
          final uid = user.uid;
          await ref
              .read(sharedPreferencesProvider)
              .setString(
                'recent_expense_${uid}_${widget.groupId}',
                jsonEncode({
                  'title': _title.text.trim(),
                  'amount': amount.toString(),
                  'category': _category,
                }),
              );
        }
      } catch (_) {}

      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() {
        _showSuccess = true;
        _loading = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) context.pop();
    } catch (e) {
      final message = e is InsufficientBalanceException
          ? l10n.insufficientBalance
          : userFacingError(e);
      setState(() {
        _error = message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final movements = ref.watch(movementsProvider(widget.groupId)).value;
      final found = movements
          ?.where((m) => m.id == widget.movementId)
          .firstOrNull;
      if (found != null) _hydrate(found);
    }

    final l10n = AppLocalizations.of(context);
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final user = ref.watch(authStateProvider).value;
    final isStarting = _existing?.isStartingBalance == true;
    final canEditStarting =
        !isStarting || (user != null && group?.createdBy == user.uid);
    final scheme = Theme.of(context).colorScheme;

    if (isStarting && !canEditStarting) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.startingBalance)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.onlyCreatorCanEditStarting,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStarting
              ? l10n.editStartingBalance
              : (widget.isEditing ? l10n.editMovement : l10n.addMovement),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isStarting) ...[
                      Text(
                        l10n.onlyCreatorEditStarting,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      Text(
                        l10n.type,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                              label: l10n.deposit,
                              selected: _type == MovementType.deposit,
                              color: AppColors.deposit,
                              onTap: () =>
                                  setState(() => _type = MovementType.deposit),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeChip(
                              label: l10n.expense,
                              selected: _type == MovementType.expense,
                              color: AppColors.expense,
                              onTap: () =>
                                  setState(() => _type = MovementType.expense),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_lastExpense != null &&
                          _type == MovementType.expense) ...[
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _title.text =
                                    _lastExpense?['title'] as String? ?? '';
                                _amount.text =
                                    _lastExpense?['amount'] as String? ?? '';
                                _category =
                                    _lastExpense?['category'] as String? ??
                                    _category;
                              });
                              HapticFeedback.selectionClick();
                            },
                            icon: const Icon(Icons.replay),
                            label: Text(
                              EngagementCopy.of(context).repeatLastExpense,
                            ),
                          ),
                        ),
                      ],
                    ],
                    TextFormField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: isStarting
                            ? l10n.startingAmount
                            : l10n.amount,
                        hintText: '0.00',
                      ),
                      validator: (v) {
                        final n = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (n == null || n <= 0) return l10n.enterValidAmount;
                        return null;
                      },
                    ),
                    if (!isStarting) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _title,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l10n.title,
                          hintText: l10n.titleHint,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.enterTitle;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppSelectField<String>(
                        label: l10n.category,
                        value: AppConstants.categories.contains(_category)
                            ? _category
                            : AppConstants.categories.last,
                        options: [
                          for (final c in AppConstants.categories)
                            AppSelectOption(value: c, label: c),
                        ],
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(height: 16),
                      if (_receiptPath != null &&
                          _receiptPath!.trim().isNotEmpty) ...[
                        ReceiptImage(url: _receiptPath!, height: 160),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: _pickReceipt,
                        icon: const Icon(Icons.photo_outlined),
                        label: Text(
                          _receiptPath == null || _receiptPath!.trim().isEmpty
                              ? l10n.addReceipt
                              : l10n.receiptSelected,
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: scheme.error)),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? l10n.saveChanges
                                  : l10n.addMovement,
                            ),
                    ),
                    if (!widget.isEditing && !isStarting) ...[
                      const SizedBox(height: 24),
                      const HomeBannerAd(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccess) const SuccessOverlay(),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? color : scheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : scheme.outline,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
