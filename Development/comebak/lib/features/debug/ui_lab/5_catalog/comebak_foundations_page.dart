import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';

// ==============================================================================
// [FLOW] ComebakFoundationsPage
// ------------------------------------------------------------------------------
// PURPOSE: The single source of truth for the app's visual language.
// ARCHITECTURE: This page renders every color, text style, spacing token,
// radius token, and gradient we have defined. It allows developers and
// designers to visually verify the design system before applying it to
// production screens.
// ==============================================================================
class ComebakFoundationsPage extends StatelessWidget {
  const ComebakFoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      appBar: AppBar(
        backgroundColor: ComebakColors.surface,
        title: Text(
          ComebakCopy.catalogFoundationsPage,
          style: ComebakTypography.titleLarge,
        ),
        iconTheme: const IconThemeData(color: ComebakColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ComebakLayout.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================================
            // [SECTION 1: COLORS]
            // ==================================================================
            _buildSectionHeader('COLOR PALETTE'),
            _buildColorPalette(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            // ==================================================================
            // [SECTION 2: TYPOGRAPHY]
            // ==================================================================
            _buildSectionHeader('TYPOGRAPHY SCALE'),
            _buildTypographyShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            // ==================================================================
            // [SECTION 3: TYPOGRAPHY COLORS]
            // ==================================================================
            _buildSectionHeader('TYPOGRAPHY COLORS'),
            _buildTypographyColorsShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            // ==================================================================
            // [SECTION 4: ICONS & COLORS]
            // ==================================================================
            _buildSectionHeader('ICONS & BRAND COLORS'),
            _buildIconShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            // ==================================================================
            // [SECTION 5: GRADIENTS]
            // ==================================================================
            _buildSectionHeader('DESIGN GRADIENTS'),
            _buildGradientShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            // ==================================================================
            // [SECTION 6: SPACING & RADII]
            // ==================================================================
            _buildSectionHeader('SPACING SCALE'),
            _buildSpacingShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),

            _buildSectionHeader('BORDER RADII'),
            _buildRadiusShowcase(),
            const SizedBox(height: ComebakLayout.spaceXxl),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // [HELPERS]
  // ==========================================================================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ComebakLayout.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ComebakTypography.sectionTitle),
          const SizedBox(height: ComebakLayout.spaceXs),
          Container(
            height: ComebakLayout.borderThin,
            width: ComebakLayout.spaceXxl,
            color: ComebakColors.neonGreen,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // [1. COLOR PALETTE]
  // ==========================================================================
  Widget _buildColorPalette() {
    return Wrap(
      spacing: ComebakLayout.spaceLg,
      runSpacing: ComebakLayout.spaceLg,
      children: [
        _buildColorSwatch('Canvas', ComebakColors.canvas),
        _buildColorSwatch('Surface', ComebakColors.surface),
        _buildColorSwatch('Elevated', ComebakColors.surfaceElevated),
        _buildColorSwatch('Border', ComebakColors.border),
        _buildColorSwatch('Text Prim', ComebakColors.textPrimary),
        _buildColorSwatch('Text Sec', ComebakColors.textSecondary),
        _buildColorSwatch('Neon Green', ComebakColors.neonGreen),
        _buildColorSwatch('Neon Orange', ComebakColors.neonOrange),
        _buildColorSwatch('Neon Purple', ComebakColors.neonPurple),
        _buildColorSwatch('Neon Blue', ComebakColors.neonBlue),
        _buildColorSwatch('Neon Yellow', ComebakColors.neonYellow),
        _buildColorSwatch('Vibrant Red', ComebakColors.vibrantRed),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
            border: Border.all(
              color: ComebakColors.border,
              width: ComebakLayout.borderThin,
            ),
          ),
        ),
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(
          name,
          style: ComebakTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [2. TYPOGRAPHY SCALE]
  // ==========================================================================
  Widget _buildTypographyShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextSample('Brand (w800, 22)', ComebakTypography.brand),
        _buildTextSample('Greeting (w800, 36)', ComebakTypography.greeting),
        _buildTextSample(
          'Title Large (w700, 18)',
          ComebakTypography.titleLarge,
        ),
        _buildTextSample(
          'Title Medium (w700, 16)',
          ComebakTypography.titleMedium,
        ),
        _buildTextSample(
          'Body Medium (w600, 13)',
          ComebakTypography.bodyMedium,
        ),
        _buildTextSample(
          'Label Small (w600, 12)',
          ComebakTypography.labelSmall,
        ),
      ],
    );
  }

  Widget _buildTextSample(String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ComebakLayout.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ComebakTypography.labelSmall.copyWith(
              color: ComebakColors.neonGreen,
            ),
          ),
          const SizedBox(height: ComebakLayout.spaceXs),
          Text('The quick brown fox jumps over the lazy dog.', style: style),
          const SizedBox(height: ComebakLayout.spaceXs),
          Divider(
            color: ComebakColors.border,
            height: ComebakLayout.borderThin,
            thickness: ComebakLayout.borderThin,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // [3. TYPOGRAPHY COLORS]
  // ==========================================================================
  Widget _buildTypographyColorsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorTextSample('Text Primary', ComebakColors.textPrimary),
        _buildColorTextSample('Text Secondary', ComebakColors.textSecondary),
        _buildColorTextSample(
          'Neon Green (Success/Brand)',
          ComebakColors.neonGreen,
        ),
        _buildColorTextSample(
          'Vibrant Red (Danger/Error)',
          ComebakColors.vibrantRed,
        ),
        _buildColorTextSample(
          'Neon Orange (Warning/Streak)',
          ComebakColors.neonOrange,
        ),
      ],
    );
  }

