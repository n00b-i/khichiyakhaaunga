import 'package:flutter/material.dart';

// ==============================================================================
// [ATOM] ComebakGoogleMark
// ------------------------------------------------------------------------------
// PURPOSE: The Google "G" as four colored arcs + a blue cross-bar.
// Grid: 24x24. Scales via `size.width / 24.0` — never hardcode px.
// Source colors: official Google brand (blue/red/yellow/green) — exception to
// ComebakColors because brand-locked to Google identity guidelines.
// ==============================================================================
class ComebakGoogleMark extends StatelessWidget {
  final double size;
  const ComebakGoogleMark({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 10 * s;
    final stroke = 4 * s;

    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    void arc(Color c, double start, double sweep) {
      final p = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        p,
      );
    }

    arc(blue, -0.35, 1.35);
    arc(red, 1.0, 1.0);
    arc(yellow, 2.0, 1.0);
    arc(green, 3.0, 1.55);

    // Blue horizontal bar (the G's cross-bar)
    final bar = Paint()..color = blue..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - stroke / 2,
        radius + stroke / 2,
        stroke,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}