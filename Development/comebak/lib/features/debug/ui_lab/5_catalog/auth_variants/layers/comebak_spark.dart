import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [PAINTER] ComebakSpark
// ------------------------------------------------------------------------------
// PURPOSE: The micro-ignition at frame 0–72. A point of green light that
//   grows from 3px to 40px and merges into the lava bed beneath it.
// NARRATIVE ROLE: This is the "electrical impulse" — the very first thing
//   the user sees. Reference: Fincher's opening synapse in the amygdala.
// MOTION: Three concentric rings of increasing blur radius. The outermost
//   ring is the halo (colored, soft). The middle ring is the body. The inner
//   ring is the hot core (only visible when progress > 0.7).
// INTERPOLATION: Caller passes `progress` (0..1); painter never animates.
// ==============================================================================
class ComebakSpark extends StatelessWidget {
  /// 0.0 = invisible, 1.0 = full merge size
  final double progress;

  /// 0.0 = cold green, 1.0 = hot core visible
  final double ignition;

  const ComebakSpark({
    super.key,
    required this.progress,
    this.ignition = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(120),
      painter: _SparkPainter(
        progress: progress,
        ignition: ignition,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final double progress;
  final double ignition;

  _SparkPainter({required this.progress, required this.ignition});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Radius curve — fast growth then settle.
    // math.pow handles the ease-in on start (spark "lights up" instantly,
    // then expands).
    final t = progress.clamp(0.0, 1.0);
    final r = 3.0 + 37.0 * math.pow(t, 0.6).toDouble();

    // --- Layer 1: outer halo ------------------------------------------------
    // Wide soft green glow. This is what makes the spark feel like light,
    // not a dot. Alpha fades IN with t (so at t=0 it's not visible).
    final haloAlpha = (0.35 * t).clamp(0.0, 0.35);
    canvas.drawCircle(
      Offset(cx, cy),
      r * 3.0,
      Paint()
        ..color = ComebakColors.neonGreen.withValues(alpha: haloAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // --- Layer 2: body ------------------------------------------------------
    // The green core. Brighter than the halo, less blurred.
    final bodyAlpha = (0.55 * t).clamp(0.0, 0.55);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = ComebakColors.neonGreen.withValues(alpha: bodyAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // --- Layer 3: hot core --------------------------------------------------
    // White-green flash. Only visible when ignition > 0 (i.e., during the
    // molten surge, not during initial spark growth).
    if (ignition > 0.01) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.4,
        Paint()
          ..color = ComebakColors.flameYellow
              .withValues(alpha: 0.9 * ignition.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.progress != progress || old.ignition != ignition;
}