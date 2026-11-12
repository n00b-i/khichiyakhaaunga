import 'dart:math' as math;
import 'package:flutter/material.dart';

class ComebakClayLogo extends StatelessWidget {
  final int pose;
  final double time;
  final bool enableSparks;

  const ComebakClayLogo({
    super.key,
    required this.pose,
    required this.time,
    this.enableSparks = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(56, 72),
      painter: _ClayLogoPainter(
        pose: pose,
        time: time,
        enableSparks: enableSparks,
      ),
    );
  }
}

class _ClayLogoPainter extends CustomPainter {
  final int pose;
  final double time;
  final bool enableSparks;

  _ClayLogoPainter({
    required this.pose,
    required this.time,
    required this.enableSparks,
  });

  static const List<_Pose> _poses = [
    _Pose(scale: 0.60, extrude: 0.0, brightness: 0.30),
    _Pose(scale: 0.75, extrude: 2.0, brightness: 0.55),
    _Pose(scale: 0.90, extrude: 4.0, brightness: 0.75),
    _Pose(scale: 1.00, extrude: 6.0, brightness: 0.95),
    _Pose(scale: 1.00, extrude: 6.0, brightness: 1.00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = _poses[pose.clamp(0, _poses.length - 1)];

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(p.scale);
    canvas.rotate(math.pi / 4);
    canvas.scale(1.0, -1.0);
    canvas.translate(-size.width / 2, -size.height / 2);

    final leftBolt = _buildLeftBolt(size);
    final rightBolt = _buildRightBolt(size);

    final ex = p.extrude;
    final ey = p.extrude;

    // 1. THE EXTRUSION (Back 3D Body - Solid, no shadow)
    final backPaint = Paint()
      ..color = const Color(0xFF003D16).withValues(alpha: p.brightness);

    canvas.save();
    canvas.translate(ex, ey);
    canvas.drawPath(leftBolt, backPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(ex * 1.2, ey * 1.2);
    canvas.drawPath(rightBolt, backPaint);
    canvas.restore();

    // 2. THE FRONT FACES (The colored clay)
    final leftGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00E676), Color(0xFF00C853)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rightGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF69F0AE), Color(0xFF00E676)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(
      leftBolt,
      Paint()
        ..shader = leftGradient
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      rightBolt,
      Paint()
        ..shader = rightGradient
        ..style = PaintingStyle.fill,
    );

    // NO white borders, NO inner blur shadows. Clean flat 3D.
    canvas.restore();
  }

  Path _buildLeftBolt(Size size) {
    final scale = size.width / 300;
    final path = Path();
    path.moveTo(80 * scale, 40 * scale);
    path.lineTo(140 * scale, 200 * scale);
    path.lineTo(100 * scale, 200 * scale);
    path.lineTo(150 * scale, 360 * scale);
    path.lineTo(60 * scale, 220 * scale);
    path.lineTo(100 * scale, 220 * scale);
    path.lineTo(40 * scale, 100 * scale);
    path.close();
    return path;
  }

  Path _buildRightBolt(Size size) {
    final scale = size.width / 300;
    final path = Path();
    path.moveTo(220 * scale, 40 * scale);
    path.lineTo(160 * scale, 200 * scale);
    path.lineTo(200 * scale, 200 * scale);
    path.lineTo(150 * scale, 360 * scale);
    path.lineTo(240 * scale, 220 * scale);
    path.lineTo(200 * scale, 220 * scale);
    path.lineTo(260 * scale, 100 * scale);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ClayLogoPainter old) =>
      old.pose != pose || old.time != time || old.enableSparks != enableSparks;
}

class _Pose {
  final double scale;
  final double extrude;
  final double brightness;
  const _Pose({
    required this.scale,
    required this.extrude,
    required this.brightness,
  });
}
