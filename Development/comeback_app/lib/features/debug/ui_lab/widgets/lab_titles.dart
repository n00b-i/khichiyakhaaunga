import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';

// [COMPONENT] Section title — top-level heading for a section.
// [TOKEN MAPPING] size -> xl, weight -> semibold, color -> primary (Groww Green).
class LabSectionTitle extends StatelessWidget {
  final String title;
  const LabSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.lg),
      child: FossText(
        title,
        size: FossTextSize.lg,
        weight: FossTextWeight.semibold,
        color: FossTextColor.primary,
      ),
    );
  }
}

// [COMPONENT] Sub-title — used inside a section to label a component group.
// [TOKEN MAPPING] size -> sm, weight -> medium, color -> mutedForeground.
class LabSubTitle extends StatelessWidget {
  final String title;
  const LabSubTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: FossText(
        title,
        size: FossTextSize.sm,
        weight: FossTextWeight.medium,
        color: FossTextColor.mutedForeground,
      ),
    );
  }
}