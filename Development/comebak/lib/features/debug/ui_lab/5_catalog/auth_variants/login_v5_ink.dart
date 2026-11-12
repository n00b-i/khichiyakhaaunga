import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 5 — LOGIN] "INK"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v5. Centered zen typography, thin divider.
// Copy: "come back / to the flame you forgot to tend."
// Note: variant "ghost" does not exist on ComebakButton — using primary.
//       The zen minimalism carries in the typography, not the button color.
// ==============================================================================
class LoginV5Ink extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV5Ink({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ComebakLayout.spaceXl * 1.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              Text(
                'come back',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 30,
                  color: ComebakColors.textPrimary,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: ComebakLayout.spaceLg),

              // Thin hairline divider — zen break
              Container(
                width: 32,
                height: 2,
                color: ComebakColors.textSecondary.withOpacity(0.5),
              ),

              const SizedBox(height: ComebakLayout.spaceLg),

              Text(
                'to the flame you\nforgot to tend.',
                textAlign: TextAlign.center,
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  height: 1.8,
                  letterSpacing: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              GoogleCta(
                label: 'Enter',
                onPressed: onGoogleSignIn,
              ),

              const SizedBox(height: ComebakLayout.spaceMd),

              Text(
                'terms · privacy',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  letterSpacing: 2,
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