import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 6 — SPLASH] "TICKER"
// ------------------------------------------------------------------------------
// Concept: Anxiety. Counter ticks from 000 to 100, then flips to READY.
// Copy: "STREAK / XP" labels + "READY / come back." reveal.
// Runtime: 2.4s. Skip always visible.
// ==============================================================================
class SplashV6Ticker extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV6Ticker({super.key, required this.onComplete});

  @override
  State<SplashV6Ticker> createState() => _SplashV6TickerState();
}

class _SplashV6TickerState extends State<SplashV6Ticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
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
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final v = _ctrl.value;
                final showReady = v > 0.72;

                return Column(
                  children: [
                    const SizedBox(height: ComebakLayout.spaceXxl),

                    // Top row — STREAK / XP labels
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ComebakLayout.spaceLg,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'STREAK',
                            style: ComebakTypography.labelSmall.copyWith(
                              color: ComebakColors.neonGreen,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'XP',
                            style: ComebakTypography.labelSmall.copyWith(
                              color: ComebakColors.neonYellow,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Center — ticking number OR READY
                    if (!showReady)
                      _TickerNumber(v: v)
                    else
                      Column(
                        children: [
                          Text(
                            'READY',
                            style: ComebakTypography.greeting.copyWith(
                              fontSize: 64,
                              color: ComebakColors.neonGreen,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: ComebakLayout.spaceMd),
                          Text(
                            'come back.',
                            style: ComebakTypography.greeting.copyWith(
                              fontSize: 22,
                              color: ComebakColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // Bottom pill row
                    Padding(
                      padding: const EdgeInsets.all(ComebakLayout.spaceXl),
                      child: Row(
                        children: [
                          _pill('×1.0', ComebakColors.neonGreen),
                          const SizedBox(width: ComebakLayout.spaceSm),
                          _pill('60s', ComebakColors.neonOrange),
                          const SizedBox(width: ComebakLayout.spaceSm),
                          _pill('READY', ComebakColors.neonYellow),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Skip
            Positioned(
              top: ComebakLayout.spaceMd,
              right: ComebakLayout.spaceLg,
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'SKIP',
                  style: ComebakTypography.labelSmall.copyWith(
                    color: ComebakColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ComebakLayout.spaceMd,
          vertical: ComebakLayout.spaceXs,
        ),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(ComebakLayout.radiusSm),
          border: Border.all(color: c.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(color: c),
        ),
      );
}

// ==============================================================================
// [LOCAL WIDGET] Three-digit tabular counter
// ==============================================================================
class _TickerNumber extends StatelessWidget {
  final double v;
  const _TickerNumber({required this.v});

  @override
  Widget build(BuildContext context) {
    final n = (v * 100).floor().clamp(0, 999);
    final s = n.toString().padLeft(3, '0');
    return Column(
      children: [
        Text(
          s,
          style: ComebakTypography.greeting.copyWith(
            fontSize: 120,
            height: 1.0,
            color: ComebakColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(
          '+${(v * 60).floor()} streak',
          style: ComebakTypography.bodyMedium.copyWith(
            color: ComebakColors.neonGreen,
          ),
        ),
      ],
    );
  }
}