import 'package:flutter/material.dart';

/// Compact confirmation dialog with a fixed max width (no Flexible gap).
class CompactAlertDialog extends StatelessWidget {
  const CompactAlertDialog({super.key, this.title, this.content, this.actions});

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 340),
        child: Material(
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  DefaultTextStyle(
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: scheme.onSurface,
                    ),
                    child: title!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (content != null)
                  DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    child: content!,
                  ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OverflowBar(spacing: 8, children: actions!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showCompactDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black54,
    builder: (ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: barrierDismissible ? () => Navigator.pop(ctx) : null,
        child: GestureDetector(
          onTap: () {}, // keep taps on the card from dismissing
          child: builder(ctx),
        ),
      );
    },
  );
}
