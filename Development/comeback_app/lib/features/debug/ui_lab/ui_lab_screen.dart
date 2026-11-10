import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/game_card.dart';

class UiLabScreen extends StatelessWidget {
  const UiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // S-13 V1: Rendered only when kDebugMode is true (handled in MainShell)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('UI Storyboard', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xl),

              // V3: Colours Section
              _SectionTitle('Colours (Tap to copy)'),
              _buildColorSwatches(context),
              const SizedBox(height: AppSpacing.xl),

              // V3: Typography Section
              _SectionTitle('Typography'),
              const Text('Display 48/w900', style: AppTextStyles.display),
              const Text('HUD 32/w700 Tabular', style: AppTextStyles.hud),
              const Text('Body 16/w400', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xl),

              // V3: Spacing Section
              _SectionTitle('Spacing'),
              _buildSpacingBar('xxs', AppSpacing.xxs),
              _buildSpacingBar('xs', AppSpacing.xs),
              _buildSpacingBar('sm', AppSpacing.sm),
              _buildSpacingBar('md', AppSpacing.md),
              _buildSpacingBar('lg', AppSpacing.lg),
              _buildSpacingBar('xl', AppSpacing.xl),
              const SizedBox(height: AppSpacing.xl),

              // V3: Radius Section
              _SectionTitle('Radius'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRadiusBox('Card (12)', AppRadius.card),
                  _buildRadiusBox('Sheet (16)', AppRadius.sheet),
                  _buildRadiusBox('Pill (999)', AppRadius.pill),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // V3: Components Section
              _SectionTitle('Components'),
              GameCard(
                title: 'GameCard Preview',
                description: 'Subtext goes here.',
                icon: Icons.gamepad,
                accentColor: AppColors.vibrantGreen,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'Primary Button',
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.xl),

              // V3: Forbidden Reminder
              _SectionTitle('Forbidden'),
              Text(
                '• No pure white (#FFFFFF)\n• No pure black (#000000)\n• No google_fonts\n• No glows > 15% opacity\n• No gradients',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.vibrantRed,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatches(BuildContext context) {
    // Map of our locked tokens to their names for display
    final colors = {
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
        // S-13 B3: Tap to copy hex
        final hex = '#${entry.value.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
        
        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hex));
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied $hex', style: AppTextStyles.body),
                duration: const Duration(seconds: 1),
                backgroundColor: AppColors.surface,
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
              Text(entry.key, style: AppTextStyles.body.copyWith(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpacingBar(String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 14)),
          ),
          Container(
            width: size,
            height: 16,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusBox(String label, double radius) {
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
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.hud.copyWith(color: AppColors.primary),
      ),
    );
  }
}