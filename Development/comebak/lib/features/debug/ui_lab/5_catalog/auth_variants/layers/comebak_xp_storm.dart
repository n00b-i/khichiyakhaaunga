import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [PAINTER] ComebakXpStorm
// ------------------------------------------------------------------------------
// PURPOSE: Isometric clay cube with embossed `×` on the top face.
// NARRATIVE ROLE: Lands on screen at frame 144 (t=2.4s) at 40% brightness,
//   waits for lightning at frame 156, catches the flash, then decays to 15%.
//   The cube is NOT the subject of the flash — the lightning is. The cube
//   just proves the lightning happened by the way it briefly lights up.
// GEOMETRY (Master.txt §8 — 140x140 grid, scaled by width/140):
//   - Cube sits on 140-grid at 60x60x60 units
//   - Top face: rhombus, width 60, height 30, extruded 30 units down
//   - Left face and right face complete the isometric cube
//   - `×` glyph embossed on TOP face only
// EMBOSS (Master.txt §8 — 3-layer TextPainter):
//   Layer 1: deep shadow, dy:4, dark green
//   Layer 2: mid-tone, dy:2, muted green
//   Layer 3: white top, dy:0, thin white with blur 2
// COLOR SHADOWS ONLY: All shadows use colored base, never pure black.
// ==============================================================================
class ComebakXpStorm extends StatelessWidget {
  /// Global brightness multiplier 0..1. Orchestrator drives this.
  /// 0.4 = fading in, 1.0 = catching lightning flash, 0.15 = settled ambient.
  final double brightness;

  /// Widget edge length. Cube occupies ~43% of the width on the 140-grid.
  final double size;

  const ComebakXpStorm({
    super.key,
    required this.brightness,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _XpCubePainter(brightness: brightness),
      ),
    );
  }
}

class _XpCubePainter extends CustomPainter {
  final double brightness;
  _XpCubePainter({required this.brightness});

  @override
  void paint(Canvas canvas, Size size) {
    final b = brightness.clamp(0.0, 1.0);

    // Scale factor from 140-design-grid to actual widget.
    // Master.txt §8 — never hardcode, always scale by width/140.
    final s = size.width / 140.0;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Cube dimensions in grid units (60 wide, 30 tall rhombus, 30 extrusion).
    final w = 60 * s;
    final h = 30 * s;
    final ext = 30 * s;

    // Top rhombus (center at cx, cy - ext/2 so the cube sits visually centered)
    final topCenterY = cy - ext * 0.5;
    final top = Path()
      ..moveTo(cx, topCenterY - h / 2)
      ..lineTo(cx + w / 2, topCenterY)
      ..lineTo(cx, topCenterY + h / 2)
      ..lineTo(cx - w / 2, topCenterY)
      ..close();

    // Left face — rhombus extrapolated down by extrusion
    final left = Path()
      ..moveTo(cx - w / 2, topCenterY)
      ..lineTo(cx, topCenterY + h / 2)
      ..lineTo(cx, topCenterY + h / 2 + ext)
      ..lineTo(cx - w / 2, topCenterY + ext)
      ..close();

    // Right face
    final right = Path()
      ..moveTo(cx, topCenterY + h / 2)
      ..lineTo(cx + w / 2, topCenterY)
      ..lineTo(cx + w / 2, topCenterY + ext)
      ..lineTo(cx, topCenterY + h / 2 + ext)
      ..close();

    // -------------------------------------------------------------------------
    // Ambient shadow — colored, never black. Blurred ellipse under the cube.
    // -------------------------------------------------------------------------
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 4 * s, topCenterY + h / 2 + ext + 8 * s),
        width: w * 1.2,
        height: h * 1.0,
      ),
      Paint()
        ..color = ComebakColors.neonGreen.withValues(alpha: 0.20 * b)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 * s),
    );

    // -------------------------------------------------------------------------
    // Three faces, three shades. Top = brightest (catches light from above),
    // left = mid, right = darkest (turned away from key light top-left).
    // -------------------------------------------------------------------------
    final topFill = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.surfaceElevated.withValues(alpha: 0.95 * b);

    final leftFill = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.canvas.withValues(alpha: 0.85 * b);

    final rightFill = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.canvas.withValues(alpha: 0.95 * b);

    canvas.drawPath(left, leftFill);
    canvas.drawPath(right, rightFill);
    canvas.drawPath(top, topFill);

    // -------------------------------------------------------------------------
    // Bevel strokes — round joins, per Master.txt §8. First pass is the
    // clay bevel (thick), second pass is the rim (thin, neon).
    // -------------------------------------------------------------------------
    final bevelStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = ComebakColors.surfaceElevated.withValues(alpha: 0.6 * b);

    canvas.drawPath(top, bevelStroke);
    canvas.drawPath(left, bevelStroke);
    canvas.drawPath(right, bevelStroke);

    final rimStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = ComebakColors.neonGreen.withValues(alpha: 0.9 * b);

    canvas.drawPath(top, rimStroke);
    canvas.drawPath(left, rimStroke);
    canvas.drawPath(right, rimStroke);

    // -------------------------------------------------------------------------
    // `×` glyph — 3-layer emboss on top face.
    // Layer 1: deep shadow, offset dy = 4
    // Layer 2: mid-tone, offset dy = 2
    // Layer 3: white top, offset dy = 0
    // -------------------------------------------------------------------------
    _paintEmbossedX(canvas, Offset(cx, topCenterY), s, b);

    // -------------------------------------------------------------------------
    // Specular gloss — thin white stroke on the top face's upper-left edge.
    // Only a segment, not the whole path. Extract the top-left edge only.
    // -------------------------------------------------------------------------
    final metrics = top.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final totalLen = metrics.first.length;
      // First 30% of the rhombus perimeter = the upper-left edge
      final glossSegment = metrics.first.extractPath(0, totalLen * 0.30);
      canvas.drawPath(
        glossSegment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * s
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35 * b),
      );
    }
  }

  void _paintEmbossedX(Canvas canvas, Offset center, double s, double b) {
    // Glyph size: 60% of rhombus height. Fits comfortably.
    final fontSize = 24 * s;

    // Layer 1: deep shadow
    _paintGlyph(
      canvas,
      center + Offset(0, 4 * s),
      fontSize,
      ComebakColors.canvas.withValues(alpha: 0.9 * b),
    );

    // Layer 2: mid-tone
    _paintGlyph(
      canvas,
      center + Offset(0, 2 * s),
      fontSize,
      ComebakColors.mutedGreen.withValues(alpha: 0.95 * b),
    );

    // Layer 3: white top
    _paintGlyph(
      canvas,
      center,
      fontSize,
      Colors.white.withValues(alpha: b),
    );
  }

  void _paintGlyph(
    Canvas canvas,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: '×',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _XpCubePainter old) =>
      old.brightness != brightness;
}