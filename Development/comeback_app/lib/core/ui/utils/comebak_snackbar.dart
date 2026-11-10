import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

// [RULE 2.2.2] Left-aligned text, correct colors
void showComebakSnackBar(BuildContext context, String text, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.left,
        style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
      ),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.radiusMedium)),
    ),
  );
}
