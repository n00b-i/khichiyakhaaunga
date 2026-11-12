import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [WIDGET] ComebakRuleHook
// ------------------------------------------------------------------------------
// PURPOSE: The 1–2 word ALL-CAPS hook ("ALWAYS REMEMBER", "LISTEN", "NOW").
// VISUAL: 12/w600, tracking +2.4, textSecondary. Small neonGreen underline
//   accent below — 24px wide, 2px tall. The underline is what makes the hook
//   feel like a label, not a paragraph.
// ANIMATION CONTRACT: `opacity` 0..1 passed in by orchestrator. This widget
//   does no timing. Fade-in of ~200ms happens orchestrator-side.
// TYPOGRAPHY: Uses ComebakTypography.labelSmall but overrides color + tracking.
//   The override is intentional — labelSmall's default color is neonGreen,
//   which we DON'T want here (neon reserved for the underline accent).
// ==============================================================================
class ComebakRuleHook extends StatelessWidget {
  final String hook;
  final double opacity;

  const ComebakRuleHook({
    super.key,
    required this.hook,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hook.toUpperCase(),
            style: ComebakTypography.labelSmall.copyWith(
              color: ComebakColors.textSecondary,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ComebakLayout.spaceSm),
          Container(
            width: 24,
            height: 2,
            color: ComebakColors.neonGreen,
          ),
        ],
      ),
    );
  }
}