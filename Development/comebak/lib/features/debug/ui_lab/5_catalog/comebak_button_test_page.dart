import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../2_atoms/comebak_button.dart';

// ==============================================================================
// [FLOW] ComebakButtonTestPage
// ------------------------------------------------------------------------------
// PURPOSE: A temporary test page to visually compare button layouts.
// ==============================================================================
class ComebakButtonTestPage extends StatelessWidget {
  const ComebakButtonTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      appBar: AppBar(
        backgroundColor: ComebakColors.surface,
        title: Text('Button Layout Test', style: ComebakTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ComebakLayout.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('EDIT NAME SHEET (Valid)'),
            _buildEditNameSheetValid(),
            const SizedBox(height: ComebakLayout.spaceXl),
            _buildSectionHeader('EDIT NAME SHEET (Invalid)'),
            _buildEditNameSheetInvalid(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            _buildSectionHeader('LOGOUT SHEET (Logout White, Cancel Red)'),
            _buildLogoutSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ComebakLayout.spaceMd),
      child: Text(text, style: ComebakTypography.sectionTitle),
    );
  }

  Widget _buildEditNameSheetValid() {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceXl),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
        border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ComebakCopy.editNameTitle, style: ComebakTypography.titleLarge),
          const SizedBox(height: ComebakLayout.spaceLg),
          Row(
            children: [
              // [CANCEL ON LEFT] White text
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnCancel,
                  variant: ComebakButtonVariant.primary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceMd),
              // [SAVE ON RIGHT] Green text
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnSave,
                  variant: ComebakButtonVariant.success,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditNameSheetInvalid() {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceXl),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
        border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ComebakCopy.editNameTitle, style: ComebakTypography.titleLarge),
          const SizedBox(height: ComebakLayout.spaceLg),
          Row(
            children: [
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnCancel,
                  variant: ComebakButtonVariant.primary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceMd),
              // [SAVE ON RIGHT] Muted Green text
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnSave,
                  variant: ComebakButtonVariant.successMuted,
                  onPressed: () {}, // Disabled
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSheet() {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceXl),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
        border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ComebakCopy.logoutTitle, style: ComebakTypography.titleLarge),
          const SizedBox(height: ComebakLayout.spaceSm),
          RichText(text: TextSpan(style: ComebakTypography.bodyMedium, children: [TextSpan(text: ComebakCopy.logoutSubtitlePart1), TextSpan(text: ComebakCopy.logoutSubtitleHighlight, style: ComebakTypography.bodyMedium.copyWith(color: ComebakColors.neonGreen, fontWeight: FontWeight.w700)), TextSpan(text: ComebakCopy.logoutSubtitlePart2)]),),
          const SizedBox(height: ComebakLayout.spaceXl),
          Row(
            children: [
              // [LOGOUT ON LEFT] White text
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnLogout,
                  variant: ComebakButtonVariant.primary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceMd),
              // [CANCEL ON RIGHT] Red text
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnCancel,
                  variant: ComebakButtonVariant.danger,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}