import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Form field that opens a compact bottom sheet instead of a full-screen menu.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
  });

  final String label;
  final String? hint;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? Function(T?)? validator;

  String? get _selectedLabel {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  Future<T?> _openSheet(BuildContext context) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.45;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    label,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final selected = option.value == value;
                      return ListTile(
                        title: Text(
                          option.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(ctx, option.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        final scheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: () async {
            final selected = await _openSheet(context);
            if (selected == null) return;
            onChanged(selected);
            state.didChange(selected);
          },
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: InputDecorator(
            isEmpty: _selectedLabel == null,
            isFocused: false,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.keyboard_arrow_down),
            ),
            child: Text(
              _selectedLabel ?? hint ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _selectedLabel == null
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
            ),
          ),
        );
      },
    );
  }
}
