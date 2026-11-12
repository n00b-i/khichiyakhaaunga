import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 3 — LOGIN] "BURN"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v3. Three-line poetic stack, centered.
// Copy: "One minute. / One flame. / One reason."
// Uses flame token for the icon glow — matches Home streak card palette.
// ==============================================================================
class LoginV3Burn extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV3Burn({super.key, required this.onGoogleSignIn});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Glowing flame icon — same palette as Home streak card
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ComebakColors.flameOrange.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: ComebakColors.flameOrange.withOpacity(0.4),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: ComebakColors.flameOrange,
                  size: 30,
                ),
              ),

              const Spacer(),

              // Three-line poetic stack
              Text(
                'One minute.',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 34,
                  color: ComebakColors.textPrimary,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Text(
                'One flame.',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 34,
                  color: ComebakColors.flameOrange,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Text(
                'One reason.',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 34,
                  color: ComebakColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              GoogleCta(onPressed: onGoogleSignIn),

              const SizedBox(height: ComebakLayout.spaceMd),

              Text(
                'come back.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  fontStyle: FontStyle.italic,
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