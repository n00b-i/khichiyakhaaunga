import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 4 — SPLASH] "SHATTER"
// ------------------------------------------------------------------------------
// Concept: 24 particles explode outward from center, then reform inward.
// Copy: "BREAK." (first half) → "REFORM." (second half).
// Runtime: 2.6s. Skip always visible.
// ==============================================================================
class SplashV4Shatter extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV4Shatter({super.key, required this.onComplete});

  @override
  State<SplashV4Shatter> createState() => _SplashV4ShatterState();
}

class _SplashV4ShatterState extends State<SplashV4Shatter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
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
      body: Stack(
        children: [
          // Particle field
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: _ShatterPainter(t: _ctrl.value),
                ),
              ),
            ),
          ),

          // Two-phase headline — BREAK → REFORM
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 60,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final isFirstHalf = _ctrl.value < 0.45;
                final phase = isFirstHalf ? 'BREAK.' : 'REFORM.';
                final t = Curves.easeOut.transform(
                  (isFirstHalf
                          ? _ctrl.value / 0.45
                          : (_ctrl.value - 0.45) / 0.55)
                      .clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Center(
                    child: Text(
                      phase,
                      style: ComebakTypography.greeting.copyWith(
                        fontSize: 40,
                        color: isFirstHalf
                            ? ComebakColors.vibrantRed
                            : ComebakColors.neonGreen,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Skip
          Positioned(
            top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
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
    );
  }
}

// ==============================================================================
// [PAINTER] 24 particles — explode (0-35%), hold (35-60%), converge (60-100%).
// Color flips from neonGreen to flameOrange at 60% mark — the "turn".
// ==============================================================================
class _ShatterPainter extends CustomPainter {
  final double t;
  _ShatterPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const n = 24;
    final rnd = math.Random(11);

    for (var i = 0; i < n; i++) {
      final baseAngle = (i / n) * 2 * math.pi;
      final seed = rnd.nextDouble();
      final startR = 2;
      final peakR = 100 + seed * 20;

      double r;
      double opacity;
      if (t < 0.35) {
        final p = Curves.easeOut.transform(t / 0.35);
        r = startR + (peakR - startR) * p;
        opacity = 1.0;
      } else if (t < 0.6) {
        r = peakR;
        opacity = 1.0;
      } else {
        final p = Curves.easeInOut.transform((t - 0.6) / 0.4);
        r = peakR * (1 - p);
        opacity = 1.0 - p * 0.4;
      }

      final pos = Offset(
        cx + math.cos(baseAngle) * r,
        cy + math.sin(baseAngle) * r,
      );

      final color = t < 0.6
          ? ComebakColors.neonGreen
          : ComebakColors.flameOrange;

      canvas.drawCircle(
        pos,
        3.5,
        Paint()..color = color.withOpacity(opacity),
      );
    }

    // Center glow — decays as particles return
    canvas.drawCircle(
      Offset(cx, cy),
      30,
      Paint()
        ..color = ComebakColors.neonGreen.withOpacity(0.3 * (1 - t))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  @override
  bool shouldRepaint(covariant _ShatterPainter old) => old.t != t;
}