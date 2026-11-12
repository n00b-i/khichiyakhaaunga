import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../2_atoms/comebak_google_mark.dart';

// ==============================================================================
// [LOCAL ATOM] _GoogleCta
// ------------------------------------------------------------------------------
// PURPOSE: Full-width Google sign-in CTA with the 4-color G mark.
// WHY LOCAL: ComebakButton does not expose `leading` or `expand`. Rather than
//   modify the production atom (risk), this replicates its exact visual spec
//   (surfaceElevated bg / buttonHeight / radiusMd / titleMedium w700).
// DELETE WHEN: ComebakButton gains `leading` + `expand` params. Then replace
//   all usages with ComebakButton directly.
// ==============================================================================
class GoogleCta extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const GoogleCta({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComebakLayout.buttonHeight,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: ComebakColors.surface,
          foregroundColor: ComebakColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const ComebakGoogleMark(size: 18),
            const SizedBox(width: ComebakLayout.spaceMd),
            Text(
              label,
              style: ComebakTypography.titleMedium.copyWith(
                color: ComebakColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}