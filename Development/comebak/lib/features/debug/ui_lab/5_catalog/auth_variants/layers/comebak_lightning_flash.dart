import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [PAINTER] ComebakLightningFlash
// ------------------------------------------------------------------------------
// PURPOSE: 3-branch lightning strike across the XP cube.
// NARRATIVE ROLE: This is THE punctuation of the splash. Lands at frame 156
//   (t=2.6s), the exact moment the quote finishes typing. White core for 1
//   frame only, then decays over 15 frames. Never repeats within one splash.
// THREE BRANCHES:
//   - main: vertical jagged line, top-right to cube center
//   - left:  fork at 60° off main, shorter
//   - right: fork at -40° off main, shorter still
// LIGHTING RULE: This is the ONLY place pure white (#FFFFFF) appears in the
//   entire splash. The rule is intentional — white is reserved for the flash,
//   so the flash always feels like lightning, never like UI.
// DETERMINISM: Branch geometry seeded by `branchSeed`. Same seed = same bolt.
//   Without this, repaints would redraw differently and look like a strobe.
// FLASH VALUE: Caller supplies `flash` (0..1) PRE-CURVED. Painter does no
//   timing math. Orchestrator owns the exponential decay curve.
// ==============================================================================
class ComebakLightningFlash extends StatelessWidget {
  /// 0.0 = invisible, 1.0 = white peak. Values between = decay.
  final double flash;

  /// Fixed seed for the bolt shape. Keep constant per splash open.
  /// Changing this per open would make every flash look like a different bolt.
  final int branchSeed;

  /// Overall widget size. The flash extends beyond the XP cube.
  final double size;

  const ComebakLightningFlash({
    super.key,
    required this.flash,
    this.branchSeed = 42,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (flash <= 0.01) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LightningPainter(
            flash: flash,
            branchSeed: branchSeed,
          ),
        ),
      ),
    );
  }
}

class _LightningPainter extends CustomPainter {
  final double flash;
  final int branchSeed;

  _LightningPainter({required this.flash, required this.branchSeed});

  @override
  void paint(Canvas canvas, Size size) {
    final f = flash.clamp(0.0, 1.0);

    // Bolt origins — top-right quadrant, striking down-left toward cube.
    final startX = size.width * 0.85;
    final startY = size.height * 0.05;
    final endX = size.width * 0.50;
    final endY = size.height * 0.55;

    // --- Build main bolt path ------------------------------------------------
    final main = _buildJaggedPath(
      Offset(startX, startY),
      Offset(endX, endY),
      segments: 8,
      seed: branchSeed,
    );

    // --- Build two fork paths ------------------------------------------------
    // Forks branch at ~40% and ~60% along the main bolt.
    final forkA = _buildJaggedPath(
      _pointOnPath(main, 0.40),
      Offset(size.width * 0.25, size.height * 0.40),
      segments: 5,
      seed: branchSeed + 7,
    );
    final forkB = _buildJaggedPath(
      _pointOnPath(main, 0.60),
      Offset(size.width * 0.75, size.height * 0.70),
      segments: 4,
      seed: branchSeed + 13,
    );

    // -------------------------------------------------------------------------
    // LAYER 1: outer colored halo
    // Wide green blur. Only visible when flash > 0.15 (during the decay).
    // -------------------------------------------------------------------------
    if (f > 0.15) {
      final haloAlpha = ((f - 0.15) / 0.85 * 0.55).clamp(0.0, 0.55);
      final haloPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ComebakColors.neonGreen.withValues(alpha: haloAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawPath(main, haloPaint);
      canvas.drawPath(forkA, haloPaint);
      canvas.drawPath(forkB, haloPaint);
    }

    // -------------------------------------------------------------------------
    // LAYER 2: green body
    // Mid-width stroke, no blur. Present through entire flash.
    // -------------------------------------------------------------------------
    if (f > 0.05) {
      final bodyPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ComebakColors.neonGreen.withValues(alpha: 0.95 * f);

      canvas.drawPath(main, bodyPaint);
      canvas.drawPath(forkA, bodyPaint);
      canvas.drawPath(forkB, bodyPaint);
    }

    // -------------------------------------------------------------------------
    // LAYER 3: white core
    // The only pure-white element in the splash. Visible only at peak (f > 0.5).
    // -------------------------------------------------------------------------
    if (f > 0.5) {
      final coreAlpha = ((f - 0.5) / 0.5).clamp(0.0, 1.0);
      final corePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: coreAlpha);

      canvas.drawPath(main, corePaint);
      canvas.drawPath(forkA, corePaint);
      canvas.drawPath(forkB, corePaint);
    }

    // -------------------------------------------------------------------------
    // LAYER 4: full-screen white wash
    // Very faint. This is what makes the flash feel like it lights the room,
    // not just the bolt. Fades to zero by f=0.3.
    // -------------------------------------------------------------------------
    if (f > 0.3) {
      final washAlpha = ((f - 0.3) / 0.7 * 0.08).clamp(0.0, 0.08);
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: washAlpha),
      );
    }
  }

  // ==========================================================================
  // Jagged path builder — deterministic, seeded.
  // Each segment jitters perpendicular to the general direction by ±jitter.
  // Jitter decreases linearly so the bolt gets straighter at the tip.
  // ==========================================================================
  Path _buildJaggedPath(
    Offset start,
    Offset end, {
    required int segments,
    required int seed,
  }) {
    final rnd = math.Random(seed);
    final path = Path()..moveTo(start.dx, start.dy);

    // Direction vector, used to compute perpendicular for jitter
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final nx = -dy / len; // perpendicular
    final ny = dx / len;

    // Max jitter is 8% of bolt length, tapering to zero at the end
    final maxJitter = len * 0.08;

    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      final baseX = start.dx + dx * t;
      final baseY = start.dy + dy * t;

      // Tapering jitter — straight at the tip
      final taper = 1.0 - t * 0.7;
      final jitter = (rnd.nextDouble() * 2 - 1) * maxJitter * taper;

      path.lineTo(baseX + nx * jitter, baseY + ny * jitter);
    }

    path.lineTo(end.dx, end.dy);
    return path;
  }

  // ==========================================================================
  // Sample a point at `t` (0..1) along a path — used to find fork origins.
  // ==========================================================================
  Offset _pointOnPath(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset.zero;
    final metric = metrics.first;
    final tangent = metric.getTangentForOffset(metric.length * t);
    return tangent?.position ?? Offset.zero;
  }

  @override
  bool shouldRepaint(covariant _LightningPainter old) =>
      old.flash != flash || old.branchSeed != branchSeed;
}