import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 3 — SPLASH] "BURN"
// ------------------------------------------------------------------------------
// Concept: Single flame grows from center. Warm minimalism, three-layer clay.
// Copy: "let it burn." fading in at 55% mark.
// Runtime: 2.4s. Skip always visible.
// Uses existing flame tokens — color cohesion with Home streak card.
// ==============================================================================
class SplashV3Burn extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV3Burn({super.key, required this.onComplete});

  @override
  State<SplashV3Burn> createState() => _SplashV3BurnState();
}

class _SplashV3BurnState extends State<SplashV3Burn>
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
      body: Stack(
        children: [
          // Hero flame
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOut.transform(
                  (_ctrl.value * 1.4).clamp(0.0, 1.0),
                );
                return SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: _FlamePainter(progress: t),
                  ),
                );
              },
            ),
          ),

          // Copy
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOut.transform(
                  ((_ctrl.value - 0.55) / 0.35).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Center(
                    child: Text(
                      'let it burn.',
                      style: ComebakTypography.greeting.copyWith(
                        fontSize: 28,
                        color: ComebakColors.textSecondary,
                        fontStyle: FontStyle.italic,
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
// [PAINTER] Layered flame — red outer, orange mid, yellow core.
// Per Master.txt §8: colored ambient shadow, specular gloss top-left.
// ==============================================================================
class _FlamePainter extends CustomPainter {
  final double progress;
  _FlamePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;
    final baseR = 40 * progress;

    // Colored ambient shadow — never black
    final shadow = Paint()
      ..color = ComebakColors.flameOrange.withValues(alpha: 0.35 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(cx, cy), baseR * 1.4, shadow);

    // Flame teardrop curve — outer to inner
    Path flamePath(double scale) {
      final w = 70 * scale;
      final h = 140 * scale;
      return Path()
        ..moveTo(cx, cy - h / 2)
        ..quadraticBezierTo(cx + w / 2, cy - h / 6, cx + w / 4, cy + h / 4)
        ..quadraticBezierTo(cx + w / 2.2, cy + h / 3, cx, cy + h / 2)
        ..quadraticBezierTo(cx - w / 2.2, cy + h / 3, cx - w / 4, cy + h / 4)
        ..quadraticBezierTo(cx - w / 2, cy - h / 6, cx, cy - h / 2)
        ..close();
    }

    canvas.drawPath(
      flamePath(1.0),
      Paint()
        ..color = ComebakColors.flameRed.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      flamePath(0.7),
      Paint()
        ..color = ComebakColors.flameOrange
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      flamePath(0.4),
      Paint()
        ..color = ComebakColors.flameYellow
        ..style = PaintingStyle.fill,
    );

    // Specular gloss — top-left on outer face
    final gloss = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(cx - 8, cy - 25);
    canvas.rotate(-0.4);
    canvas.drawOval(const Rect.fromLTWH(-6, -12, 12, 24), gloss);
    canvas.restore();

    // Flicker embers — 8 dots above flame
    final rnd = math.Random(7);
    for (var i = 0; i < 8; i++) {
      final ex = cx + (rnd.nextDouble() - 0.5) * 90;
      final ey = cy - 80 - rnd.nextDouble() * 40;
      canvas.drawCircle(
        Offset(ex, ey),
        1.5,
        Paint()..color = ComebakColors.neonYellow.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.progress != progress;
}