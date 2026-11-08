import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/currencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/image_picker_utils.dart';
import '../../core/utils/split.dart';
import '../../core/utils/user_error.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../l10n/engagement_copy.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../providers/settings_provider.dart';
import '../../services/movement_service.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_components.dart';
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
  String _category = AppConstants.categoryKeys.first;
  String? _receiptPath;
  bool _loading = false;
  bool _showSuccess = false;
  String? _error;
  Movement? _existing;
  bool _initialized = false;
  Map<String, dynamic>? _lastExpense;

  /// Currency the amount is typed in; null means the group currency.
  String? _entryCurrency;
  final _rate = TextEditingController();
  bool _rateLoading = false;
  bool _rateFailed = false;

  /// Members who own this movement. Null until the default is known.
  Set<String>? _participants;
  bool _customSplit = false;
  final Map<String, TextEditingController> _shareControllers = {};

  RecurrenceFrequency? _repeat;

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
      if (recent != null && AppConstants.categoryKeys.contains(recent)) {
        setState(() => _category = recent);
      } else if (_lastExpense?['category'] is String &&
          AppConstants.categoryKeys.contains(_lastExpense!['category'])) {
        setState(() => _category = _lastExpense!['category'] as String);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _rate.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _hydrate(Movement m) {
    if (_initialized) return;
    _existing = m;
    _title.text = m.title;
    _type = m.type;
    _category = m.category;
    _receiptPath = m.receiptUrl;
    if (m.isForeignCurrency) {
      _entryCurrency = m.originalCurrency;
      _amount.text = m.originalAmount!.toStringAsFixed(
        AppCurrencies.decimalDigits(m.originalCurrency!),
      );
      if (m.exchangeRate != null) _rate.text = _formatRate(m.exchangeRate!);
    } else {
      _amount.text = m.amount.toStringAsFixed(2);
    }
    _participants = m.allocation.keys.toSet();
    if (m.hasSplit) {
      final equal = equalSplit(
        m.amount,
        m.split!.keys.toList(),
        _groupCurrency ?? 'MAD',
      );
      final isEqual =
          equal.length == m.split!.length &&
          equal.entries.every(
            (e) => (m.split![e.key]! - e.value).abs() < 0.005,
          );
      _customSplit = !isEqual;
      for (final share in m.split!.entries) {
        _shareController(share.key).text = share.value.toStringAsFixed(2);
      }
    }
    _initialized = true;
  }

  String? get _groupCurrency =>
      ref.read(groupProvider(widget.groupId)).value?.currency;

  TextEditingController _shareController(String uid) =>
      _shareControllers.putIfAbsent(uid, TextEditingController.new);

  static String _formatRate(double rate) {
    final text = rate.toStringAsFixed(rate >= 1 ? 4 : 6);
    return text.contains('.')
        ? text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : text;
  }

  double? _parse(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  /// Typed amount converted to the group currency, or null while incomplete.
  double? _groupAmount(String groupCurrency) {
    final typed = _parse(_amount.text);
    if (typed == null || typed <= 0) return null;
    final entry = _entryCurrency;
    if (entry == null || entry == groupCurrency) {
      return roundToCurrency(typed, groupCurrency);
    }
    final rate = _parse(_rate.text);
    if (rate == null || rate <= 0) return null;
    return roundToCurrency(roundToCurrency(typed, entry) * rate, groupCurrency);
  }

  Future<void> _selectEntryCurrency(String code, String groupCurrency) async {
    setState(() {
      _entryCurrency = code == groupCurrency ? null : code;
      _rateFailed = false;
      _rate.clear();
    });
    if (code == groupCurrency) return;
    setState(() => _rateLoading = true);
    final rate = await ref
        .read(exchangeRateServiceProvider)
        .rate(from: code, to: groupCurrency);
    if (!mounted || _entryCurrency != code) return;
    setState(() {
      _rateLoading = false;
      _rateFailed = rate == null;
      if (rate != null) _rate.text = _formatRate(rate);
    });
  }

  static DateTime _nextRun(RecurrenceFrequency frequency, DateTime from) {
    if (frequency == RecurrenceFrequency.weekly) {
      return from.add(const Duration(days: 7));
    }
    final lastDay = DateTime(from.year, from.month + 2, 0).day;
    return DateTime(
      from.year,
      from.month + 1,
      from.day > lastDay ? lastDay : from.day,
      from.hour,
      from.minute,
    );
  }

  Future<void> _pickReceipt() async {
    final file = await pickGalleryImage(imageQuality: 75, maxWidth: 1600);
    if (file != null) {
      setState(() => _receiptPath = file.path);
    }
  }

  /// Selected participants in member order, so equal-split leftover cents
  /// always land on the same people for the same selection.
  List<String> _orderedParticipants(String owner) {
    final selected = _participants ?? {owner};
    final members =
        ref.read(groupMembersProvider(widget.groupId)).value ?? const [];
    final ordered = [
      for (final m in members)
        if (selected.contains(m.uid)) m.uid,
    ];
    for (final uid in selected) {
      if (!ordered.contains(uid)) ordered.add(uid);
    }
    return ordered;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);

    final group = ref.read(groupProvider(widget.groupId)).value;
    final groupCurrency = group?.currency ?? 'MAD';
    final typed = _parse(_amount.text);
    if (typed == null || typed <= 0) {
      setState(() => _error = l10n.enterValidAmountGtZero);
      return;
    }
    final isStarting = _existing?.isStartingBalance == true;
    final entry = isStarting ? null : _entryCurrency;
    ForeignAmount? original;
    if (entry != null && entry != groupCurrency) {
      final rate = _parse(_rate.text);
      if (rate == null || rate <= 0) {
        setState(() => _error = l10n.enterValidRate);
        return;
      }
      original = ForeignAmount(
        currency: entry,
        amount: roundToCurrency(typed, entry),
        rate: rate,
      );
    }
    final amount = _groupAmount(groupCurrency) ?? 0;
    if (amount <= 0) {
      setState(() => _error = l10n.enterValidAmountGtZero);
      return;
    }
    // The server enforces this too; checking the loaded ledger first saves a
    // slow round-trip for the common case. Edits are left to the server since
    // they only change the balance by the difference.
    if (!widget.isEditing && _type == MovementType.expense) {
      final loaded = ref.read(movementsProvider(widget.groupId)).hasValue;
      final available = ref.read(balanceProvider(widget.groupId)).total;
      if (loaded && amount - available > 0.005) {
        setState(() => _error = l10n.insufficientBalance);
        return;
      }
    }

    Map<String, double>? split;
    final canSplit = !isStarting && group != null && !group.isPersonal;
    if (canSplit) {
      final owner = _existing?.createdBy ?? user.uid;
      final participants = _orderedParticipants(owner);
      if (participants.isEmpty) {
        setState(() => _error = l10n.splitPickSomeone);
        return;
      }
      if (_customSplit) {
        final shares = <String, double>{};
        for (final uid in participants) {
          final share = _parse(_shareController(uid).text);
          if (share == null || share < 0) {
            setState(() => _error = l10n.splitMustMatch);
            return;
          }
          if (share > 0) shares[uid] = roundToCurrency(share, groupCurrency);
        }
        if (shares.isEmpty ||
            !splitMatchesAmount(shares, amount, groupCurrency)) {
          setState(() => _error = l10n.splitMustMatch);
          return;
        }
        split = shares.length == 1 && shares.containsKey(owner) ? null : shares;
      } else if (!(participants.length == 1 && participants.first == owner)) {
        split = equalSplit(amount, participants, groupCurrency);
      }
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
          split: split,
          original: original,
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
          split: split,
          original: original,
        );

        final repeat = _repeat;
        if (repeat != null) {
          try {
            await service.createRecurring(
              groupId: widget.groupId,
              type: _type,
              amount: amount,
              title: _title.text,
              category: _category,
              displayName: displayName,
              frequency: repeat,
              firstRunAt: _nextRun(repeat, DateTime.now()),
              split: split,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.recurringSetupFailed(userFacingError(e))),
                ),
              );
            }
          }
        }

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
      if (mounted) {
        setState(() {
          _error = message;
          _loading = false;
        });
      }
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
    final tones = context.semantic;
    final currency = group?.currency ?? '';
    final entryCurrency = _entryCurrency ?? currency;
    final isForeign =
        !isStarting && _entryCurrency != null && _entryCurrency != currency;
    final members =
        ref.watch(groupMembersProvider(widget.groupId)).value ?? const [];
    final canSplit =
        !isStarting && group != null && !group.isPersonal && members.length > 1;
    if (_participants == null && user != null && !widget.isEditing) {
      _participants = {user.uid};
    }
    final groupAmount = currency.isEmpty ? null : _groupAmount(currency);
    final available =
        !widget.isEditing &&
            _type == MovementType.expense &&
            currency.isNotEmpty &&
            ref.watch(movementsProvider(widget.groupId)).hasValue
        ? ref.watch(balanceProvider(widget.groupId)).total
        : null;
    final locale = Localizations.localeOf(context).toString();

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
          Column(
            children: [
              // Failure sits at the top of the form so it is readable the moment the
              // save fails, without having to scroll to the submit button first.
              if (_error != null)
                AppPage(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.smd,
                    AppSpacing.gutter,
                    AppSpacing.xs,
                  ),
                  child: _ErrorBanner(message: _error!),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.xs,
                    AppSpacing.gutter,
                    AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isStarting) ...[
                          Text(
                            l10n.onlyCreatorEditStarting,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // Amount leads the form: it is the one thing a person is
                        // certain about when they open this screen.
                        TextFormField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            fontFeatures: kTabularFigures,
                          ),
                          decoration: InputDecoration(
                            labelText: isStarting
                                ? l10n.startingAmount
                                : l10n.amount,
                            hintText: '0.00',
                            helperText: available == null
                                ? null
                                : l10n.availableInCaisse(
                                    formatMoney(available, currency: currency),
                                  ),
                            // The caisse currency is the default and
                            // rarely changes, so it is a quiet button
                            // rather than a field of its own.
                            suffixIcon: isStarting || currency.isEmpty
                                ? null
                                : Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: AppSpacing.xs,
                                    ),
                                    child: TextButton.icon(
                                      onPressed: _loading
                                          ? null
                                          : () async {
                                              final code =
                                                  await showAppSelectSheet<
                                                    String
                                                  >(
                                                    context: context,
                                                    label: l10n.currency,
                                                    value: entryCurrency,
                                                    options: [
                                                      for (final code
                                                          in AppCurrencies.codesPreferredFirst(
                                                            currency,
                                                          ))
                                                        AppSelectOption(
                                                          value: code,
                                                          label:
                                                              AppCurrencies.label(
                                                                code,
                                                                locale,
                                                              ),
                                                        ),
                                                    ],
                                                  );
                                              if (code != null) {
                                                _selectEntryCurrency(
                                                  code,
                                                  currency,
                                                );
                                              }
                                            },
                                      iconAlignment: IconAlignment.end,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                      ),
                                      label: Text(
                                        entryCurrency,
                                        semanticsLabel:
                                            '${l10n.currency}: $entryCurrency',
                                      ),
                                    ),
                                  ),
                          ),
                          validator: (v) {
                            final n = double.tryParse(
                              (v ?? '').replaceAll(',', '.'),
                            );
                            if (n == null || n <= 0) {
                              return l10n.enterValidAmount;
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        if (!isStarting && currency.isNotEmpty) ...[
                          if (isForeign) ...[
                            const SizedBox(height: AppSpacing.smd),
                            TextFormField(
                              controller: _rate,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.exchangeRateLabel(
                                  entryCurrency,
                                  currency,
                                ),
                                helperText: _rateFailed
                                    ? l10n.exchangeRateUnavailable
                                    : null,
                                suffixIcon: _rateLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (v) {
                                final n = _parse(v ?? '');
                                if (n == null || n <= 0) {
                                  return l10n.enterValidRate;
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                            if (groupAmount != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.convertedAmount(
                                  formatMoney(groupAmount, currency: currency),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ],
                        if (!isStarting) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.type,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _TypeChip(
                                  label: l10n.deposit,
                                  icon: Icons.south_east,
                                  selected: _type == MovementType.deposit,
                                  tint: tones.positive,
                                  onTap: _loading
                                      ? null
                                      : () => setState(
                                          () => _type = MovementType.deposit,
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.smd),
                              Expanded(
                                child: _TypeChip(
                                  label: l10n.expense,
                                  icon: Icons.north_east,
                                  selected: _type == MovementType.expense,
                                  tint: tones.negative,
                                  onTap: _loading
                                      ? null
                                      : () => setState(
                                          () => _type = MovementType.expense,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (_lastExpense != null &&
                              _type == MovementType.expense) ...[
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        setState(() {
                                          _title.text =
                                              _lastExpense?['title']
                                                  as String? ??
                                              '';
                                          _amount.text =
                                              _lastExpense?['amount']
                                                  as String? ??
                                              '';
                                          _category =
                                              _lastExpense?['category']
                                                  as String? ??
                                              _category;
                                        });
                                        HapticFeedback.selectionClick();
                                      },
                                icon: const Icon(Icons.replay, size: 18),
                                label: Text(
                                  EngagementCopy.of(context).repeatLastExpense,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
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
                          const SizedBox(height: AppSpacing.md),
                          AppSelectField<String>(
                            label: l10n.category,
                            value: AppConstants.categoryKeys.contains(_category)
                                ? _category
                                : AppConstants.categoryKeys.last,
                            options: [
                              for (final entry in l10n.localizedCategoryEntries)
                                AppSelectOption(
                                  value: entry.key,
                                  label: entry.label,
                                ),
                            ],
                            onChanged: _loading
                                ? (_) {}
                                : (v) => setState(() => _category = v),
                          ),
                          if (canSplit && user != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _SplitEditor(
                              title: _type == MovementType.expense
                                  ? l10n.splitTitleExpense
                                  : l10n.splitTitleDeposit,
                              members: members,
                              currentUid: user.uid,
                              currency: currency,
                              amount: groupAmount,
                              selected: _participants ?? {user.uid},
                              custom: _customSplit,
                              enabled: !_loading,
                              shareController: _shareController,
                              orderedParticipants: () => _orderedParticipants(
                                _existing?.createdBy ?? user.uid,
                              ),
                              onCustomChanged: (custom) =>
                                  setState(() => _customSplit = custom),
                              onSelectionChanged: (next) =>
                                  setState(() => _participants = next),
                              onShareChanged: () => setState(() {}),
                            ),
                          ],
                          if (!widget.isEditing) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppSelectField<RecurrenceFrequency?>(
                              label: l10n.repeatLabel,
                              value: _repeat,
                              options: [
                                AppSelectOption(
                                  value: null,
                                  label: l10n.repeatNever,
                                ),
                                AppSelectOption(
                                  value: RecurrenceFrequency.weekly,
                                  label: l10n.repeatWeekly,
                                ),
                                AppSelectOption(
                                  value: RecurrenceFrequency.monthly,
                                  label: l10n.repeatMonthly,
                                ),
                              ],
                              onChanged: _loading
                                  ? (_) {}
                                  : (v) => setState(() => _repeat = v),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          if (_receiptPath != null &&
                              _receiptPath!.trim().isNotEmpty) ...[
                            ReceiptImage(url: _receiptPath!, height: 160),
                            const SizedBox(height: AppSpacing.smd),
                          ],
                          OutlinedButton.icon(
                            onPressed: _loading ? null : _pickReceipt,
                            icon: const Icon(Icons.photo_outlined),
                            label: Text(
                              _receiptPath == null ||
                                      _receiptPath!.trim().isEmpty
                                  ? l10n.addReceipt
                                  : l10n.receiptSelected,
                            ),
                          ),
                          if (!widget.isEditing) ...[
                            const SizedBox(height: AppSpacing.lg),
                            const HomeBannerAd(),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Submit is pinned outside the scroll view so it stays reachable when
              // the keyboard opens, and it carries the whole ready/loading state.
              _SubmitBar(
                loading: _loading,
                label: widget.isEditing ? l10n.saveChanges : l10n.addMovement,
                onPressed: _loading ? null : _save,
              ),
            ],
          ),
          if (_showSuccess) const SuccessOverlay(),
        ],
      ),
    );
  }
}

/// Chooses who a movement belongs to: an equal split between the ticked
/// members, or exact amounts per member that must add up to the total.
class _SplitEditor extends StatelessWidget {
  const _SplitEditor({
    required this.title,
    required this.members,
    required this.currentUid,
    required this.currency,
    required this.amount,
    required this.selected,
    required this.custom,
    required this.enabled,
    required this.shareController,
    required this.orderedParticipants,
    required this.onCustomChanged,
    required this.onSelectionChanged,
    required this.onShareChanged,
  });

  final String title;
  final List<GroupMember> members;
  final String currentUid;
  final String currency;

  /// Total in the group currency, or null while the amount is incomplete.
  final double? amount;
  final Set<String> selected;
  final bool custom;
  final bool enabled;
  final TextEditingController Function(String uid) shareController;
  final List<String> Function() orderedParticipants;
  final ValueChanged<bool> onCustomChanged;
  final ValueChanged<Set<String>> onSelectionChanged;
  final VoidCallback onShareChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = amount;
    final ordered = orderedParticipants();
    final equalShares = total == null
        ? const <String, double>{}
        : equalSplit(total, ordered, currency);
    double? remaining;
    if (custom && total != null) {
      var assigned = 0.0;
      for (final uid in ordered) {
        assigned +=
            double.tryParse(
              shareController(uid).text.trim().replaceAll(',', '.'),
            ) ??
            0;
      }
      remaining = total - assigned;
    }
    final allSelected = members.every((m) => selected.contains(m.uid));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
              TextButton(
                onPressed: enabled
                    ? () => onSelectionChanged(
                        allSelected
                            ? {currentUid}
                            : {for (final m in members) m.uid},
                      )
                    : null,
                child: Text(
                  allSelected ? l10n.splitJustMe : l10n.splitEveryone,
                ),
              ),
            ],
          ),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.splitEqually)),
              ButtonSegment(value: true, label: Text(l10n.splitCustom)),
            ],
            selected: {custom},
            onSelectionChanged: enabled
                ? (value) => onCustomChanged(value.first)
                : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final member in members)
            InkWell(
              onTap: enabled
                  ? () {
                      final next = {...selected};
                      if (!next.remove(member.uid)) next.add(member.uid);
                      onSelectionChanged(next);
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected.contains(member.uid),
                      onChanged: enabled
                          ? (checked) {
                              final next = {...selected};
                              if (checked == true) {
                                next.add(member.uid);
                              } else {
                                next.remove(member.uid);
                              }
                              onSelectionChanged(next);
                            }
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        member.uid == currentUid
                            ? '${member.displayName} (${l10n.you})'
                            : member.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (selected.contains(member.uid))
                      if (custom)
                        SizedBox(
                          width: 112,
                          child: TextField(
                            controller: shareController(member.uid),
                            enabled: enabled,
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '0.00',
                              suffixText: currency,
                            ),
                            onChanged: (_) => onShareChanged(),
                          ),
                        )
                      else
                        Text(
                          equalShares[member.uid] == null
                              ? '—'
                              : formatMoney(
                                  equalShares[member.uid]!,
                                  currency: currency,
                                ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFeatures: kTabularFigures,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          if (remaining != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              remaining.abs() < 0.005
                  ? l10n.splitBalanced
                  : l10n.splitRemaining(
                      formatMoney(remaining, currency: currency),
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: remaining.abs() < 0.005
                    ? context.semantic.positiveInk
                    : scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Failure notice for the whole form. Kept distinct from field validation so a
/// person can tell "this value is wrong" from "the save did not go through".
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.smd,
            AppSpacing.gutter,
            AppSpacing.smd,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: loading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? tint : scheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.control),
            border: Border.all(
              color: selected ? tint : scheme.outline,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? scheme.onPrimary : tint),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
