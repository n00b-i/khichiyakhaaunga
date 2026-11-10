import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/lab_titles.dart';
import 'sections/colours_section.dart';
import 'sections/spacing_section.dart';
import 'sections/inputs_section.dart';
import 'sections/feedback_section.dart';
import 'sections/overlays_section.dart';
import 'sections/layout_section.dart';

// [ISSUE: fossui-adaptation] UILab is the contract registry for fossui components.
// Hybrid boundary: game-arena widgets (BubblePainter, GameHud, CustomNumpad,
// FloatingNavBar, GameCard) are NOT migrated. They stay custom.
class UiLabScreen extends StatelessWidget {
  const UiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FossText(
                'UI Storyboard',
                size: FossTextSize.xl2,
                weight: FossTextWeight.bold,
              ),
              const SizedBox(height: AppSpacing.xs),
              const FossText(
                'fossui for chrome, custom for game arena.',
                size: FossTextSize.sm,
                color: FossTextColor.mutedForeground,
              ),
              const LabSectionTitle('Colours'),
              const ColoursSection(),
              const LabSectionTitle('Spacing & Radius'),
              const SpacingSection(),
              const LabSectionTitle('Inputs'),
              const InputsSection(),
              const LabSectionTitle('Feedback'),
              const FeedbackSection(),
              const LabSectionTitle('Overlays'),
              const OverlaysSection(),
              const LabSectionTitle('Layout'),
              const LayoutSection(),
              const SizedBox(height: AppSpacing.xl * 3),
            ],
          ),
        ),
      ),
    );
  }
}