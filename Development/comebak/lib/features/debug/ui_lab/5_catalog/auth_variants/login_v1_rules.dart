import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'layers/comebak_clay_logo.dart';
import 'layers/comebak_wordmark.dart';
import '_google_cta.dart';

class LoginV1Rules extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final bool isBlocked;
  final bool isLoading;

  const LoginV1Rules({
    super.key,
    required this.onGoogleSignIn,
    this.isBlocked = false,
    this.isLoading = false,
  });

  @override
  State<LoginV1Rules> createState() => _LoginV1RulesState();
}

class _LoginV1RulesState extends State<LoginV1Rules>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    ComebakColors.neonGreen.withValues(alpha: 0.15),
                    ComebakColors.canvas,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComebakLayout.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Center(
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, _) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ComebakClayLogo(
                                pose: 4,
                                time: _ctrl.value * 4,
                                enableSparks: false,
                              ),
                              const SizedBox(width: 12),
                              ComebakWordmark(
                                charCount: 7,
                                brightness: 1.0,
                                time: _ctrl.value * 4,
                                enableSparks: false,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Blocked banner
                  if (widget.isBlocked) ...[
                    Container(
                      padding: const EdgeInsets.all(ComebakLayout.spaceMd),
                      decoration: BoxDecoration(
                        color: ComebakColors.vibrantRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ComebakLayout.radiusMd,
                        ),
                        border: Border.all(
                          color: ComebakColors.vibrantRed.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.block,
                            color: ComebakColors.vibrantRed,
                            size: ComebakLayout.spaceXl,
                          ),
                          const SizedBox(width: ComebakLayout.spaceSm),
                          Expanded(
                            child: Text(
                              'This account is not available. Please contact support.',
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.vibrantRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ComebakLayout.spaceLg),
                  ],
                  // Copy
                  Text(
                    'TIME TO COMEBAK!',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.neonGreen,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),
                  Text(
                    'Every Day\nJust 60 seconds',
                    style: ComebakTypography.greeting.copyWith(
                      fontSize: 44,
                      height: 1.2,
                      color: ComebakColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceMd),
                  Text(
                    'Nobody is coming to SAVE you, take your own responsibility!',
                    style: ComebakTypography.bodyMedium.copyWith(
                      color: ComebakColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                  GoogleCta(
                    onPressed: widget.onGoogleSignIn,
                    label: 'Login with Google',
                    isLoading: widget.isLoading,
                  ),
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
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
