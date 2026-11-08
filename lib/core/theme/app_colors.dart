/// EnCaisse design tokens.
///
/// Flat design: no gradients, no shadows. Teal + coral only.
///
/// Two layers live here:
///  * static brand constants — the same in both themes, used for brand marks
///    and anything that must not shift with brightness;
///  * [AppSemantic] — a [ThemeExtension] carrying the meaning-bearing colors
///    (positive / negative / warning / neutral) so every screen reads them from
///    the active theme instead of hard-coding a hex value. That is what keeps
///    dark mode honest.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryDark = Color(0xFF0A5240);
  static const Color primaryLight = Color(0xFFE6F4F0);
  static const Color accent = Color(0xFFD85A30);
  static const Color accentLight = Color(0xFFFBEDE8);

  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF636363);
  static const Color textMuted = Color(0xFF6E6E6E);
  static const Color border = Color(0xFFE3E3E0);
  static const Color neutralSurface = Color(0xFFF2F2EF);

  static const Color deposit = Color(0xFF0F6E56);
  static const Color expense = Color(0xFFD85A30);
  static const Color error = Color(0xFFB42318);
  static const Color success = Color(0xFF0F6E56);
}

/// Meaning-bearing colors, resolved per theme.
///
/// Brand coral (#D85A30) only reaches 3.7:1 on the light background, so it is
/// used for marks and large figures but never for small body text. The `Ink`
/// variants are the text-safe versions of the same hue.
@immutable
class AppSemantic extends ThemeExtension<AppSemantic> {
  const AppSemantic({
    required this.positive,
    required this.positiveInk,
    required this.positiveSurface,
    required this.negative,
    required this.negativeInk,
    required this.negativeSurface,
    required this.warning,
    required this.warningInk,
    required this.warningSurface,
    required this.neutralSurface,
    required this.neutralBorder,
    required this.overlay,
  });

  /// Graphical accent for money coming in.
  final Color positive;

  /// Text-safe "in" tone.
  final Color positiveInk;

  final Color positiveSurface;

  /// Graphical accent for money going out.
  final Color negative;

  /// Text-safe "out" tone.
  final Color negativeInk;

  final Color negativeSurface;

  final Color warning;
  final Color warningInk;
  final Color warningSurface;

  /// Quiet fill for chips, pills and inert tiles.
  final Color neutralSurface;

  /// Hairline used instead of a shadow to separate surfaces.
  final Color neutralBorder;

  /// Dialog scrim.
  final Color overlay;

  static const light = AppSemantic(
    positive: Color(0xFF0F6E56),
    positiveInk: Color(0xFF0B5A46),
    positiveSurface: Color(0xFFE6F4F0),
    negative: Color(0xFFD85A30),
    negativeInk: Color(0xFFA83A16),
    negativeSurface: Color(0xFFFBEDE8),
    warning: Color(0xFFB07407),
    warningInk: Color(0xFF8A5B05),
    warningSurface: Color(0xFFFCF3E2),
    neutralSurface: Color(0xFFF2F2EF),
    neutralBorder: Color(0xFFE3E3E0),
    overlay: Color(0x66101410),
  );

  static const dark = AppSemantic(
    positive: Color(0xFF2FA37F),
    positiveInk: Color(0xFF5CC7A5),
    positiveSurface: Color(0xFF14332A),
    negative: Color(0xFFE8794F),
    negativeInk: Color(0xFFF0A183),
    negativeSurface: Color(0xFF3A231A),
    warning: Color(0xFFE0A94A),
    warningInk: Color(0xFFEFC978),
    warningSurface: Color(0xFF33280F),
    neutralSurface: Color(0xFF1C2A25),
    neutralBorder: Color(0xFF2A3832),
    overlay: Color(0x99000000),
  );

  @override
  AppSemantic copyWith({
    Color? positive,
    Color? positiveInk,
    Color? positiveSurface,
    Color? negative,
    Color? negativeInk,
    Color? negativeSurface,
    Color? warning,
    Color? warningInk,
    Color? warningSurface,
    Color? neutralSurface,
    Color? neutralBorder,
    Color? overlay,
  }) {
    return AppSemantic(
      positive: positive ?? this.positive,
      positiveInk: positiveInk ?? this.positiveInk,
      positiveSurface: positiveSurface ?? this.positiveSurface,
      negative: negative ?? this.negative,
      negativeInk: negativeInk ?? this.negativeInk,
      negativeSurface: negativeSurface ?? this.negativeSurface,
      warning: warning ?? this.warning,
      warningInk: warningInk ?? this.warningInk,
      warningSurface: warningSurface ?? this.warningSurface,
      neutralSurface: neutralSurface ?? this.neutralSurface,
      neutralBorder: neutralBorder ?? this.neutralBorder,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppSemantic lerp(ThemeExtension<AppSemantic>? other, double t) {
    if (other is! AppSemantic) return this;
    return AppSemantic(
      positive: Color.lerp(positive, other.positive, t)!,
      positiveInk: Color.lerp(positiveInk, other.positiveInk, t)!,
      positiveSurface: Color.lerp(positiveSurface, other.positiveSurface, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeInk: Color.lerp(negativeInk, other.negativeInk, t)!,
      negativeSurface: Color.lerp(negativeSurface, other.negativeSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningInk: Color.lerp(warningInk, other.warningInk, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      neutralSurface: Color.lerp(neutralSurface, other.neutralSurface, t)!,
      neutralBorder: Color.lerp(neutralBorder, other.neutralBorder, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

/// Convenience access so widgets can write `context.semantic.positive`.
extension AppSemanticAccess on BuildContext {
  AppSemantic get semantic =>
      Theme.of(this).extension<AppSemantic>() ?? AppSemantic.light;
}

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal page gutter. One value, used by every screen.
  static const double gutter = 20;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double field = 12;
  static const double control = 12;
  static const double md = 16;
  static const double lg = 20;
}

abstract final class AppSizes {
  /// Standard control height. Fields and buttons share it so a form reads as
  /// one system rather than a pile of mismatched boxes.
  static const double control = 52;

  static const double fieldMin = 56;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double avatarSm = 36;
  static const double avatarMd = 44;
  static const double avatarLg = 56;
  static const double hairline = 1;
}

/// Minimum comfortable touch target. Icon-only controls are padded to this.
abstract final class AppTapTarget {
  static const double min = 48;
}
