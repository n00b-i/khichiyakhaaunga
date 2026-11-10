import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';

// [COMPONENT] Colour swatch grid. Tapping copies hex to clipboard.
// [TOKEN MAPPING] Swatch box uses AppRadius.card + AppColors.border.
// Labels use FossText xs / regular.
class ColoursSection extends StatelessWidget {
  const ColoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    // [DATA] Only locked tokens from UI_SYSTEM.md.
    final colors = <String, Color>{
      'Background': AppColors.background,
      'Surface': AppColors.surface,
      'Border': AppColors.border,
      'Text': AppColors.textPrimary,
      'Primary': AppColors.primary,
      'Red': AppColors.vibrantRed,
      'Orange': AppColors.vibrantOrange,
      'Yellow': AppColors.vibrantYellow,
      'Green': AppColors.vibrantGreen,
      'Blue': AppColors.vibrantBlue,
      'Purple': AppColors.vibrantPurple,
      'Pink': AppColors.vibrantPink,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: colors.entries.map((entry) {
        final hex = '#${entry.value.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hex));
            HapticFeedback.selectionClick();
            // [COMPONENT] showFossToast — inline confirmation via FossToaster at root.
            showFossToast(
              context,
              FossToast(
                title: Text('Copied $hex'),
                variant: FossToastVariant.success,
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              FossText(
                entry.key,
                size: FossTextSize.xs,
                weight: FossTextWeight.regular,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}