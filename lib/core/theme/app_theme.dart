import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    );

    return _build(
      base: base,
      scheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
        surfaceContainerHighest: AppColors.neutralSurface,
      ),
      semantic: AppSemantic.light,
      overlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
    );

    // Brand green is only 3.0:1 against the dark scaffold, so dark mode runs a
    // lightened primary for text and marks. The hue is unchanged.
    return _build(
      base: base,
      scheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF5CC7A5),
        onPrimary: Color(0xFF06301F),
        primaryContainer: Color(0xFF14332A),
        onPrimaryContainer: Color(0xFF9BE0C7),
        secondary: Color(0xFFF0A183),
        onSecondary: Color(0xFF3A1206),
        surface: Color(0xFF1C2A25),
        onSurface: Color(0xFFF2F7F5),
        onSurfaceVariant: Color(0xFFA8B5AF),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        outline: Color(0xFF2A3832),
        surfaceContainerHighest: Color(0xFF1C2A25),
      ),
      semantic: AppSemantic.dark,
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _build({
    required ThemeData base,
    required ColorScheme scheme,
    required AppSemantic semantic,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final onSurface = scheme.onSurface;
    final secondaryText = scheme.onSurfaceVariant;
    final mutedText = scheme.brightness == Brightness.light
        ? AppColors.textMuted
        : const Color(0xFF7A8781);
    final border = scheme.outline;
    final disabledFg = scheme.brightness == Brightness.light
        ? const Color(0xFF9E9E9A)
        : const Color(0xFF5C6B66);

    // Keep every Material text style aligned with the active theme. Widgets
    // using styles not explicitly customized below (for example bodySmall or
    // titleSmall) should not inherit a platform default text color.
    final themedTextTheme = base.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.control),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _scaffoldFor(base.brightness),
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[semantic],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _scaffoldFor(base.brightness),
        foregroundColor: onSurface,
        centerTitle: false,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        iconTheme: IconThemeData(color: onSurface, size: AppSizes.iconMd),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      // Primary: the one filled action on a screen.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.32),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.75),
          minimumSize: const Size.fromHeight(AppSizes.control),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: controlShape,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      // Secondary: neutral outline. Deliberately not green, so a screen with
      // both a primary and secondary action still has one clear focal point.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: onSurface,
          minimumSize: const Size.fromHeight(AppSizes.control),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          side: BorderSide(color: border, width: 1),
          shape: controlShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // Tertiary: text-only.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          disabledForegroundColor: disabledFg,
          minimumSize: const Size(0, AppTapTarget.min),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.brightness == Brightness.light
            ? AppColors.surface
            : const Color(0xFF16201C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.smd,
        ),
        border: _fieldBorder(border),
        enabledBorder: _fieldBorder(border),
        focusedBorder: _fieldBorder(scheme.primary, width: 2),
        errorBorder: _fieldBorder(scheme.error),
        focusedErrorBorder: _fieldBorder(scheme.error, width: 2),
        disabledBorder: _fieldBorder(
          scheme.brightness == Brightness.light
              ? const Color(0xFFEBEBE8)
              : const Color(0xFF232F2B),
        ),
        labelStyle: TextStyle(color: secondaryText, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: mutedText, fontSize: 15),
        helperStyle: TextStyle(color: mutedText, fontSize: 12),
        errorStyle: TextStyle(color: scheme.error, fontSize: 12),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: AppSizes.hairline,
        space: AppSizes.hairline,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.brightness == Brightness.light
            ? const Color(0xFF1F2A26)
            : const Color(0xFF24332D),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF2F7F5),
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        actionTextColor: const Color(0xFF6FD3AE),
        insetPadding: const EdgeInsets.all(AppSpacing.smd),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: semantic.neutralSurface,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(color: onSurface, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimary, fontSize: 13),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      // Selection is brand teal; coral stays reserved for money going out.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? semantic.positiveSurface
                : null,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? semantic.positiveInk
                : onSurface,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: secondaryText,
        textColor: onSurface,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surface),
          maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 300)),
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.field),
              side: BorderSide(color: border),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          side: BorderSide(color: border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: semantic.neutralSurface,
        circularTrackColor: semantic.neutralSurface,
      ),
      textTheme: themedTextTheme.copyWith(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: onSurface,
          height: 1.15,
          letterSpacing: -0.8,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: mutedText,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryText,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: mutedText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static Color _scaffoldFor(Brightness brightness) =>
      brightness == Brightness.light
      ? AppColors.background
      : const Color(0xFF0E1512);
}

/// Tabular figures keep money columns from shifting as digits change, which is
/// what makes a running balance readable rather than jumpy.
const List<FontFeature> kTabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

extension MoneyText on TextStyle {
  /// Large balance figure — the dominant element on a financial screen.
  TextStyle asMoney({Color? color}) => copyWith(
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    fontFeatures: kTabularFigures,
    color: color,
  );

  /// Secondary figure inside a list row or stat.
  TextStyle asMoneyInline({Color? color}) => copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: kTabularFigures,
    color: color,
  );
}
