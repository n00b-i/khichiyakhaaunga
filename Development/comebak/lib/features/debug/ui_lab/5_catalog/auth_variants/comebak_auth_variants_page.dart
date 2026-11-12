import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'splash_v1_rules.dart';
import 'splash_v2_terminal.dart';
import 'splash_v3_burn.dart';
import 'splash_v4_shatter.dart';
import 'splash_v5_ink.dart';
import 'splash_v6_ticker.dart';
import 'login_v1_rules.dart';
import 'login_v2_terminal.dart';
import 'login_v3_burn.dart';
import 'login_v4_shatter.dart';
import 'login_v5_ink.dart';
import 'login_v6_ticker.dart';

// ==============================================================================
// [INDEX] ComebakAuthVariantsPage
// ------------------------------------------------------------------------------
// PURPOSE: Preview gallery for 6 splash+login flow variants.
// ENTRY: Tap variant card → splash plays → navigates to its login screen.
// ==============================================================================
class ComebakAuthVariantsPage extends StatelessWidget {
  const ComebakAuthVariantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ComebakLayout.spaceXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUTH VARIANTS',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 28,
                  color: ComebakColors.textPrimary,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceSm),
              Text(
                '6 splash → login flows. Tap to preview.',
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceXxl),

              _variantCard(
                context,
                '01',
                'THE RULES',
                'Wireframe clay → fill. "You do not chase the streak."',
                ComebakColors.neonGreen,
                _buildSplashV1,
                _buildLoginV1,
              ),
              _variantCard(
                context,
                '02',
                'TERMINAL',
                'Boot-sequence typewriter. Monospace soul.',
                ComebakColors.neonGreen,
                _buildSplashV2,
                _buildLoginV2,
              ),
              _variantCard(
                context,
                '03',
                'BURN',
                'Single flame grows. "Let it burn." Warm minimalism.',
                ComebakColors.flameOrange,
                _buildSplashV3,
                _buildLoginV3,
              ),
              _variantCard(
                context,
                '04',
                'SHATTER',
                'Logo explodes into 24 particles → reforms.',
                ComebakColors.vibrantRed,
                _buildSplashV4,
                _buildLoginV4,
              ),
              _variantCard(
                context,
                '05',
                'INK',
                'Brush-stroke spiral on dark. Zen calligraphy.',
                ComebakColors.textPrimary,
                _buildSplashV5,
                _buildLoginV5,
              ),
              _variantCard(
                context,
                '06',
                'TICKER',
                'Streak counter ticks up. Panic. "Expires in 59s."',
                ComebakColors.neonYellow,
                _buildSplashV6,
                _buildLoginV6,
              ),

              const SizedBox(height: ComebakLayout.spaceXxl),
            ],
          ),
        ),
      ),
    );
  }

  // Splash builders — each receives the onComplete callback
  Widget _buildSplashV1(VoidCallback onDone) =>
      SplashV1Rules(onComplete: onDone);
  Widget _buildSplashV2(VoidCallback onDone) =>
      SplashV2Terminal(onComplete: onDone);
  Widget _buildSplashV3(VoidCallback onDone) =>
      SplashV3Burn(onComplete: onDone);
  Widget _buildSplashV4(VoidCallback onDone) =>
      SplashV4Shatter(onComplete: onDone);
  Widget _buildSplashV5(VoidCallback onDone) =>
      SplashV5Ink(onComplete: onDone);
  Widget _buildSplashV6(VoidCallback onDone) =>
      SplashV6Ticker(onComplete: onDone);

  // Login builders — Google sign-in is a no-op in UI Lab (no real auth yet)
  Widget _buildLoginV1(VoidCallback onDone) =>
      LoginV1Rules(onGoogleSignIn: onDone);
  Widget _buildLoginV2(VoidCallback onDone) =>
      LoginV2Terminal(onGoogleSignIn: onDone);
  Widget _buildLoginV3(VoidCallback onDone) =>
      LoginV3Burn(onGoogleSignIn: onDone);
  Widget _buildLoginV4(VoidCallback onDone) =>
      LoginV4Shatter(onGoogleSignIn: onDone);
  Widget _buildLoginV5(VoidCallback onDone) =>
      LoginV5Ink(onGoogleSignIn: onDone);
  Widget _buildLoginV6(VoidCallback onDone) =>
      LoginV6Ticker(onGoogleSignIn: onDone);

  // ============================================================================
  // [FLOW RUNNER] Splash → onComplete → push Login in same stack
  // ============================================================================
  void _runFlow(
    BuildContext context,
    Widget Function(VoidCallback) buildSplash,
    Widget Function(VoidCallback) buildLogin,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (splashCtx) => buildSplash(() {
          // Splash done → push login on top of splash route
          Navigator.of(splashCtx).push(
            MaterialPageRoute(builder: (_) => buildLogin(() {})),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // [CARD] One variant card
  // ============================================================================
  Widget _variantCard(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    Color accent,
    Widget Function(VoidCallback) splash,
    Widget Function(VoidCallback) login,
  ) {
    return GestureDetector(
      onTap: () => _runFlow(context, splash, login),
      child: Container(
        margin: const EdgeInsets.only(bottom: ComebakLayout.spaceMd),
        padding: const EdgeInsets.all(ComebakLayout.spaceLg),
        decoration: BoxDecoration(
          color: ComebakColors.surface,
          borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
          border: Border.all(color: ComebakColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                border: Border.all(color: accent.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  id,
                  style: ComebakTypography.titleMedium.copyWith(
                    color: accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: ComebakLayout.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ComebakTypography.titleMedium.copyWith(
                      color: ComebakColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXs),
                  Text(
                    subtitle,
                    style: ComebakTypography.bodyMedium.copyWith(
                      color: ComebakColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accent),
          ],
        ),
      ),
    );
  }
}