import 'package:flutter/material.dart';
import 'tokens/app_colors.dart';

export 'tokens/app_colors.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_radius.dart';
export 'tokens/app_sizes.dart';
export 'tokens/app_text_styles.dart';
export 'tokens/app_motion.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onPrimary: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      dividerColor: AppColors.border,
      useMaterial3: true,
    );
  }
}
