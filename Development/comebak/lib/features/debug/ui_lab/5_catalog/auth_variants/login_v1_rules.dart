import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 1 — LOGIN] "THE RULES"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v1. Left-aligned manifesto, single CTA.
// Copy: "you are not your streak / xp / number."
// ==============================================================================
class LoginV1Rules extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV1Rules({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ComebakLayout.spaceXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'THE RULES',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.neonGreen,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceLg),
              Text(
                'you are not\nyour streak.',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 44,
                  height: 1.0,
                  color: ComebakColors.textPrimary,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceMd),
              Text(
                'you are not your xp.\nyou are not the number.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              GoogleCta(onPressed: onGoogleSignIn),
              const SizedBox(height: ComebakLayout.spaceMd),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: ComebakTypography.labelSmall.copyWith(
                    color: ComebakColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}