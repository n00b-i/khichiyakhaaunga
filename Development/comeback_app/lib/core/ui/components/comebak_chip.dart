import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class ComebakChip extends StatelessWidget {
  final String text;
  final bool isActive;

  const ComebakChip({super.key, required this.text, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? AppColors.warning.withValues(alpha: 0.1) : AppColors.surfaceElevated;
    final textColor = isActive ? AppColors.warning : AppColors.textMuted;
    final borderColor = isActive ? AppColors.warning.withValues(alpha: 0.3) : AppColors.borderSubtle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8, vertical: AppSpacing.space4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelXSmall.copyWith(color: textColor),
      ),
    );
  }
}
