import 'dart:math' as math; // ADDED IMPORT
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

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
      size: const Size(48, 64),
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
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(p.scale);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.rotate(p.rotation);

    final path = _buildThunderPath();

    canvas.drawPath(
      path.shift(Offset(p.extrude, p.extrude)),
      Paint()..color = Colors.black.withOpacity(0.8 * p.brightness),
    );

    canvas.drawPath(
      path.shift(Offset(p.extrude * 0.5, p.extrude * 0.5)),
      Paint()..color = const Color(0xFF003D16).withOpacity(p.brightness),
    );

    final angle = time * 0.5;
    final fillGradient = LinearGradient(
      begin: Alignment(math.cos(angle), math.sin(angle)),
      end: Alignment(-math.cos(angle), -math.sin(angle)),
      colors: const [Color(0xFF00C853), Color(0xFF00E676), Colors.white],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, Paint()..shader = fillGradient);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height),
      Paint()
        ..color = Colors.black.withOpacity(0.4 * p.brightness)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final glossSegment = metrics.first.extractPath(
        0,
        metrics.first.length * 0.3,
      );
      canvas.drawPath(
        glossSegment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.9 * p.brightness)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = ComebakColors.neonGreen.withOpacity(0.9 * p.brightness),
    );

    canvas.restore();
  }

  Path _buildThunderPath() {
    final path = Path();
    path.moveTo(32, 0);
    path.lineTo(0, 40);
    path.lineTo(20, 40);
    path.lineTo(12, 64);
    path.lineTo(48, 24);
    path.lineTo(28, 24);
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
  final double rotation;
  final double brightness;
  const _Pose({
    required this.scale,
    required this.extrude,
    required this.rotation,
    required this.brightness,
  });
}