  Widget _buildColorTextSample(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ComebakLayout.spaceSm),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Comebak UI',
              style: ComebakTypography.titleMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // [4. ICONS & COLORS]
  // ==========================================================================
  Widget _buildIconShowcase() {
    return Wrap(
      spacing: ComebakLayout.spaceXl,
      runSpacing: ComebakLayout.spaceLg,
      children: [
        _buildIconSample(
          'Neon Green',
          LucideIcons.zap,
          ComebakColors.neonGreen,
        ),
        _buildIconSample(
          'Neon Orange',
          LucideIcons.flame,
          ComebakColors.neonOrange,
        ),
        _buildIconSample(
          'Neon Yellow',
          LucideIcons.trophy,
          ComebakColors.neonYellow,
        ),
        _buildIconSample(
          'Neon Blue',
          LucideIcons.house,
          ComebakColors.neonBlue,
        ),
        _buildIconSample(
          'Text Primary',
          LucideIcons.user,
          ComebakColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildIconSample(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ComebakLayout.spaceLg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: ComebakLayout.opacityIconBg),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: ComebakLayout.spaceXl),
        ),
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [5. GRADIENTS]
  // ==========================================================================
  Widget _buildGradientShowcase() {
    return Row(
      children: [
        // [GRADIENT 1] The 3D Icon Gradient
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ComebakColors.neonGreen.withValues(
                        alpha: ComebakLayout.opacityGradientStart,
                      ),
                      ComebakColors.neonGreen.withValues(
                        alpha: ComebakLayout.opacityGradientEnd,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.plus,
                    color: ComebakColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Text('3D Icon Fill', style: ComebakTypography.labelSmall),
            ],
          ),
        ),
        const SizedBox(width: ComebakLayout.spaceLg),

        // [GRADIENT 2] The Card Border Gradient
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ComebakColors.neonGreen.withValues(
                        alpha: ComebakLayout.opacityBorderAccent,
                      ),
                      ComebakColors.canvas,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                  border: Border.all(
                    color: ComebakColors.border,
                    width: ComebakLayout.borderThin,
                  ),
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Text('Card Border Fade', style: ComebakTypography.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [6. SPACING & RADII]
  // ==========================================================================
  Widget _buildSpacingShowcase() {
    return Column(
      children: [
        _buildSpacingBlock('spaceXs (4)', ComebakLayout.spaceXs),
        _buildSpacingBlock('spaceSm (8)', ComebakLayout.spaceSm),
        _buildSpacingBlock('spaceMd (12)', ComebakLayout.spaceMd),
        _buildSpacingBlock('spaceLg (16)', ComebakLayout.spaceLg),
        _buildSpacingBlock('spaceXl (24)', ComebakLayout.spaceXl),
        _buildSpacingBlock('spaceXxl (32)', ComebakLayout.spaceXxl),
      ],
    );
  }

  Widget _buildSpacingBlock(String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ComebakLayout.spaceSm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: ComebakTypography.labelSmall),
          ),
          Container(width: size, height: 20, color: ComebakColors.neonGreen),
        ],
      ),
    );
  }

  Widget _buildRadiusShowcase() {
    return Wrap(
      spacing: ComebakLayout.spaceLg,
      runSpacing: ComebakLayout.spaceLg,
      children: [
        _buildRadiusBox('radiusSm (6)', ComebakLayout.radiusSm),
        _buildRadiusBox('radiusMd (10)', ComebakLayout.radiusMd),
        _buildRadiusBox('radiusLg (16)', ComebakLayout.radiusLg),
        _buildRadiusBox('radiusXl (20)', ComebakLayout.radiusXl),
      ],
    );
  }

  Widget _buildRadiusBox(String label, double radius) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ComebakColors.surfaceElevated,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: ComebakColors.neonGreen,
              width: ComebakLayout.borderThin,
            ),
          ),
        ),
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(label, style: ComebakTypography.labelSmall),
      ],
    );
  }
}
