import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 5 — SPLASH] "INK"
// ------------------------------------------------------------------------------
// Concept: Single brush stroke draws a spiral. Zen calligraphy on dark.
// Copy: "come back." with wide letterSpacing, fades at 70% mark.
// Runtime: 2.2s. Skip always visible.
// Note: path is drawn progressively using computeMetrics().extractPath().
// ==============================================================================
class SplashV5Ink extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV5Ink({super.key, required this.onComplete});

  @override
  State<SplashV5Ink> createState() => _SplashV5InkState();
}

class _SplashV5InkState extends State<SplashV5Ink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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
          // Ink spiral
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _InkPainter(t: _ctrl.value),
                ),
              ),
            ),
          ),

          // "come back." fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 140,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOut.transform(
                  ((_ctrl.value - 0.7) / 0.3).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Center(
                    child: Text(
                      'come back.',
                      style: ComebakTypography.greeting.copyWith(
                        fontSize: 20,
                        color: ComebakColors.textSecondary,
                        letterSpacing: 6,
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
// [PAINTER] Spiral drawn progressively via PathMetric extraction.
// Two-pass stroke: soft blur glow underneath + crisp main brush on top.
// ==============================================================================
class _InkPainter extends CustomPainter {
  final double t;
  _InkPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Build the full spiral path
    final path = Path();
    const turns = 2.6;
    const maxR = 70.0;
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final p = i / steps;
      final angle = p * turns * 2 * math.pi - math.pi / 2;
      final r = maxR * p;
      final x = cx + r * (1 - p * 0.3) * math.cos(angle);
      final y = cy + r * (1 - p * 0.3) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Extract partial path up to progress t
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLen = metrics.first.length;
    final drawLen = totalLen * Curves.easeInOut.transform(t);
    final drawn = metrics.first.extractPath(0, drawLen);

    // Under-glow — soft blur behind brush
    final glow = Paint()
      ..color = ComebakColors.textPrimary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(drawn, glow);

    // Main brush — crisp
    final brush = Paint()
      ..color = ComebakColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(drawn, brush);
  }

  @override
  bool shouldRepaint(covariant _InkPainter old) => old.t != t;
}