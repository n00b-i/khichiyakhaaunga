import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '_google_cta.dart';

// ==============================================================================
// [VARIANT 2 — LOGIN] "TERMINAL"
// ------------------------------------------------------------------------------
// Concept: Continuation of splash_v2. Monospace auth prompt + cursor.
// Copy: "> authenticate" / "no forms. no passwords. no names. just play."
// ==============================================================================
class LoginV2Terminal extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  const LoginV2Terminal({super.key, required this.onGoogleSignIn});

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
              Text(
                'comebak.session',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceLg),
              Text(
                r'> authenticate',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 32,
                  color: ComebakColors.neonGreen,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Container(
                width: 10,
                height: 24,
                color: ComebakColors.neonGreen,
              ),
              const Spacer(),
              Text(
                'no forms.\nno passwords.\nno names.\njust play.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                  fontFamily: 'monospace',
                  height: 1.8,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceXl),
              GoogleCta(
                label: 'RUN: google_auth',
                onPressed: onGoogleSignIn,
              ),
              const SizedBox(height: ComebakLayout.spaceMd),
              Text(
                'by continuing you accept terms + privacy.',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}