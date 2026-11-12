import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/app_tokens.dart';

enum ComebakChipVariant { normal, active, neon }

class ComebakChip extends StatelessWidget {
  final String text;
  final bool isActive;
  final ComebakChipVariant variant;

  const ComebakChip({
    super.key,
    required this.text,
    this.isActive = false,
    this.variant = ComebakChipVariant.normal,
  });

  ComebakChipVariant get _effective =>
      variant == ComebakChipVariant.normal && isActive
          ? ComebakChipVariant.active
          : variant;

  Color get _bgColor {
    switch (_effective) {
      case ComebakChipVariant.neon:
        return AppColors.neon.withValues(alpha: 0.10);
      case ComebakChipVariant.active:
        return AppColors.warning.withValues(alpha: 0.1);
      case ComebakChipVariant.normal:
        return AppColors.surfaceElevated;
    }
  }

  Color get _textColor {
    switch (_effective) {
      case ComebakChipVariant.neon:
        return AppColors.neon;
      case ComebakChipVariant.active:
        return AppColors.warning;
      case ComebakChipVariant.normal:
        return AppColors.textMuted;
    }
  }

  Color get _borderColor {
    switch (_effective) {
      case ComebakChipVariant.neon:
        return AppColors.neon.withValues(alpha: 0.8);
      case ComebakChipVariant.active:
        return AppColors.warning.withValues(alpha: 0.3);
      case ComebakChipVariant.normal:
        return AppColors.borderSubtle;
    }
  }

  List<BoxShadow> get _shadows {
    if (_effective != ComebakChipVariant.neon) return const [];
    return [
      BoxShadow(
        color: AppColors.neon.withValues(alpha: 0.25),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
        border: Border.all(color: _borderColor, width: _effective == ComebakChipVariant.neon ? 1.5 : 1),
        boxShadow: _shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_effective == ComebakChipVariant.neon) ...[
            Icon(LucideIcons.award, size: 14, color: _textColor),
            const SizedBox(width: AppSpacing.space4),
          ],
          Text(
            text,
            style: AppTextStyles.labelXSmall.copyWith(color: _textColor),
          ),
        ],
      ),
    );
  }
}
