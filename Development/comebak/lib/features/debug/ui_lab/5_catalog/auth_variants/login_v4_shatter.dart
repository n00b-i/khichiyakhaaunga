import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 4 — LOGIN] "SHATTER"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v4. Rotated stacked type, broken-rules motif.
// Copy: "PROVE / YOU CAME / BACK."
// Rotations are subtle (±1-2°) — not chaotic, just off-axis.
// ==============================================================================
class LoginV4Shatter extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV4Shatter({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ComebakLayout.spaceXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ComebakLayout.spaceXxl),

              // Broken-frame row — 6 red segments, alternating rotation
              Row(
                children: [
                  for (var i = 0; i < 6; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        right: ComebakLayout.spaceSm,
                      ),
                      child: Transform.rotate(
                        angle: (i.isEven ? 1 : -1) * 0.06 * math.pi,
                        child: Container(
                          width: 24,
                          height: 3,
                          color: ComebakColors.vibrantRed
                              .withOpacity(0.4 + i * 0.1),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: ComebakLayout.spaceLg),

              // Rotated stacked type
              Transform.rotate(
                angle: -0.02,
                child: Text(
                  'PROVE',
                  style: ComebakTypography.greeting.copyWith(
                    fontSize: 52,
                    height: 0.95,
                    color: ComebakColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Transform.rotate(
                angle: 0.03,
                child: Text(
                  'YOU CAME',
                  style: ComebakTypography.greeting.copyWith(
                    fontSize: 52,
                    height: 0.95,
                    color: ComebakColors.vibrantRed,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(20, 0),
                child: Text(
                  'BACK.',
                  style: ComebakTypography.greeting.copyWith(
                    fontSize: 52,
                    height: 0.95,
                    color: ComebakColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '60 seconds.\nthat is the whole ask.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: ComebakLayout.spaceLg),

              GoogleCta(
                label: 'SIGN IN',
                onPressed: onGoogleSignIn,
              ),

              const SizedBox(height: ComebakLayout.spaceMd),

              Text(
                'terms + privacy.',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
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