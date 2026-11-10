import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';

// [COMPONENT] Spacing scale + radius scale visual reference.
// [TOKEN MAPPING] Bar fill uses AppColors.primary. Radius boxes use AppColors.surface fill + primary border.
class SpacingSection extends StatelessWidget {
  const SpacingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [TOKEN MAPPING] Spacing scale from AppSpacing.
        _bar(context, 'xxs', AppSpacing.xxs),
        _bar(context, 'xs', AppSpacing.xs),
        _bar(context, 'sm', AppSpacing.sm),
        _bar(context, 'md', AppSpacing.md),
        _bar(context, 'lg', AppSpacing.lg),
        _bar(context, 'xl', AppSpacing.xl),
        const SizedBox(height: AppSpacing.md),
        // [TOKEN MAPPING] Radius scale from AppRadius.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _radius(context, 'Card (12)', AppRadius.card),
            _radius(context, 'Sheet (16)', AppRadius.sheet),
            _radius(context, 'Pill (999)', AppRadius.pill),
          ],
        ),
      ],
    );
  }

  Widget _bar(BuildContext context, String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: FossText(label, size: FossTextSize.sm),
          ),
          Container(width: size, height: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _radius(BuildContext context, String label, double radius) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        FossText(label, size: FossTextSize.xs),
      ],
    );
  }
}