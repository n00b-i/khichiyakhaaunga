import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakClayLogo extends StatelessWidget {
  final int pose;
  const ComebakClayLogo({super.key, required this.pose});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 80), // Tight bounding box matching text height
      painter: _ClayLogoPainter(pose: pose),
    );
  }
}

class _ClayLogoPainter extends CustomPainter {
  final int pose;
  _ClayLogoPainter({required this.pose});

  static const List<_Pose> _poses = [
    _Pose(scale: 0.60, extrude: 0.0, rotation: 0.00, brightness: 0.30),
    _Pose(scale: 0.75, extrude: 2.0, rotation: 0.14, brightness: 0.55),
    _Pose(scale: 0.90, extrude: 4.0, rotation: -0.07, brightness: 0.75),
    _Pose(scale: 1.00, extrude: 6.0, rotation: 0.03, brightness: 0.95),
    _Pose(scale: 1.00, extrude: 6.0, rotation: 0.00, brightness: 1.00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = _poses[pose.clamp(0, _poses.length - 1)];
    
    canvas.save();
    // Center it in the 60x80 box
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(p.scale);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.rotate(p.rotation);

    final path = _buildThunderPath();

    // 1. Back face (extruded shadow)
    canvas.drawPath(
      path.shift(Offset(p.extrude, p.extrude)),
      Paint()
        ..style = PaintingStyle.fill
        ..color = ComebakColors.canvas.withOpacity(p.brightness),
    );

    // 2. Side face (mid-tone bevel)
    canvas.drawPath(
      path.shift(Offset(p.extrude * 0.5, p.extrude * 0.5)),
      Paint()
        ..style = PaintingStyle.fill
        ..color = ComebakColors.surfaceElevated.withOpacity(p.brightness),
    );

    // 3. Front face (clay top)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = ComebakColors.surfaceElevated.withOpacity(p.brightness),
    );

    // 4. Neon rim (stroke only, on top of fill)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ComebakColors.neonGreen.withOpacity(0.9 * p.brightness),
    );

    // 5. Specular gloss on the top-left edge
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final full = metrics.first.length;
      final glossSegment = metrics.first.extractPath(0, full * 0.4);
      canvas.drawPath(
        glossSegment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.7 * p.brightness),
      );
    }

    canvas.restore();
  }

  Path _buildThunderPath() {
    // Sharp, classic lightning bolt filling a 60x80 box perfectly.
    final path = Path();
    path.moveTo(40, 0);     // Top point
    path.lineTo(0, 50);     // Down left
    path.lineTo(25, 50);    // Inner right
    path.lineTo(15, 80);    // Bottom point
    path.lineTo(60, 30);    // Up right
    path.lineTo(35, 30);    // Inner left
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ClayLogoPainter old) => old.pose != pose;
}

class _Pose {
  final double scale;
  final double extrude;
  final double rotation;
  final double brightness;
  const _Pose({required this.scale, required this.extrude, required this.rotation, required this.brightness});
}