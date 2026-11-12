import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 6 — LOGIN] "TICKER"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v6. Session-expiry panic framing.
// Copy: "SESSION / EXPIRES / IN 59s." + "the flame burns down fast."
// ==============================================================================
class LoginV6Ticker extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV6Ticker({super.key, required this.onGoogleSignIn});

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

              // Top row — LIVE badge + STREAK 0
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ComebakLayout.spaceSm,
                      vertical: ComebakLayout.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: ComebakColors.vibrantRed.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(ComebakLayout.radiusSm),
                      border: Border.all(
                        color: ComebakColors.vibrantRed.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '◉ LIVE',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.vibrantRed,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'STREAK 0',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Stacked headline
              Text(
                'SESSION',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'EXPIRES',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 48,
                  height: 1.0,
                  color: ComebakColors.textPrimary,
                ),
              ),
              Text(
                'IN 59s.',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 48,
                  height: 1.0,
                  color: ComebakColors.vibrantRed,
                ),
              ),

              const SizedBox(height: ComebakLayout.spaceLg),

              Text(
                'the flame burns down fast.\nlight it again.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              GoogleCta(
                label: 'SIGN IN NOW',
                onPressed: onGoogleSignIn,
              ),

              const SizedBox(height: ComebakLayout.spaceMd),

              Text(
                'terms · privacy · one tap.',
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