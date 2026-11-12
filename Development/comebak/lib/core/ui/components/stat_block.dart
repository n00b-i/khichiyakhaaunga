import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool? isPositiveDelta;

  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.isPositiveDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSpacing.space4),
        Text(value, style: AppTextStyles.hud),
        if (delta != null && isPositiveDelta != null) ...[
          const SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              Icon(
                isPositiveDelta! ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositiveDelta! ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.space4),
              Text(
                delta!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isPositiveDelta! ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
