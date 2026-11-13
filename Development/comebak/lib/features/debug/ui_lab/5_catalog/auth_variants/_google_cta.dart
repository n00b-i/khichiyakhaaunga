import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../2_atoms/comebak_google_mark.dart';

// ==============================================================================
// [LOCAL ATOM] GoogleCta
// ------------------------------------------------------------------------------
// PURPOSE: Full-width Google sign-in CTA with the 4-color G mark.
// UPDATED: Added `isLoading` to show a spinner during authentication.
// ==============================================================================
class GoogleCta extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const GoogleCta({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComebakLayout.buttonHeight,
      width: double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: ComebakColors.surface,
          foregroundColor: ComebakColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: ComebakLayout.spaceXl,
                height: ComebakLayout.spaceXl,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ComebakColors.neonGreen,
                ),
              )
            : Row(
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
