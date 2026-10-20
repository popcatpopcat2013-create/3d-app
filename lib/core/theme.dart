import 'package:flutter/material.dart';

/// Colors with a meaning that screens share.
class AppColors {
  AppColors._();

  static const seed = Color(0xFF4F6BED);
  static const keep = Color(0xFF2E9E6B);
  static const trash = Color(0xFFE5484D);
}

/// Light and dark themes. Change the look of the whole app here.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );
  }
}
