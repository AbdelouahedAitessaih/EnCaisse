/// EnCaisse brand colors and design tokens.
/// Flat design: no gradients, no shadows. Teal + coral only.
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
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9A9A9A);
  static const Color border = Color(0xFFE5E5E5);
  static const Color deposit = Color(0xFF0F6E56);
  static const Color expense = Color(0xFFD85A30);
  static const Color error = Color(0xFFB42318);
  static const Color success = Color(0xFF0F6E56);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}
