import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [ATOM] ComebakButton
// ------------------------------------------------------------------------------
// PURPOSE: The unified button for the entire app.
// ARCHITECTURE: All buttons share the EXACT same regular background color 
// (surfaceElevated). The only visual difference is the text color based on 
// the action's intent (Primary, Success, Danger).
// ==============================================================================
enum ComebakButtonVariant {
  primary,      // White text (Cancel)
  success,      // Neon Green text (Valid Save)
  successMuted, // Muted Green text (Invalid Save)
  danger,       // Red text (Logout)
}

class ComebakButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ComebakButtonVariant variant;

  const ComebakButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ComebakButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    // [STYLING] Determine text color based on variant
    Color fgColor;

    switch (variant) {
      case ComebakButtonVariant.primary:
        fgColor = ComebakColors.textPrimary;
        break;
      case ComebakButtonVariant.success:
        fgColor = ComebakColors.neonGreen;
        break;
      case ComebakButtonVariant.successMuted:
        fgColor = ComebakColors.mutedGreen;
        break;
      case ComebakButtonVariant.danger:
        fgColor = ComebakColors.vibrantRed;
        break;
    }

    return SizedBox(
      height: ComebakLayout.buttonHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          // [DESIGN] ALL buttons share the regular background.
          backgroundColor: ComebakColors.surfaceElevated,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
          ),
        ),
        child: Text(
          text,
          style: ComebakTypography.titleMedium.copyWith(
            color: fgColor,
          ),
        ),
      ),
    );
  }
}