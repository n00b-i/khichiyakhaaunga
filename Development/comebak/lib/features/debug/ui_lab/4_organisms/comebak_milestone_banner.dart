import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';

// ==============================================================================
// [ORGANISM] ComebakMilestoneBanner
// ------------------------------------------------------------------------------
// PURPOSE: The motivational banner shown at the bottom of the Home Screen.
// ARCHITECTURE: Combines an icon (Trophy), text, and a CTA button.
// DRY PRINCIPLE: Purely presentational. Receives a callback for the CTA action.
// ==============================================================================
class ComebakMilestoneBanner extends StatelessWidget {
  final VoidCallback onViewProgress;

  const ComebakMilestoneBanner({
    super.key,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
        border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
      ),
      child: Row(
        children: [
          // ====================================================================
          // [ICON] The Trophy
          // ====================================================================
          Container(
            padding: const EdgeInsets.all(ComebakLayout.spaceSm),
            decoration: BoxDecoration(
              color: ComebakColors.neonYellow.withValues(alpha: ComebakLayout.opacityIconBg),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.trophy, 
              color: ComebakColors.neonYellow, 
              size: ComebakLayout.spaceXl,
            ),
          ),
          const SizedBox(width: ComebakLayout.spaceLg),

          // ====================================================================
          // [TEXT SECTION]
          // ====================================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ComebakCopy.milestoneTitle, 
                  style: ComebakTypography.titleMedium
                ),
                const SizedBox(height: ComebakLayout.spaceXs),
                Text(
                  ComebakCopy.milestoneSubtitle, 
                  style: ComebakTypography.bodyMedium
                ),
              ],
            ),
          ),
          const SizedBox(width: ComebakLayout.spaceMd),

          // ====================================================================
          // [CTA BUTTON]
          // ====================================================================
          TextButton(
            onPressed: onViewProgress,
            style: TextButton.styleFrom(
              backgroundColor: ComebakColors.neonGreen,
              foregroundColor: ComebakColors.canvas,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: ComebakLayout.spaceMd,
                vertical: ComebakLayout.spaceSm,
              ),
            ),
            child: Text(
              ComebakCopy.milestoneCta,
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.canvas,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}