import 'package:flutter/material.dart';
import 'app_tokens.dart';
export 'app_tokens.dart'; // [FIX] Re-export tokens so existing files compile

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvas,
      primaryColor: AppColors.primaryAccent,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.onPrimary,
        error: AppColors.danger,
        onError: AppColors.onPrimary,
        surface: AppColors.surfaceElevated,
        onSurface: AppColors.textPrimary,
      ),
      dividerColor: AppColors.borderSubtle,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusMedium)),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
    );
  }
}
